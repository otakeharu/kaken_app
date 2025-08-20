import UIKit

// MARK: - Constants (列幅など)
private enum Grid {
    static let titleWidth: CGFloat = 120   // item0 行名
    static let editWidth: CGFloat  = 80    // item1 編集
    static let dayWidth: CGFloat   = 44    // item2以降 日付列
    static let rowHeight: CGFloat  = 44
    static let headerHeight: CGFloat = 44
    static let maxRows = 32                // 8×4=32 行
    // ✅ 枠線の基準（on/offボタンと同じ1ピクセル）
    static let lineWidth: CGFloat = 1.0 / UIScreen.main.scale
}

// MARK: - UserDefaults Keys
private enum UDKey {
    static let createdAt   = "gantt.createdAt"   // "yyyy-MM-dd"
    static let goalEnd     = "gantt.goalEnd"     // "yyyy-MM-dd"
    static func koudou(rowGroup: Int, colInGroup: Int) -> String {
        "koudou\(rowGroup)\(colInGroup)" // rowGroup: 1...8, colInGroup: 1...4
    }
    static func onoff(rowIndex: Int, date: String) -> String { "onoff_\(rowIndex)_\(date)" }
    static let currentRowIndex = "vc6.currentRowIndex" // 1...32
}

// MARK: - Date utils
private let jpCal = Calendar(identifier: .gregorian)
private let jpLocale = Locale(identifier: "ja_JP")

private func ymdString(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "yyyy-MM-dd"; return df.string(from: date)
}
private func dString(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "d"; return df.string(from: date)
}
private func wdayShort(_ date: Date) -> String {
    let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
    df.dateFormat = "E"; return df.string(from: date)
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
private func endOfMonth(for date: Date) -> Date {
    let start = jpCal.date(from: jpCal.dateComponents([.year, .month], from: date))!
    let add = DateComponents(month: 1, day: -1)
    return jpCal.date(byAdding: add, to: start)!
}

// MARK: - Cells（全て contentView.layer に同じ線幅で枠）

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
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0
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
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0
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
        // ✅ on/offボタンと同じ線幅・同じ描画面（contentView.layer）
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0
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
        // ✅ on/offボタンと同じ枠線
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0
    }
    @objc private func tap() { onTap?() }
}

final class DayStateCell: UICollectionViewCell {
    static let reuse = "DayStateCell"

    // 枠線は contentView.layer に統一（他セルと同じ線幅）
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderColor = (isSelected ? UIColor.systemRed.cgColor
                                                        : UIColor.separator.cgColor)
        }
    }
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
    }
    func configure(on: Bool, isToday: Bool) {
        contentView.backgroundColor = on ? UIColor.systemBlue.withAlphaComponent(0.25) : .systemBackground
        if isToday {
            contentView.layer.borderWidth = Grid.lineWidth * 2   // 目立たせる（太さ2px）
            contentView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
        } else {
            contentView.layer.borderWidth = Grid.lineWidth
            contentView.layer.borderColor = UIColor.separator.cgColor
        }
    }
}

// MARK: - Main VC

final class ViewController5: UIViewController,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout {

    // 先頭2行はヘッダー(月・日付)、以降が32行のkoudou行
    private enum GridRowKind {
        case monthHeader    // 行0
        case dayHeader      // 行1
        case body(row: Int) // 行2...33（0始まりで2〜）
    }

    @IBOutlet weak var collectionView: UICollectionView!

    private var createdAt: Date = Date()
    private var goalEnd: Date = Date()

    private var days: [Date] = []
    private var koudouTitles: [String] = Array(repeating: "", count: Grid.maxRows)

    private let headerRows = 2
    private var columns: Int { 2 + days.count } // [タイトル][編集][日付xN]
    private var rows: Int { headerRows + Grid.maxRows }

