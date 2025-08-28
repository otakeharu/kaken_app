import UIKit

// MARK: - Constants（Storyboardの数値と一致）
private enum Grid {
    static let titleWidth: CGFloat   = 160
    static let editWidth: CGFloat    = 40
    static let dayWidth: CGFloat     = 44
    static let rowHeight: CGFloat    = 44
    static let headerHeight: CGFloat = 44
    static let lineWidth: CGFloat    = 1.0 / UIScreen.main.scale
    static let maxRows               = 24
}

private func pixelAlign(_ x: CGFloat) -> CGFloat {
    let s = UIScreen.main.scale
    return (x * s).rounded() / s
}

// MARK: - Date utils（VC内で完結させる）
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
private func daysArray(from start: Date, to end: Date) -> [Date] {
    var arr: [Date] = []; var cur = jpCal.startOfDay(for: start); let endDay = jpCal.startOfDay(for: end)
    while cur <= endDay { arr.append(cur); cur = jpCal.date(byAdding: .day, value: 1, to: cur)! }
    return arr
}

// MARK: - UserDefaults keys
private enum UDKey {
    static let createdAt   = "gantt.createdAt"
    static let goalEnd     = "gantt.goalEnd"

    // 例: (row=1, col=3) -> "koudou13"
    static func koudou(row: Int, col: Int) -> String { "koudou\(row)\(col)" }

    static func onoff(row: Int, date: String) -> String { "onoff_\(row)_\(date)" }

}

// MARK: - 右本体セル（Storyboard プロトタイプでもOK）
final class DayStateCell: UICollectionViewCell {
    func configure(on: Bool) {
        contentView.layer.borderWidth = Grid.lineWidth
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.backgroundColor = on ? UIColor.systemBlue.withAlphaComponent(0.25) : .systemBackground
    }
}

// MARK: - ViewController
final class ViewController5: UIViewController {

    // Storyboard Outlets（忘れず接続）
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var headerDaysCV: UICollectionView!
    @IBOutlet weak var fixedLeftCV: UICollectionView!
    @IBOutlet weak var hScrollView: UIScrollView!
    @IBOutlet weak var mainCV: UICollectionView!
    @IBOutlet weak var collectionWidth: NSLayoutConstraint! // MainCV の Width=Constant

    // Data
    private var createdAt = Date()
    private var goalEnd   = Date()
    private var days: [Date] = []
    private var titles: [String] = Array(repeating: "", count: Grid.maxRows)
    private var firstVisibleDayIndex = 0

