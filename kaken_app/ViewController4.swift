//
//  ViewController4.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/30.
//

import UIKit

class ViewController4: UIViewController {
  
  @IBOutlet var yousoLabel: UILabel!

  var index: Int = 0




  var koudouArray: [koudou] = [
    koudou(youso: UserDefaults.standard.string(forKey: "youso1") ?? "", koudou1: <#T##String#>, koudou2: <#T##String#>, koudou3: <#T##String#>, koudou4: <#T##String#>)
  ]




    override func viewDidLoad() {
        super.viewDidLoad()
    }
  func setUI() {




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
