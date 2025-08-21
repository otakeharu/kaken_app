import UIKit

// MARK: - Layout constants
private enum Grid {
    static let titleWidth: CGFloat   = 120
    static let editWidth: CGFloat    = 80
    static let dayWidth: CGFloat     = 44
    static let rowHeight: CGFloat    = 44
    static let headerHeight: CGFloat = 44
    static let maxRows               = 24
    static let lineWidth: CGFloat    = 1.0 / UIScreen.main.scale // 1px 相当
}

// MARK: - UserDefaults keys
private enum UDKey {
    static let createdAt   = "gantt.createdAt"   // "yyyy-MM-dd"（表示開始日）
    static let goalEnd     = "gantt.goalEnd"     // "yyyy-MM-dd"（表示終了日）
    static func koudou(_ i: Int) -> String { "koudou\(i)" } // koudou1..24
    static func onoff(row: Int, date: String) -> String { "onoff_\(row)_\(date)" }
    static let currentRowIndex = "vc6.currentRowIndex"
}

// MARK: - Date utils
private let jpCal    = Calendar(identifier: .gregorian)
private let jpLocale = Locale(identifier: "ja_JP")

private func ymdString(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy-MM-dd"; return df.string(from: date)
}
private func dString(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "d"; return df.string(from: date)
}
private func monthString(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy年M月"; return df.string(from: date)
}
private func parseYMD(_ s: String) -> Date? {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy-MM-dd"; return df.date(from: s)
}
private func daysArray(from start: Date, to end: Date) -> [Date] {
    var days: [Date] = []
    var cur = jpCal.startOfDay(for: start)
    let endDay = jpCal.startOfDay(for: end)
    while cur <= endDay {
        days.append(cur)
        cur = jpCal.date(byAdding: .day, value: 1, to: cur)!
    }
    return days
}
private func weekdaySymbolJP(for date: Date) -> String {
    ["日","月","火","水","木","金","土"][Calendar.current.component(.weekday, from: date) - 1]
}
private func monthStart(of date: Date) -> Date {
    let comps = jpCal.dateComponents([.year,.month], from: date)
    return jpCal.date(from: comps)!
}
private func monthEnd(of date: Date) -> Date {
    let start = monthStart(of: date)
    let next  = jpCal.date(byAdding: .month, value: 1, to: start)!
    return jpCal.date(byAdding: .day, value: -1, to: next)!
}

// MARK: - Cells（枠線は全て1px、今日強調なし、ONは薄い青）
final class HeaderMonthCell: UICollectionViewCell {
    static let reuse = "HeaderMonthCell"
    let label = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true

        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

final class HeaderDayCell: UICollectionViewCell {
    static let reuse = "HeaderDayCell"
    let label = UILabel()
    let wday  = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true

        let stack = UIStackView(arrangedSubviews: [label, wday])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        wday.font = .systemFont(ofSize: 10); wday.textColor = .secondaryLabel
        wday.textAlignment = .center

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    func configure(date: Date) {
        label.text = dString(date)
        wday.text  = weekdaySymbolJP(for: date)
    }
}

final class RowTitleCell: UICollectionViewCell {
    static let reuse = "RowTitleCell"
    let label = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true

        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

final class RowEditCell: UICollectionViewCell {
    static let reuse = "RowEditCell"
    let button = UIButton(type: .system)
    var onTap: (() -> Void)?
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true

        button.setTitle("編集", for: .normal)
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    @objc private func tap() { onTap?() }
}

final class DayStateCell: UICollectionViewCell {
    static let reuse = "DayStateCell"
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true
    }
    func configure(on: Bool) {
        contentView.backgroundColor = on
            ? UIColor.systemBlue.withAlphaComponent(0.25) // ON は薄い青
            : .systemBackground
    }
}

// MARK: - Main VC（横：UIScrollView / 縦：UICollectionView）
final class ViewController5: UIViewController {

    // 外側（横スクロール）と内側コレクション幅制約
    @IBOutlet weak var hScrollView: UIScrollView!
    @IBOutlet weak var collectionWidth: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!

