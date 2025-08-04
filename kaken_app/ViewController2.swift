//
//  ViewController2.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/22.
//

import UIKit

class ViewController2: UIViewController {

  @IBOutlet var textField: UITextField!

  @IBAction func nextButton(_ sender: UIButton) {
    var kikan = textField.text ?? ""
    UserDefaults.standard.set(kikan, forKey: "kikan")
    print(kikan)
    performSegue(withIdentifier: "toViewController3", sender: nil)
  }

//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//  }
}
