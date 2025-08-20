//
//  ViewController6.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/08.
//
import UIKit
import FSCalendar

final class ViewController6: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewController6 viewDidLoad called")
        print("Calendar is nil: \(calendar == nil)")
        
        if calendar == nil {
            print("ERROR: Calendar outlet is not connected!")
            print("Check Storyboard IBOutlet connection")
            return
        }
        
        print("Calendar type: \(type(of: calendar!))")
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.locale = Locale(identifier: "ja_JP")
        
        print("Calendar setup completed")
    }

    // 例: 選択時の確認
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("selected:", date)
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


