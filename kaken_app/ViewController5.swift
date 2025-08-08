//
//  ViewController5.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/07.
//

import UIKit

class ViewController5: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  @IBAction func nextButton(_ sender: UIButton) {

    performSegue(withIdentifier: "toViewController6", sender: nil)
  }

}
