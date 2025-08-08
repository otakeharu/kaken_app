//
//  ViewController5.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/07.
//

import UIKit

// MARK: - Models

struct Row: Codable, Hashable {
    let id: UUID
    let title: String
}

struct Task: Codable, Hashable {
    let id: UUID
    let rowID: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let colorHex: String? // 例: "#FF3B30"
}

// MARK: - UserDefaults Store

enum GanttDefaultsKey {
    static let rows = "gantt.rows"
    static let tasks = "gantt.tasks"
    static let startDate = "gantt.startDate"
    static let visibleDays = "gantt.visibleDays"
}

final class GanttStore {
    static let shared = GanttStore()
    private init() {}

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // Load
    func loadRows() -> [Row] {
        guard let data = UserDefaults.standard.data(forKey: GanttDefaultsKey.rows),
              let rows = try? decoder.decode([Row].self, from: data) else { return [] }
        return rows
    }
    func loadTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: GanttDefaultsKey.tasks),
              let tasks = try? decoder.decode([Task].self, from: data) else { return [] }
        return tasks
    }
    func loadStartDate() -> Date? {
        // ISO8601で保存している前提／DateそのものでもOK
        if let data = UserDefaults.standard.data(forKey: GanttDefaultsKey.startDate),
           let d = try? decoder.decode(Date.self, from: data) {
            return d
        }
        // 互換: Double（timeIntervalSince1970）で入ってた場合
        if let t = UserDefaults.standard.object(forKey: GanttDefaultsKey.startDate) as? Double {
            return Date(timeIntervalSince1970: t)
        }
        return nil
    }
    func loadVisibleDays() -> Int {
        let v = UserDefaults.standard.integer(forKey: GanttDefaultsKey.visibleDays)
        return v > 0 ? v : 14
    }

    // Save（前の画面で使う）
    func save(rows: [Row]) {
        if let data = try? encoder.encode(rows) {
            UserDefaults.standard.set(data, forKey: GanttDefaultsKey.rows)
        }
    }
    func save(tasks: [Task]) {
        if let data = try? encoder.encode(tasks) {
            UserDefaults.standard.set(data, forKey: GanttDefaultsKey.tasks)
        }
    }
    func save(startDate: Date) {
        if let data = try? encoder.encode(startDate) {
            UserDefaults.standard.set(data, forKey: GanttDefaultsKey.startDate)
        }
    }
    func save(visibleDays: Int) {
        UserDefaults.standard.set(visibleDays, forKey: GanttDefaultsKey.visibleDays)
    }

    // デモ用：何もなければサンプル投入（開発時の保険）
    func seedIfEmpty() {
        if loadRows().isEmpty || loadTasks().isEmpty || loadStartDate() == nil {
            let rows = (0..<10).map { Row(id: UUID(), title: "行\($0+1)") }
            let start = Calendar.current.startOfDay(for: Date())
            let tasks: [Task] = [
                Task(id: UUID(), rowID: rows[0].id, title: "A", startDate: start.addingDays(1), endDate: start.addingDays(3), colorHex: "#FF3B30"),
                Task(id: UUID(), rowID: rows[3].id, title: "B", startDate: start.addingDays(5), endDate: start.addingDays(7), colorHex: "#34C759"),
                Task(id: UUID(), rowID: rows[6].id, title: "C", startDate: start.addingDays(8), endDate: start.addingDays(9), colorHex: "#007AFF"),
            ]
            save(rows: rows)
            save(tasks: tasks)
            save(startDate: start)
            save(visibleDays: 14)
        }
    }
}

// MARK: - Cells (StoryboardのPrototypeにClass/IDを設定)

final class HeaderCell: UICollectionViewCell {
    static let reuseID = "HeaderCell"
    let title = UILabel()
    let sub = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.textAlignment = .center
        sub.font = .systemFont(ofSize: 10)
        sub.textAlignment = .center
        sub.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [title, sub])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 2
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.backgroundColor = .systemGray6
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
}