    private var createdAt: Date = Date() // 表示開始
    private var goalEnd: Date   = Date() // 表示終了
    private var days: [Date] = []
    private var koudouTitles: [String] = Array(repeating: "", count: Grid.maxRows)
    private var firstVisibleDayIndex: Int = 0
    private let segueToVC6 = "toVC6"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataFromUserDefaults()
        setupCollection()
        updateContentWidth() // 横幅反映
    }

    // MARK: - Setup
    private func setupDataFromUserDefaults() {
        let ud = UserDefaults.standard

        if let s = ud.string(forKey: UDKey.createdAt), let d = parseYMD(s) {
            createdAt = d
        } else {
            createdAt = jpCal.startOfDay(for: Date())
            ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        }

        if let s = ud.string(forKey: UDKey.goalEnd), let d = parseYMD(s) {
            goalEnd = d
        } else {
            goalEnd = createdAt
            ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
        }

        // 初期表示は「開始日の属する月の月初〜月末」
        let startMonth = monthStart(of: createdAt)
        let endMonth   = monthEnd(of: createdAt)
        createdAt = startMonth
        goalEnd   = max(goalEnd, endMonth)
        ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        ud.set(ymdString(goalEnd),   forKey: UDKey.goalEnd)

        days = daysArray(from: createdAt, to: goalEnd)

        for i in 1...Grid.maxRows {
            koudouTitles[i - 1] = ud.string(forKey: UDKey.koudou(i)) ?? "koudou\(i)"
        }
    }

    private func setupCollection() {
        // 外側（横スクロール）
        hScrollView.delegate = self
        hScrollView.showsHorizontalScrollIndicator = true
        hScrollView.alwaysBounceHorizontal = true

        // 内側（縦スクロール）
        collectionView.dataSource = self
        collectionView.delegate   = self

        collectionView.register(HeaderMonthCell.self, forCellWithReuseIdentifier: HeaderMonthCell.reuse)
        collectionView.register(HeaderDayCell.self,   forCellWithReuseIdentifier: HeaderDayCell.reuse)
        collectionView.register(RowTitleCell.self,    forCellWithReuseIdentifier: RowTitleCell.reuse)
        collectionView.register(RowEditCell.self,     forCellWithReuseIdentifier: RowEditCell.reuse)
        collectionView.register(DayStateCell.self,    forCellWithReuseIdentifier: DayStateCell.reuse)

        if let fl = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            fl.scrollDirection = .vertical          // 縦専用
            fl.estimatedItemSize = .zero            // 自動サイズ無効（重要）
            fl.minimumInteritemSpacing = 0
            fl.minimumLineSpacing = 0
            fl.sectionInset = .zero
            fl.sectionInsetReference = .fromContentInset
            fl.itemSize = .zero                      // sizeForItemAt を使う
        }

