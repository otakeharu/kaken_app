//
//  ViewController4.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/30.
//

import UIKit

class ViewController4: UIViewController, UITextViewDelegate {

  @IBOutlet var textView1: UITextView!
  @IBOutlet var textView2: UITextView!
  @IBOutlet var textView3: UITextView!
  @IBOutlet var textView4: UITextView!

  @IBOutlet var yousoLabel: UILabel!

  var index: Int = 0

  @IBAction func nextButton(_ sender: UIButton) {
    let koudou11 = textView1.text ?? ""
    let koudou12 = textView2.text ?? ""
    let koudou13 = textView3.text ?? ""
    let koudou14 = textView4.text ?? ""
    let koudou21 = textView1.text ?? ""
    let koudou22 = textView2.text ?? ""
    let koudou23 = textView3.text ?? ""
    let koudou24 = textView4.text ?? ""
    UserDefaults.standard.set(koudou11, forKey: "koudou11")
    UserDefaults.standard.set(koudou12, forKey: "koudou12")
    UserDefaults.standard.set(koudou13, forKey: "koudou13")
    UserDefaults.standard.set(koudou14, forKey: "koudou14")
    UserDefaults.standard.set(koudou21, forKey: "koudou21")
    UserDefaults.standard.set(koudou22, forKey: "koudou22")
    UserDefaults.standard.set(koudou23, forKey: "koudou23")
    UserDefaults.standard.set(koudou24, forKey: "koudou24")

    performSegue(withIdentifier: "toViewController5", sender: nil)
  }



  lazy var koudouArray: [koudou] = [
    koudou(youso: UserDefaults.standard.string(forKey: "youso1") ?? "",
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: UserDefaults.standard.string(forKey: "youso2") ?? "",
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? "")
  ]

 @IBAction func next(){
    index += 1
    setUI()

  }
@IBAction func back(){    index -= 1
    setUI()

  }


  func setUI(){
    let current = koudouArray[index]
    textView1.text = UserDefaults.standard.string(forKey: "koudou11") ?? ""
    textView2.text = UserDefaults.standard.string(forKey: "koudou12") ?? ""
    textView3.text = UserDefaults.standard.string(forKey: "koudou13") ?? ""
    textView4.text = UserDefaults.standard.string(forKey: "koudou14") ?? ""


  }




  override func viewDidLoad() {
    super.viewDidLoad()
    

    setUI()

  }
}