final class SidebarCell: UICollectionViewCell {
    static let reuseID = "SidebarCell"
    let label = UILabel()
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
}

final class GridCell: UICollectionViewCell {
    static let reuseID = "GridCell"
    let bar = UIView()
    let title = UILabel()
    override var isSelected: Bool {
        didSet { contentView.layer.borderColor = (isSelected ? UIColor.systemRed : UIColor.separator).cgColor }
    }
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        bar.layer.cornerRadius = 6
        bar.isHidden = true

        title.font = .systemFont(ofSize: 9, weight: .medium)
        title.textColor = .white
        title.textAlignment = .center
        title.isHidden = true

        contentView.addSubview(bar)
        contentView.addSubview(title)
        bar.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            bar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            bar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bar.heightAnchor.constraint(equalToConstant: 14),

            title.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 2),
            title.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -2),
            title.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])
    }
    func configure(showBar: Bool, color: UIColor?, text: String?) {
        bar.isHidden = !showBar
        title.isHidden = !showBar
        if showBar {
            bar.backgroundColor = color ?? .systemBlue
            title.text = text
        }
    }
}

// MARK: - ViewController

final class ViewController5: UIViewController {

    // Storyboard Outlets
    @IBOutlet weak var headerCV: UICollectionView!
    @IBOutlet weak var sidebarCV: UICollectionView!
    @IBOutlet weak var gridCV: UICollectionView!

    // Layout constants（StoryboardのItem Sizeと揃える）
    private let sidebarWidth: CGFloat = 64
    private let headerHeight: CGFloat = 56
    private let cellWidth: CGFloat = 64
    private let cellHeight: CGFloat = 56

    // Data
    private var rows: [Row] = []
    private var tasks: [Task] = []
    private var startDate: Date = Calendar.current.startOfDay(for: Date())
    private var visibleDays: Int = 14
    private var days: [Date] = []

    private var calendar = Calendar(identifier: .gregorian)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ガント"
        calendar.locale = Locale(identifier: "ja_JP")

        // データロード（無ければシード）
        GanttStore.shared.seedIfEmpty()
        reloadFromDefaults()

        // CollectionViewセット（Storyboard接続でもOK）
        [headerCV, sidebarCV, gridCV].forEach {
            $0?.dataSource = self
            $0?.delegate = self
        }

        // FlowLayout（Storyboard設定を最終確認）
        if let l = headerCV.collectionViewLayout as? UICollectionViewFlowLayout {
            l.scrollDirection = .horizontal
            l.minimumInteritemSpacing = 0; l.minimumLineSpacing = 0
            l.itemSize = CGSize(width: cellWidth, height: headerHeight)
        }
        if let l = sidebarCV.collectionViewLayout as? UICollectionViewFlowLayout {
            l.scrollDirection = .vertical
            l.minimumInteritemSpacing = 0; l.minimumLineSpacing = 0
            l.itemSize = CGSize(width: sidebarWidth, height: cellHeight)
        }
        if let l = gridCV.collectionViewLayout as? UICollectionViewFlowLayout {
            l.scrollDirection = .vertical
            l.minimumInteritemSpacing = 0; l.minimumLineSpacing = 0
            l.itemSize = CGSize(width: cellWidth, height: cellHeight)
        }
        gridCV.isDirectionalLockEnabled = true

        // 初期表示位置：今日が見えるように（範囲内なら）
        if let todayIdx = days.firstIndex(where: { Calendar.current.isDateInToday($0) }) {
            let indexPath = IndexPath(item: todayIdx, section: 0)
            headerCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            // gridは横だけ合わせる
            gridCV.contentOffset.x = headerCV.contentOffset.x
        }
    }

    private func reloadFromDefaults() {
        rows = GanttStore.shared.loadRows()
        tasks = GanttStore.shared.loadTasks()
        startDate = GanttStore.shared.loadStartDate() ?? Calendar.current.startOfDay(for: Date())
        visibleDays = GanttStore.shared.loadVisibleDays()

        days = (0..<visibleDays).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }

        headerCV?.reloadData()
        sidebarCV?.reloadData()
        gridCV?.reloadData()
    }
}

