import UIKit
import FSCalendar

final class ViewController6: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    // VC5 から受け取る
    var rowIndex: Int = 1
    var startDate: Date = Date() // きょう（0時）を受け取る
    var endDate: Date = Date()   // UDのgoalEndを受け取る

    private var calendar: FSCalendar!
    private var kikanDate: Date? // VC2で保存されたkikan日付

    // 8A: 直接UserDefaults（VC5とキーを揃える）
    private var jpCal: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        return cal
    }()
    private let jpLoc = Locale(identifier: "ja_JP")

    private func ymd(_ d: Date) -> String {
        let f = DateFormatter(); f.calendar = jpCal; f.locale = jpLoc
        f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }
    private func key(for date: Date) -> String { "onoff_\(rowIndex)_\(ymd(date))" }

    private func days(from a: Date, to b: Date) -> [Date] {
        var r:[Date]=[]; var cur = jpCal.startOfDay(for: a); let end = jpCal.startOfDay(for: b)
        while cur <= end { r.append(cur); cur = jpCal.date(byAdding: .day, value: 1, to: cur)! }
        return r
    }
    private func inRange(_ d: Date) -> Bool {
        let s = jpCal.startOfDay(for: startDate); let e = jpCal.startOfDay(for: endDate)
        let x = jpCal.startOfDay(for: d); return (x >= s && x <= e)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadKikanDate()
        setupCalendar()
        loadSavedSelections()
    }
    
    private func loadKikanDate() {
        // VC2で保存されたkikan日付を読み込む
        if let kikan = UserDefaults.standard.object(forKey: "kikan") as? Date {
            // 元の日付をそのまま使用（時刻は無視）
            kikanDate = kikan
            endDate = kikan
            print("Loaded kikan date: \(kikan)")
            print("Set kikanDate and endDate to: \(kikan)")
        } else {
            print("No kikan date found in UserDefaults")
        }
    }
    
    private func setupCalendar() {
        // 背景色をFFF7E7に設定
        view.backgroundColor = UIColor(red: 255/255.0, green: 247/255.0, blue: 231/255.0, alpha: 1.0)
        
        // FSCalendarをコードで作成
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendar)
        
        // Auto Layout設定
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendar.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // FSCalendar設定
        calendar.dataSource = self
        calendar.delegate = self
        calendar.locale = jpLoc
        calendar.allowsMultipleSelection = true
        
        // カレンダーの色設定（カスタム色）
        calendar.backgroundColor = UIColor(red: 255/255.0, green: 247/255.0, blue: 231/255.0, alpha: 1.0) // FFF7E7
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.todayColor = UIColor(red: 157/255.0, green: 133/255.0, blue: 99/255.0, alpha: 1.0) // 9D8563
        calendar.appearance.selectionColor = UIColor(red: 255/255.0, green: 143/255.0, blue: 124/255.0, alpha: 1.0) // FF8F7C
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .white
        
        // 表示開始月を合わせる
        calendar.setCurrentPage(startDate, animated: false)
        
        // デバッグ用
        if let kikan = kikanDate {
            print("setupCalendar: kikan date is \(kikan)")
        }
        
        // カレンダーの表示を強制更新
        DispatchQueue.main.async {
            self.calendar.reloadData()
        }
    }
    
    private func loadSavedSelections() {
        // 保存済みONを初期選択で復元
        let ud = UserDefaults.standard
        for d in days(from: startDate, to: endDate) {
            if ud.bool(forKey: key(for: d)) {
                calendar.select(d, scrollToDate: false)
            }
        }
        // カレンダーの表示を更新してkikan日付の色を反映
        DispatchQueue.main.async {
            self.calendar.reloadData()
        }
    }

    // 6A + 3B: タップ都度に即保存。範囲外は保存しない（選択は可）
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        guard inRange(date) else { return }
        UserDefaults.standard.set(true, forKey: key(for: date))
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at _: FSCalendarMonthPosition) {
        guard inRange(date) else { return }
        UserDefaults.standard.set(false, forKey: key(for: date))
    }
    
    // FSCalendarDelegate: 日付の色をカスタマイズ (複数のメソッドを試す)
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        print("fillDefaultColorFor called for date: \(date)")
        return getKikanColor(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        print("fillSelectionColorFor called for date: \(date)")
        return getKikanColor(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        print("eventDefaultColorsFor called for date: \(date)")
        if let color = getKikanColor(for: date) {
            return [color]
        }
        return nil
    }
    
    private func getKikanColor(for date: Date) -> UIColor? {
        if let kikan = kikanDate {
            // DateFormatterで日付文字列に変換して比較
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.calendar = jpCal
            
            let kikanString = formatter.string(from: kikan)
            let dateString = formatter.string(from: date)
            
            print("Comparing kikan: \(kikanString) with date: \(dateString)")
            if kikanString == dateString {
                print("*** MATCH! Highlighting kikan date: \(date)")
                return .systemOrange
            }
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if let kikan = kikanDate {
            // DateFormatterで日付文字列に変換して比較
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.calendar = jpCal
            
            let kikanString = formatter.string(from: kikan)
            let dateString = formatter.string(from: date)
            
            if kikanString == dateString {
                return .white
            }
        }
        return nil
    }
}