    private var leftFixedWidth: CGFloat { Grid.titleWidth + Grid.editWidth }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataFromUserDefaults()
        setupViews()
        updateContentWidth()
        updateMonthLabel()
        syncHeaderToHorizontal()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentWidth()
    }

    // MARK: - Setup
    private func setupDataFromUserDefaults() {
        let ud = UserDefaults.standard

        if let s = ud.string(forKey: UDKey.createdAt),
           let d = DateFormatter.cached("yyyy-MM-dd", cal: jpCal, loc: jpLocale).date(from: s) {
            createdAt = d
        } else {
            createdAt = jpCal.startOfDay(for: Date())
            ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        }

        if let s = ud.string(forKey: UDKey.goalEnd),
           let d = DateFormatter.cached("yyyy-MM-dd", cal: jpCal, loc: jpLocale).date(from: s) {
            goalEnd = d
        } else {
            goalEnd = createdAt
            ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
        }

        // 表示範囲を開始月の月初〜月末に最低保証
        let startMonth = monthStart(of: createdAt)
        let endMonth   = monthEnd(of: createdAt)
        createdAt = startMonth
        goalEnd   = max(goalEnd, endMonth)
        ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
        ud.set(ymdString(goalEnd),   forKey: UDKey.goalEnd)

        days = daysArray(from: createdAt, to: goalEnd)
        if days.isEmpty {
            goalEnd = monthEnd(of: createdAt)
            days = daysArray(from: createdAt, to: goalEnd)
        }

      for rowIndex in 1...Grid.maxRows { // 1..24
          let (row, col) = elementRowAndCol(forRowIndex: rowIndex)
          let key = UDKey.koudou(row: row, col: col) // "koudou11" .. "koudou84"
          titles[rowIndex - 1] = ud.string(forKey: key) ?? key


        }
    }

    private func setupViews() {
        // Scroll behaviors
        hScrollView.delegate = self
        hScrollView.alwaysBounceHorizontal = true
        hScrollView.alwaysBounceVertical = false
        hScrollView.isDirectionalLockEnabled = true
        if #available(iOS 11.0, *) { hScrollView.contentInsetAdjustmentBehavior = .never }

        // CollectionViews
        headerDaysCV.dataSource = self; headerDaysCV.delegate = self
        fixedLeftCV.dataSource  = self; fixedLeftCV.delegate  = self
        mainCV.dataSource       = self; mainCV.delegate       = self

        // XIBセルの登録（Prototype=0 想定）
        headerDaysCV.register(UINib(nibName: "HeaderDayCell", bundle: nil),
                              forCellWithReuseIdentifier: "HeaderDayCell")
        fixedLeftCV.register(UINib(nibName: "RowTitleCell", bundle: nil),
                             forCellWithReuseIdentifier: "RowTitleCell")
        fixedLeftCV.register(UINib(nibName: "RowEditCell", bundle: nil),
                             forCellWithReuseIdentifier: "RowEditCell")
        // MainCV は Storyboard のプロトタイプを使うなら register 不要
        // もしプロトタイプを使わないなら↓を有効化
        // mainCV.register(DayStateCell.self, forCellWithReuseIdentifier: "DayStateCell")

        // Flow 設定（ズレ防止）
        if let fl = headerDaysCV.collectionViewLayout as? UICollectionViewFlowLayout {
            fl.scrollDirection = .horizontal
            fl.minimumLineSpacing = 0; fl.minimumInteritemSpacing = 0
            fl.itemSize = CGSize(width: Grid.dayWidth, height: Grid.headerHeight)
            fl.estimatedItemSize = .zero
        }
        if let fl = fixedLeftCV.collectionViewLayout as? UICollectionViewFlowLayout {
            fl.scrollDirection = .vertical
            fl.minimumLineSpacing = 0; fl.minimumInteritemSpacing = 0
            fl.estimatedItemSize = .zero
        }
        if let fl = mainCV.collectionViewLayout as? UICollectionViewFlowLayout {
            fl.scrollDirection = .vertical
            fl.minimumLineSpacing = 0; fl.minimumInteritemSpacing = 0
            fl.itemSize = CGSize(width: Grid.dayWidth, height: Grid.rowHeight)
            fl.estimatedItemSize = .zero
            if #available(iOS 11.0, *) { fl.sectionInsetReference = .fromContentInset }
        }

        // ヘッダー高さぶんだけ中身を下げる（重なり防止）
        mainCV.contentInset.top += Grid.headerHeight
        mainCV.verticalScrollIndicatorInsets.top += Grid.headerHeight
        fixedLeftCV.contentInset.top += Grid.headerHeight
        fixedLeftCV.verticalScrollIndicatorInsets.top += Grid.headerHeight
    }

    // MARK: - Width & Header
    private func updateContentWidth() {
        // 右側の合計幅 = 左固定幅 + 日数 * dayWidth
        let raw = leftFixedWidth + CGFloat(days.count) * Grid.dayWidth
        collectionWidth.constant = pixelAlign(raw)
        view.layoutIfNeeded()
    }

    private func updateMonthLabel() {
        guard !days.isEmpty else { monthLabel.text = ""; return }
        let idx = max(0, min(days.count - 1, firstVisibleDayIndex))
        monthLabel.text = monthString(days[idx])
    }

    private func syncHeaderToHorizontal() {
        let x = max(0, hScrollView.contentOffset.x - leftFixedWidth)
        let syncedX = pixelAlign(x)
        if headerDaysCV.contentOffset.x != syncedX {
            headerDaysCV.setContentOffset(CGPoint(x: syncedX, y: 0), animated: false)
        }
        let dayIndex = Int(round(syncedX / Grid.dayWidth))
        if dayIndex != firstVisibleDayIndex {
            firstVisibleDayIndex = max(0, min(days.count - 1, dayIndex))
            updateMonthLabel()
        }
    }

    private func appendNextMonthIfNeeded() {
        // 右端近くで翌月列を自動追加（任意）
        let rightEdge = hScrollView.contentOffset.x + hScrollView.bounds.width
        let threshold = max(0, hScrollView.contentSize.width - Grid.dayWidth * 7)
        guard rightEdge >= threshold, let last = days.last else { return }
        let nextMonthEnd = monthEnd(of: jpCal.date(byAdding: .month, value: 1, to: last)!)
        if nextMonthEnd <= goalEnd { return }

        let start = jpCal.date(byAdding: .day, value: 1, to: goalEnd)!
        let more  = daysArray(from: start, to: nextMonthEnd)
        guard !more.isEmpty else { return }
        days.append(contentsOf: more)
        goalEnd = nextMonthEnd
        UserDefaults.standard.set(ymdString(goalEnd), forKey: UDKey.goalEnd)

        headerDaysCV.reloadData()
        mainCV.reloadData()
        updateContentWidth()
    }

    // MARK: - Toggle helper
    private func isOn(row: Int, date: Date) -> Bool {
        UserDefaults.standard.bool(forKey: UDKey.onoff(row: row, date: ymdString(date)))
    }
    private func toggle(row: Int, date: Date) {
        let ud = UserDefaults.standard
        let k = UDKey.onoff(row: row, date: ymdString(date))
        ud.set(!ud.bool(forKey: k), forKey: k)
    }
}

