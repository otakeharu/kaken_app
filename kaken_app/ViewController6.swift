//
//  ViewController6.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/08.
//

import FSCalendar

class ViewController6: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
  @IBOutlet weak var calendar: FSCalendar!

  override func viewDidLoad() {
      super.viewDidLoad()

    guard let calendar = calendar else {
        print("Calendar outlet not connected")
        return
    }

      calendar.delegate = self
      calendar.dataSource = self

      // 見た目の設定
      calendar.appearance.todayColor = UIColor.blue
      calendar.appearance.selectionColor = UIColor.red
      calendar.appearance.weekdayTextColor = UIColor.black
      calendar.appearance.headerTitleColor = UIColor.black


  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
