import UIKit

// MARK: - Constants (列幅など)
private enum Grid {
    static let titleWidth: CGFloat = 120   // item0 行名
    static let editWidth: CGFloat  = 80    // item1 編集
    static let dayWidth: CGFloat   = 44    // item2以降 日付列
    static let rowHeight: CGFloat  = 44
    static let headerHeight: CGFloat = 44
    static let maxRows = 24
}

// MARK: - UserDefaults Keys
private enum UDKey {
    static let createdAt   = "gantt.createdAt"   // "yyyy-MM-dd"
    static let goalEnd     = "gantt.goalEnd"     // "yyyy-MM-dd"
    static func koudou(_ i: Int) -> String { "koudou\(i)" } // 1...24
    static func onoff(row: Int, date: String) -> String { "onoff_\(row)_\(date)" }
    // VC6 へ渡す一時キー（VC6 側でも読み取る）
    static let currentRowIndex = "vc6.currentRowIndex" // 1...24
}

// MARK: - Date utils
private let jpCal = Calendar(identifier: .gregorian)
private let jpLocale = Locale(identifier: "ja_JP")

private func ymdString(_ date: Date) -> String {
    let df = DateFormatter()
    df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy-MM-dd"
    return df.string(from: date)
}
private func dString(_ date: Date) -> String {
    let df = DateFormatter()
    df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "d"
    return df.string(from: date)
}
private func monthString(_ date: Date) -> String {
    let df = DateFormatter()
    df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy年M月"
    return df.string(from: date)
}
private func parseYMD(_ s: String) -> Date? {
    let df = DateFormatter()
    df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy-MM-dd"
    return df.date(from: s)
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

// MARK: - Cells

final class HeaderMonthCell: UICollectionViewCell {
    static let reuse = "HeaderMonthCell"
    let label = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
}

final class HeaderDayCell: UICollectionViewCell {
    static let reuse = "HeaderDayCell"
    let label = UILabel()
    let wday = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        let stack = UIStackView(arrangedSubviews: [label, wday])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        wday.font = .systemFont(ofSize: 10); wday.textColor = .secondaryLabel
        label.textAlignment = .center; wday.textAlignment = .center
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        contentView.backgroundColor = .systemGray6
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
}

final class RowTitleCell: UICollectionViewCell {
    static let reuse = "RowTitleCell"
    let label = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
}

final class RowEditCell: UICollectionViewCell {
    static let reuse = "RowEditCell"
    let button = UIButton(type: .system)
    var onTap: (() -> Void)?
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        button.setTitle("編集", for: .normal)
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
    @objc private func tap() { onTap?() }
}

final class DayStateCell: UICollectionViewCell {
    static let reuse = "DayStateCell"
    override var isSelected: Bool {
        didSet { layer.borderColor = (isSelected ? UIColor.systemRed : UIColor.separator).cgColor }
    }
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
    func configure(on: Bool, isToday: Bool) {
        contentView.backgroundColor = on ? UIColor.systemBlue.withAlphaComponent(0.25) : .systemBackground
        if isToday {
            // 今日列うっすら
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
        } else {
            contentView.layer.borderWidth = 0.5
            contentView.layer.borderColor = UIColor.separator.cgColor
        }
    }
}

// MARK: - Main VC

final class ViewController5: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // 設定（必要に応じてUserDefaultsへ格納）
    private var createdAt: Date = Date()
    private var goalEnd: Date = Date()

    private var days: [Date] = []
    private var koudouTitles: [String] = Array(repeating: "", count: Grid.maxRows) // index 0..23 -> koudou1..24

    // ヘッダー月のための現在列インデックス（item2=0列目とする）
    private var firstVisibleDayIndex: Int = 0

    // Segue Identifier（StoryboardのSegueにも同じIDを設定してください）
    private let segueToVC6 = "toVC6"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataFromUserDefaults()
        setupCollection()
    }

    private func setupDataFromUserDefaults() {
        let ud = UserDefaults.standard
        // 作成日が未設定なら今日を保存して採用
        if let s = ud.string(forKey: UDKey.createdAt), let d = parseYMD(s) { createdAt = d }
        else {
            createdAt = jpCal.startOfDay(for: Date())
            ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        }
        // 目標終了日は必須（未設定なら作成日と同じ日にしておく）
        if let s = ud.string(forKey: UDKey.goalEnd), let d = parseYMD(s) { goalEnd = d }
        else {
            goalEnd = createdAt
            ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
        }
        days = daysArray(from: createdAt, to: goalEnd)

        // koudou1..24
        for i in 1...Grid.maxRows {
            koudouTitles[i-1] = ud.string(forKey: UDKey.koudou(i)) ?? "koudou\(i)"
        }
    }

    private func setupCollection() {
        collectionView.dataSource = self
        collectionView.delegate = self

        // Register（StoryboardにPrototypeを置いていれば不要ですが、保険で二重登録OK）
        collectionView.register(HeaderMonthCell.self, forCellWithReuseIdentifier: HeaderMonthCell.reuse)
        collectionView.register(HeaderDayCell.self,   forCellWithReuseIdentifier: HeaderDayCell.reuse)
        collectionView.register(RowTitleCell.self,    forCellWithReuseIdentifier: RowTitleCell.reuse)
        collectionView.register(RowEditCell.self,     forCellWithReuseIdentifier: RowEditCell.reuse)
        collectionView.register(DayStateCell.self,    forCellWithReuseIdentifier: DayStateCell.reuse)

        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.isDirectionalLockEnabled = true
    }

    // index -> Date（ヘッダーの item 1 が days[0] に対応）
    private func dateForItem(_ item: Int) -> Date? {
        let dayIndex = item - 1 // item1 -> 0
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
        let newValue = !ud.bool(forKey: key)
        ud.set(newValue, forKey: key)
    }

    private func updateHeaderMonthIfNeeded() {
        // contentOffset.x から「現在の先頭日列（item1 に相当する列）」の days インデックスを推定
        let x = collectionView.contentOffset.x
        let threshold = Grid.titleWidth + Grid.editWidth
        var idx = 0
        if x > threshold {
            let dx = x - threshold
            idx = max(0, Int(round(dx / Grid.dayWidth)))
            idx = min(idx, max(0, days.count - 1))
        }
        if idx != firstVisibleDayIndex {
            firstVisibleDayIndex = idx
            // ヘッダーの月セルだけ更新
            let ip = IndexPath(item: 0, section: 0)
            collectionView.reloadItems(at: [ip])
        }
    }

    @objc private func goToVC6(rowIndex: Int) {
        // VC6 側が読みやすいように一時キーで渡す（あなたの指定どおり UserDefaults 運用）
        let ud = UserDefaults.standard
        ud.set(rowIndex, forKey: UDKey.currentRowIndex)
        ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
        performSegue(withIdentifier: segueToVC6, sender: nil)
    }
}