// MARK: - DataSource

extension ViewController5: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case headerCV: return 1
        case sidebarCV, gridCV: return rows.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case headerCV: return days.count
        case sidebarCV: return 1
        case gridCV: return days.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView === headerCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.reuseID, for: indexPath) as! HeaderCell
            let d = days[indexPath.item]
            cell.title.text = DateFormatter.g_day.string(from: d)
            cell.sub.text = DateFormatter.g_weekday.string(from: d)
            cell.contentView.backgroundColor = Calendar.current.isDateInToday(d) ? .systemGray4 : .systemGray6
            return cell

        } else if collectionView === sidebarCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SidebarCell.reuseID, for: indexPath) as! SidebarCell
            cell.label.text = rows[indexPath.section].title
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseID, for: indexPath) as! GridCell
            let row = rows[indexPath.section]
            let day = days[indexPath.item]

            // その行で、その日が「タスク期間内」に含まれるタスクがあるか判定
            if let task = tasks.first(where: { $0.rowID == row.id && day.isBetween($0.startDate, $0.endDate, by: calendar) }) {
                let color = UIColor(hex: task.colorHex) ?? .systemBlue
                // 期間の途中ならタイトルは省略、開始日のセルだけ表示する等のルールもOK
                let showTitle = calendar.isDate(day, inSameDayAs: task.startDate)
                cell.configure(showBar: true, color: color, text: showTitle ? task.title : nil)
            } else {
                cell.configure(showBar: false, color: nil, text: nil)
            }
            return cell
        }
    }
}

// MARK: - Delegate & Scroll Sync

extension ViewController5: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === gridCV {
            let row = rows[indexPath.section].title
            let d = days[indexPath.item]
            let title = "\(row) - \(DateFormatter.g_ymd.string(from: d))"
            let alert = UIAlertController(title: title, message: "ここで詳細へ遷移などを実装します。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // スクロール同期（中央が司令塔）
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === gridCV {
            headerCV.contentOffset.x = gridCV.contentOffset.x
            sidebarCV.contentOffset.y = gridCV.contentOffset.y
        } else if scrollView === headerCV {
            gridCV.contentOffset.x = headerCV.contentOffset.x
        } else if scrollView === sidebarCV {
            gridCV.contentOffset.y = sidebarCV.contentOffset.y
        }
    }
}

// MARK: - Helpers

private extension Date {
    func startOfDay(_ cal: Calendar) -> Date { cal.startOfDay(for: self) }
    func addingDays(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: n, to: self)! }
    func isBetween(_ a: Date, _ b: Date, by cal: Calendar) -> Bool {
        let d = cal.startOfDay(for: self)
        let sa = cal.startOfDay(for: a)
        let sb = cal.startOfDay(for: b)
        return (sa ... sb).contains(d)
    }
}

private extension UIColor {
    convenience init?(hex: String?) {
        guard let hex, hex.hasPrefix("#") else { return nil }
        let s = String(hex.dropFirst())
        var v: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&v) else { return nil }
        switch s.count {
        case 6:
            self.init(red: CGFloat((v >> 16) & 0xFF)/255.0,
                      green: CGFloat((v >> 8) & 0xFF)/255.0,
                      blue: CGFloat(v & 0xFF)/255.0,
                      alpha: 1.0)
        case 8:
            self.init(red: CGFloat((v >> 24) & 0xFF)/255.0,
                      green: CGFloat((v >> 16) & 0xFF)/255.0,
                      blue: CGFloat((v >> 8) & 0xFF)/255.0,
                      alpha: CGFloat(v & 0xFF)/255.0)
        default:
            return nil
        }
    }
}

private extension DateFormatter {
    static let g_day: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "d"
        return df
    }()
    static let g_weekday: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "E"
        return df
    }()
    static let g_ymd: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy/MM/dd (E)"
        return df
    }()
}