        collectionView.alwaysBounceHorizontal = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.alwaysBounceVertical = true
    }

    // MARK: - 横幅＝内容幅（横スクロールの要）
    private func updateContentWidth() {
        let contentWidth = Grid.titleWidth + Grid.editWidth + CGFloat(days.count) * Grid.dayWidth
        collectionWidth.constant = contentWidth
        view.layoutIfNeeded()
    }

    // MARK: - Helpers
    private func dateForHeaderItem(_ item: Int) -> Date? {
        let dayIndex = item - 1 // item1 -> days[0]
        guard dayIndex >= 0 && dayIndex < days.count else { return nil }
        return days[dayIndex]
    }
    private func isOn(rowIndex: Int, date: Date) -> Bool {
        let key = UDKey.onoff(row: rowIndex, date: ymdString(date))
        return UserDefaults.standard.bool(forKey: key)
    }
    private func toggleOn(rowIndex: Int, date: Date) {
        let ud = UserDefaults.standard
        let key = UDKey.onoff(row: rowIndex, date: ymdString(date))
        ud.set(!ud.bool(forKey: key), forKey: key)
    }

    // 右端近くで翌月を自動追加（不要なら呼び出しを外してOK）
    private func appendNextMonthIfNeeded() {
        // 残り7列以内で発火
        let rightEdge = hScrollView.contentOffset.x + hScrollView.bounds.width
        let threshold = hScrollView.contentSize.width - Grid.dayWidth * 7
        guard rightEdge >= threshold else { return }

        guard let last = days.last else { return }
        let nextMonthEnd = monthEnd(of: jpCal.date(byAdding: .month, value: 1, to: last)!)
        if nextMonthEnd <= goalEnd { return }

        let start = jpCal.date(byAdding: .day, value: 1, to: goalEnd)!
        let more  = daysArray(from: start, to: nextMonthEnd)
        guard !more.isEmpty else { return }

        days.append(contentsOf: more)
        goalEnd = nextMonthEnd
        UserDefaults.standard.set(ymdString(goalEnd), forKey: UDKey.goalEnd)

        collectionView.reloadData()
        updateContentWidth()
    }

    // 横スクロール位置からヘッダー左端（月）を更新
    private func updateHeaderMonthIfNeeded() {
        let x = hScrollView.contentOffset.x
        let threshold = Grid.titleWidth + Grid.editWidth // 日列が始まる位置
        var idx = 0
        if x > threshold {
            let dx = x - threshold
            idx = max(0, Int(round(dx / Grid.dayWidth)))
            idx = min(idx, max(0, days.count - 1))
        }
        if idx != firstVisibleDayIndex {
            firstVisibleDayIndex = idx
            collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }

    @objc private func goToVC6(rowIndex: Int) {
        let ud = UserDefaults.standard
        ud.set(rowIndex, forKey: UDKey.currentRowIndex)
        ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        ud.set(ymdString(goalEnd),   forKey: UDKey.goalEnd)
        performSegue(withIdentifier: segueToVC6, sender: nil)
    }
}

// MARK: - DataSource
extension ViewController5: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 + Grid.maxRows }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? (1 + days.count) : (2 + days.count)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                cell.label.text = days.isEmpty ? "" : monthString(days[firstVisibleDayIndex])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HeaderDayCell.reuse, for: indexPath) as! HeaderDayCell
                if let d = dateForHeaderItem(indexPath.item) { cell.configure(date: d) }
                return cell
            }
        } else {
            let rowIndex = indexPath.section // 1..24
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RowTitleCell.reuse, for: indexPath) as! RowTitleCell
                cell.label.text = koudouTitles[rowIndex - 1]
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RowEditCell.reuse, for: indexPath) as! RowEditCell
                cell.onTap = { [weak self] in self?.goToVC6(rowIndex: rowIndex) }
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DayStateCell.reuse, for: indexPath) as! DayStateCell
                let d = days[indexPath.item - 2]
                cell.configure(on: isOn(rowIndex: rowIndex, date: d))
                return cell
            }
        }
    }
}

// MARK: - Delegate & Layout
extension ViewController5: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section >= 1, indexPath.item >= 2 {
            let rowIndex = indexPath.section
            let d = days[indexPath.item - 2]
            toggleOn(rowIndex: rowIndex, date: d)
            collectionView.reloadItems(at: [indexPath])
        } else if indexPath.section >= 1, indexPath.item == 1 {
            goToVC6(rowIndex: indexPath.section)
        }
    }

    // 横スクロールは外側 UIScrollView を監視
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === hScrollView {
            updateHeaderMonthIfNeeded()
            appendNextMonthIfNeeded() // 右端付近で翌月を追加（不要ならコメントアウト）
        }
    }

    // セルの固定サイズ（必須）
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let w: CGFloat = (indexPath.item == 0) ? (Grid.titleWidth + Grid.editWidth) : Grid.dayWidth
            return CGSize(width: w, height: Grid.headerHeight)
        } else {
            let w: CGFloat = (indexPath.item == 0) ? Grid.titleWidth
                         : (indexPath.item == 1) ? Grid.editWidth
                         : Grid.dayWidth
            return CGSize(width: w, height: Grid.rowHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
}
