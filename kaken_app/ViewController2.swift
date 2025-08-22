//
//  ViewController2.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/22.
//

import UIKit

class ViewController2: UIViewController {

  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var nextButton: UIButton!



  override func viewDidLoad() {
    super.viewDidLoad()

    datePicker.datePickerMode = .date
    datePicker.locale = Locale(identifier: "ja_JP")
    datePicker.calendar = Calendar(identifier: .gregorian)
    if #available(iOS 13.4, *) {
        datePicker.preferredDatePickerStyle = .wheels
    }
    nextButton.layer.cornerRadius = 20

    nextButton.clipsToBounds = true
  }

  @IBAction func nextButtontapped(_ sender: UIButton) {
    let kikan = datePicker.date
    UserDefaults.standard.set(kikan, forKey: "kikan")
    print(kikan)
    performSegue(withIdentifier: "toViewController3", sender: nil)
  }

}
