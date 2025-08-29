import UIKit
import FSCalendar

final class ViewController6: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    // VC5 から受け取る
    var rowIndex: Int = 1
    var startDate: Date = Date() // きょう（0時）を受け取る
    var endDate: Date = Date()   // UDのgoalEndを受け取る

    @IBOutlet weak var calendar: FSCalendar!

    // 8A: 直接UserDefaults（VC5とキーを揃える）
    private let jpCal = Calendar(identifier: .gregorian)
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

        guard let calendar else {
            print("ERROR: FSCalendar outlet not connected.")
            return
        }

        // 1A: 複数日選択を許可
        calendar.dataSource = self
        calendar.delegate   = self
        calendar.locale     = jpLoc
        calendar.allowsMultipleSelection = true

        // 表示開始月を合わせる
        calendar.setCurrentPage(startDate, animated: false)

        // 2B: 保存済みONを初期選択で復元
        let ud = UserDefaults.standard
        for d in days(from: startDate, to: endDate) {
            if ud.bool(forKey: key(for: d)) {
                calendar.select(d, scrollToDate: false)
            }
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
}
