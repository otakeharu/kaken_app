//
//  ViewController.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/22.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var textField: UITextField!

  @IBAction func nextButton(_ sender: UIButton) {
    var mokuhyouText = textField.text ?? ""
    UserDefaults.standard.set(mokuhyouText, forKey: "mokuhyou")
    print(mokuhyouText)
    performSegue(withIdentifier: "toViewController2", sender: nil)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
  }