    private let segueToVC6 = "toVC6"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataFromUserDefaults()
        setupCollection()
    }

    // MARK: - Data
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
            goalEnd = endOfMonth(for: createdAt)      // 未設定なら月末まで表示
            ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
        }
        days = daysArray(from: createdAt, to: goalEnd)

        var idx = 0
        for group in 1...8 {
            for col in 1...4 {
                let key = UDKey.koudou(rowGroup: group, colInGroup: col)
                koudouTitles[idx] = ud.string(forKey: key) ?? key
                idx += 1
            }
        }
    }

    // MARK: - CollectionView
    private func setupCollection() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(HeaderMonthCell.self, forCellWithReuseIdentifier: HeaderMonthCell.reuse)
        collectionView.register(HeaderDayCell.self,   forCellWithReuseIdentifier: HeaderDayCell.reuse)
        collectionView.register(RowTitleCell.self,    forCellWithReuseIdentifier: RowTitleCell.reuse)
        collectionView.register(RowEditCell.self,     forCellWithReuseIdentifier: RowEditCell.reuse)
        collectionView.register(DayStateCell.self,    forCellWithReuseIdentifier: DayStateCell.reuse)

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
            flow.sectionInset = .zero
        }
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.isDirectionalLockEnabled = true
        collectionView.backgroundColor = .systemBackground
    }

    // index → (row, col)
    private func rc(_ item: Int) -> (r: Int, c: Int) {
        let r = item / columns
        let c = item % columns
        return (r, c)
    }

    // 行の種類
    private func kind(for r: Int) -> GridRowKind {
        if r == 0 { return .monthHeader }
        if r == 1 { return .dayHeader }
        return .body(row: r - headerRows) // 0...31
    }

    // item→日付
    private func dateForCol(_ col: Int) -> Date? {
        let dayIndex = col - 2 // col2 -> days[0]
        guard dayIndex >= 0 && dayIndex < days.count else { return nil }
        return days[dayIndex]
    }

    private func isOn(rowIndex: Int, date: Date) -> Bool {
        let key = UDKey.onoff(rowIndex: rowIndex, date: ymdString(date))
        return UserDefaults.standard.bool(forKey: key)
    }

    private func toggleOn(rowIndex: Int, date: Date) {
        let ud = UserDefaults.standard
        let key = UDKey.onoff(rowIndex: rowIndex, date: ymdString(date))
        let newValue = !ud.bool(forKey: key)
        ud.set(newValue, forKey: key)
    }

    // MARK: - DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rows * columns
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (r, c) = rc(indexPath.item)
        switch kind(for: r) {
        case .monthHeader:
            if c == 0 {
                // 左上「行名」ヘッダー（空ラベルでも枠あり）
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                cell.label.text = "項目"
                return cell
            } else if c == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                cell.label.text = "編集"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                if let d = dateForCol(c) {
                    // 月初だけ月名を表示、それ以外は空（でも枠は描く）
                    let day = jpCal.component(.day, from: d)
                    cell.label.text = (day == 1) ? monthString(d) : ""
                } else {
                    cell.label.text = ""
                }
                return cell
            }

        case .dayHeader:
            if c == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                cell.label.text = "行名"
                return cell
            } else if c == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderMonthCell.reuse, for: indexPath) as! HeaderMonthCell
                cell.label.text = "—"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderDayCell.reuse, for: indexPath) as! HeaderDayCell
                if let d = dateForCol(c) {
                    cell.label.text = dString(d)
                    cell.wday.text = wdayShort(d)
                } else {
                    cell.label.text = ""
                    cell.wday.text = ""
                }
                return cell
            }

        case .body(let bodyRow): // 0...31
            if c == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RowTitleCell.reuse, for: indexPath) as! RowTitleCell
                cell.label.text = koudouTitles[bodyRow]
                return cell
            } else if c == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RowEditCell.reuse, for: indexPath) as! RowEditCell
                cell.onTap = { [weak self] in
                    guard let self = self else { return }
                    // ここで編集画面へ遷移など
                    // self.performSegue(withIdentifier: self.segueToVC6, sender: bodyRow)
                    print("Edit tapped row=\(bodyRow + 1)")
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayStateCell.reuse, for: indexPath) as! DayStateCell
                if let d = dateForCol(c) {
                    let on = isOn(rowIndex: bodyRow + 1, date: d)
                    let isToday = jpCal.isDateInToday(d)
                    cell.configure(on: on, isToday: isToday)
                }
                return cell
            }
        }
    }

    // MARK: - Delegate (toggle)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (r, c) = rc(indexPath.item)
        guard case .body(let bodyRow) = kind(for: r), c >= 2, let d = dateForCol(c) else { return }
        toggleOn(rowIndex: bodyRow + 1, date: d)
        collectionView.reloadItems(at: [indexPath])
    }

    // MARK: - FlowLayout sizes
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (r, c) = rc(indexPath.item)
        let height: CGFloat = (r < headerRows) ? Grid.headerHeight : Grid.rowHeight
        let width: CGFloat
        if c == 0 { width = Grid.titleWidth }
        else if c == 1 { width = Grid.editWidth }
        else { width = Grid.dayWidth } // ✅ on/offセル基準の正方形感
        return CGSize(width: width, height: height)
    }

    // MARK: - Optional: スクロール時などの月ヘッダ更新が必要ならここで
    private func updateHeaderMonthIfNeeded() {
        // 今回はセル側で月初のみ表示する実装のため空。必要なら可視範囲の先頭日付から月表示を更新する処理を書く。
    }
}
