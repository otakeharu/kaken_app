import UIKit
import FSCalendar

final class ViewController6: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    // VC5 から受け取る
    var goalId: UUID?            // 目標ID
    var rowIndex: Int = 1
    var startDate: Date = Date() // きょう（0時）を受け取る
    var endDate: Date = Date()   // UDのgoalEndを受け取る
    
    private let goalManager = GoalManager.shared
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // VC5に戻る時に変更を通知
        NotificationCenter.default.post(name: NSNotification.Name("CalendarDataChanged"), object: nil)
    }
    
    private func loadKikanDate() {
        guard let goalId = self.goalId else { return }
        
        // VC2で保存されたkikan日付を読み込む
        if let kikan = goalManager.getGoalData(forKey: "kikan", goalId: goalId) as? Date {
            // 元の日付をそのまま使用（時刻は無視）
            kikanDate = kikan
            endDate = kikan
            print("Loaded kikan date: \(kikan)")
            print("Set kikanDate and endDate to: \(kikan)")
        } else {
            print("No kikan date found for goal \(goalId.uuidString)")
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
        calendar.allowsSelection = true
        calendar.swipeToChooseGesture.isEnabled = false // スワイプ選択を無効化してタップを確実に
        
        // カスタムセルを登録
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        
        // カレンダーの色設定（カスタム色）
        calendar.backgroundColor = UIColor(red: 255/255.0, green: 247/255.0, blue: 231/255.0, alpha: 1.0) // FFF7E7
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.todayColor = UIColor(red: 157/255.0, green: 133/255.0, blue: 99/255.0, alpha: 1.0) // 9D8563
        calendar.appearance.selectionColor = UIColor(red: 255/255.0, green: 143/255.0, blue: 124/255.0, alpha: 1.0) // FF8F7C（通常の選択色に戻す）
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.titleTodayColor = .white
        
        // 表示開始月を合わせる
        calendar.setCurrentPage(startDate, animated: false)
        
        // タップジェスチャーは削除（FSCalendarの標準機能を使用）
        
        // デバッグ用
        if let kikan = kikanDate {
            print("setupCalendar: kikan date is \(kikan)")
        }
        
        // カレンダーの表示を強制更新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.calendar.reloadData()
            // endDateにスクロール（ハイライト確認のため）
            self.calendar.setCurrentPage(self.endDate, animated: false)
            print("Calendar reloaded and scrolled to endDate: \(self.endDate)")
        }
    }
    
    private func loadSavedSelections() {
        guard let goalId = self.goalId else { return }
        
        // 保存済みONを初期選択で復元
        for d in days(from: startDate, to: endDate) {
            let isOn = goalManager.getGoalData(forKey: key(for: d), goalId: goalId, defaultValue: false)
            if isOn {
                calendar.select(d, scrollToDate: false)
            }
        }
        
        // endDateも選択状態にして色を表示
        calendar.select(endDate, scrollToDate: false)
        
        // カレンダーの表示を更新してkikan日付の色を反映
        DispatchQueue.main.async {
            self.calendar.reloadData()
        }
    }

    // タップ許可
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        print("shouldSelect called for date: \(date)")
        return true
    }
    
    // デザレクト許可（重要：これでendDateのタップを検出）
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        print("shouldDeselect called for date: \(date)")
        
        // endDateの場合は、デザレクトを許可せず、代わりに状態を切り替え
        if jpCal.isDate(date, inSameDayAs: endDate) {
            print("endDate deselect attempt - handling as toggle")
            guard let goalId = self.goalId else { return false }
            let currentState = goalManager.getGoalData(forKey: key(for: date), goalId: goalId, defaultValue: false)
            goalManager.setGoalData(!currentState, forKey: key(for: date), goalId: goalId)
            print("endDate state changed to: \(!currentState)")
            
            DispatchQueue.main.async {
                // 選択状態を強制的に更新して色を変更
                print("Forcing selection update...")
                self.calendar.deselect(self.endDate)
                self.calendar.select(self.endDate, scrollToDate: false)
                print("Selection updated")
            }
            
            return false // デザレクトは実際には行わない
        }
        
        return true
    }
    
    // 6A + 3B: タップ都度に即保存。範囲外は保存しない（選択は可）
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        print("didSelect called for date: \(date)")
        guard inRange(date) else { return }
        guard let goalId = self.goalId else { return }
        
        // endDateの場合は特別処理（ON/OFF切り替え）
        if jpCal.isDate(date, inSameDayAs: endDate) {
            let currentState = goalManager.getGoalData(forKey: key(for: date), goalId: goalId, defaultValue: false)
            goalManager.setGoalData(!currentState, forKey: key(for: date), goalId: goalId)
            print("endDate state changed to: \(!currentState)")
            // endDateは常に選択状態を維持し、色を更新
            DispatchQueue.main.async {
                // 一度デザレクトしてから再選択することで色の更新を強制
                self.calendar.deselect(self.endDate)
                self.calendar.select(self.endDate, scrollToDate: false)
            }
        } else {
            goalManager.setGoalData(true, forKey: key(for: date), goalId: goalId)
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at _: FSCalendarMonthPosition) {
        guard inRange(date) else { return }
        
        // endDateの場合は再選択して選択状態を維持
        if jpCal.isDate(date, inSameDayAs: endDate) {
            DispatchQueue.main.async {
                self.calendar.select(self.endDate, scrollToDate: false)
            }
        } else {
            guard let goalId = self.goalId else { return }
            goalManager.setGoalData(false, forKey: key(for: date), goalId: goalId)
        }
    }
    
    // FSCalendarDelegate: カスタムセルで色を設定
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.calendar = jpCal
        
        let endDateString = formatter.string(from: endDate)
        let dateString = formatter.string(from: date)
        
        print("fillSelectionColorFor called for date: \(dateString), endDate: \(endDateString)")
        
        if endDateString == dateString {
            guard let goalId = self.goalId else { return nil }
            let isOn = goalManager.getGoalData(forKey: key(for: date), goalId: goalId, defaultValue: false)
            print("endDate isOn: \(isOn), returning color")
            print("Returning 9D8563 for endDate (both ON and OFF)")
            return UIColor(red: 157/255.0, green: 133/255.0, blue: 99/255.0, alpha: 1.0) // 9D8563
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        // goalEndに印をつける（VC5のgoalEndを取得）
        if let goalEndString = UserDefaults.standard.string(forKey: "goalEnd") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.calendar = jpCal
            
            let dateString = formatter.string(from: date)
            
            if goalEndString == dateString {
                return UIColor(red: 157/255.0, green: 133/255.0, blue: 99/255.0, alpha: 0.5) // 9D8563 with 50% transparency
            }
        }
        return nil
    }
    
    
}