// MARK: - DataSource
extension ViewController5: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === headerDaysCV { return 1 }
        return Grid.maxRows
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView === headerDaysCV { return days.count }
        if collectionView === fixedLeftCV { return 2 } // [タイトル, 編集]
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView === headerDaysCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderDayCell", for: indexPath) as! HeaderDayCell
            let date = days[indexPath.item]
            cell.configure(dayText: dString(date), weekdayText: weekdaySymbolJP(for: date))
            return cell
        }

        if collectionView === fixedLeftCV {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowTitleCell", for: indexPath) as! RowTitleCell
                cell.configure(text: titles[indexPath.section])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowEditCell", for: indexPath) as! RowEditCell
                let rowIndex = indexPath.section + 1
                cell.onTap = { [weak self] in
                    print("Edit tapped row:", rowIndex)
                    self?.view.endEditing(true)
                }
                return cell
            }
        }

        // 右本体（日付マス）
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayStateCell", for: indexPath) as! DayStateCell
        let rowIndex = indexPath.section + 1
        let date = days[indexPath.item]
        cell.configure(on: isOn(row: rowIndex, date: date))
        return cell
    }
}

// MARK: - Delegate（サイズ・同期・タップ）
extension ViewController5: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === headerDaysCV {
            return CGSize(width: pixelAlign(Grid.dayWidth), height: pixelAlign(Grid.headerHeight))
        }
        if collectionView === fixedLeftCV {
            let w = (indexPath.item == 0) ? Grid.titleWidth : Grid.editWidth
            return CGSize(width: pixelAlign(w), height: pixelAlign(Grid.rowHeight))
        }
        return CGSize(width: pixelAlign(Grid.dayWidth), height: pixelAlign(Grid.rowHeight))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === headerDaysCV { return }
        if collectionView === fixedLeftCV { return } // 編集はボタンで

        let rowIndex = indexPath.section + 1
        let date = days[indexPath.item]
        toggle(row: rowIndex, date: date)
        collectionView.reloadItems(at: [indexPath])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === hScrollView {
            syncHeaderToHorizontal()
            appendNextMonthIfNeeded()
        } else if scrollView === mainCV {
            fixedLeftCV.contentOffset.y = mainCV.contentOffset.y
        } else if scrollView === fixedLeftCV {
            mainCV.contentOffset.y = fixedLeftCV.contentOffset.y
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

// MARK: - DateFormatter cache
private extension DateFormatter {
    static func cached(_ format: String, cal: Calendar, loc: Locale) -> DateFormatter {
        let df = DateFormatter(); df.calendar = cal; df.locale = loc; df.dateFormat = format; return df
    }
}

// MARK: - Helper
private func elementRowAndCol(forRowIndex rowIndex: Int) -> (row: Int, col: Int) {
    let row = (rowIndex - 1) / 4 + 1   // 1..8   （要素番号）
    let col = (rowIndex - 1) % 4 + 1   // 1..4   （その要素の第何行動）
    return (row, col)
}

