//
//  ViewController1.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/08.
//

import UIKit
import UIKit

class ViewController1: UIViewController {

  @IBOutlet var textField: UITextField!

  @IBAction func nextButton(_ sender: UIButton) {
    var mokuhyou = textField.text ?? ""
    UserDefaults.standard.set(mokuhyou, forKey: "kikan")
    print(mokuhyou)
    performSegue(withIdentifier: "toViewController2", sender: nil)
  }

//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//  }
}