// MARK: - DataSource

extension ViewController5: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // セクション0: ヘッダー, セクション1..24: koudou 行
        return 1 + Grid.maxRows
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // item0(月) + item1...日付
            return 1 + days.count
        } else {
            // item0(行名) + item1(編集) + item2...日付ON/OFF
            return 2 + days.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            // ヘッダー行
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                let date = days[firstVisibleDayIndex]
                cell.label.text = monthString(date)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderDayCell.reuse, for: indexPath) as! HeaderDayCell
                let d = days[indexPath.item - 1]
                cell.label.text = dString(d)
                let wd = Calendar.current.component(.weekday, from: d) // 1=Sun
                cell.wday.text = ["日","月","火","水","木","金","土"][wd-1]
                cell.contentView.backgroundColor = Calendar.current.isDateInToday(d) ? UIColor.systemGray4 : UIColor.systemGray6
                return cell
            }
        } else {
            // データ行
            let rowIndex = indexPath.section // 1..24

            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RowTitleCell.reuse, for: indexPath) as! RowTitleCell
                cell.label.text = koudouTitles[rowIndex - 1]
                return cell
            } else if indexPath.item == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RowEditCell.reuse, for: indexPath) as! RowEditCell
                cell.onTap = { [weak self] in self?.goToVC6(rowIndex: rowIndex) }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayStateCell.reuse, for: indexPath) as! DayStateCell
                let d = days[indexPath.item - 2] // item2 -> days[0]
                let on = isOn(rowIndex: rowIndex, date: d)
                cell.configure(on: on, isToday: Calendar.current.isDateInToday(d))
                return cell
            }
        }
    }
}

// MARK: - Delegate (tap, scroll)

extension ViewController5: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // ヘッダーや編集セル以外のマスはトグル（ON/OFF）して即反映
        if indexPath.section >= 1, indexPath.item >= 2 {
            let rowIndex = indexPath.section
            let d = days[indexPath.item - 2]
            toggleOn(rowIndex: rowIndex, date: d)
            collectionView.reloadItems(at: [indexPath])
        } else if indexPath.section >= 1, indexPath.item == 1 {
            // 編集セルをタップ → VC6
            goToVC6(rowIndex: indexPath.section)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderMonthIfNeeded()
    }

    // セルサイズ（列ごとに幅を変える）
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            // ヘッダー
            let w: CGFloat = (indexPath.item == 0) ? (Grid.titleWidth + Grid.editWidth) : Grid.dayWidth
            let h: CGFloat = Grid.headerHeight
            return CGSize(width: w, height: h)
        } else {
            // データ行
            let w: CGFloat
            switch indexPath.item {
            case 0: w = Grid.titleWidth
            case 1: w = Grid.editWidth
            default: w = Grid.dayWidth
            }
            return CGSize(width: w, height: Grid.rowHeight)
        }
    }

    // 行間・列間0
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
}
