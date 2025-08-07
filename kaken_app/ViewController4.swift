//
//  ViewController4.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/30.
//

import UIKit

class ViewController4: UIViewController, UITextViewDelegate {

  @IBOutlet var yousoLabel: UILabel!
  @IBOutlet var textView1: UITextView!
  @IBOutlet var textView2: UITextView!
  @IBOutlet var textView3: UITextView!
  @IBOutlet var textView4: UITextView!

  let youso1 = UserDefaults.standard.string(forKey: "youso1") ?? ""
  let youso2 = UserDefaults.standard.string(forKey: "youso2") ?? ""
  let youso3 = UserDefaults.standard.string(forKey: "youso3") ?? ""
  let youso4 = UserDefaults.standard.string(forKey: "youso4") ?? ""
  let youso5 = UserDefaults.standard.string(forKey: "youso5") ?? ""
  let youso6 = UserDefaults.standard.string(forKey: "youso6") ?? ""
  let youso7 = UserDefaults.standard.string(forKey: "youso7") ?? ""
  let youso8 = UserDefaults.standard.string(forKey: "youso8") ?? ""

  var yousoArray: [String] = []
  var index: Int = 0


  override func viewDidLoad() {
    super.viewDidLoad()

    for i in 1...8 {
        let youso = UserDefaults.standard.string(forKey: "youso\(i)") ?? ""
        yousoArray.append(youso)
    }

    setUI()

  }


  lazy var koudouArray: [koudou] = [
    koudou(youso: youso1,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso2,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso3,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso4,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso5,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso6,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso7,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),
    koudou(youso: youso8,
           koudou1: textView1.text ?? "",
           koudou2: textView2.text ?? "",
           koudou3: textView3.text ?? "",
           koudou4: textView4.text ?? ""),

  ]

  @IBAction func next() {
      if index < yousoArray.count - 1 {
          index += 1
          setUI()
      }
  }

  @IBAction func back() {
      if index > 0 {
          index -= 1
          setUI()
      }
  }


  func setUI(){
    yousoLabel.text = yousoArray[index]
    textView1.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)1") ?? ""
    textView2.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)2") ?? ""
    textView3.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)3") ?? ""
    textView4.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)4") ?? ""

  }

  @IBAction func nextButton(_ sender: UIButton) {
    let koudou11 = textView1.text ?? ""
    let koudou12 = textView2.text ?? ""
    let koudou13 = textView3.text ?? ""
    let koudou14 = textView4.text ?? ""
    let koudou21 = textView1.text ?? ""
    let koudou22 = textView2.text ?? ""
    let koudou23 = textView3.text ?? ""
    let koudou24 = textView4.text ?? ""
    let koudou31 = textView1.text ?? ""
    let koudou32 = textView2.text ?? ""
    let koudou33 = textView3.text ?? ""
    let koudou34 = textView4.text ?? ""
    let koudou41 = textView1.text ?? ""
    let koudou42 = textView2.text ?? ""
    let koudou43 = textView3.text ?? ""
    let koudou44 = textView4.text ?? ""
    let koudou51 = textView1.text ?? ""
    let koudou52 = textView2.text ?? ""
    let koudou53 = textView3.text ?? ""
    let koudou54 = textView4.text ?? ""
    let koudou61 = textView1.text ?? ""
    let koudou62 = textView2.text ?? ""
    let koudou63 = textView3.text ?? ""
    let koudou64 = textView4.text ?? ""
    let koudou71 = textView1.text ?? ""
    let koudou72 = textView2.text ?? ""
    let koudou73 = textView3.text ?? ""
    let koudou74 = textView4.text ?? ""
    let koudou81 = textView1.text ?? ""
    let koudou82 = textView2.text ?? ""
    let koudou83 = textView3.text ?? ""
    let koudou84 = textView4.text ?? ""

    UserDefaults.standard.set(koudou11, forKey: "koudou11")
    UserDefaults.standard.set(koudou12, forKey: "koudou12")
    UserDefaults.standard.set(koudou13, forKey: "koudou13")
    UserDefaults.standard.set(koudou14, forKey: "koudou14")
    UserDefaults.standard.set(koudou21, forKey: "koudou21")
    UserDefaults.standard.set(koudou22, forKey: "koudou22")
    UserDefaults.standard.set(koudou23, forKey: "koudou23")
    UserDefaults.standard.set(koudou24, forKey: "koudou24")
    UserDefaults.standard.set(koudou31, forKey: "koudou31")
    UserDefaults.standard.set(koudou32, forKey: "koudou32")
    UserDefaults.standard.set(koudou33, forKey: "koudou33")
    UserDefaults.standard.set(koudou34, forKey: "koudou34")
    UserDefaults.standard.set(koudou41, forKey: "koudou41")
    UserDefaults.standard.set(koudou42, forKey: "koudou42")
    UserDefaults.standard.set(koudou43, forKey: "koudou43")
    UserDefaults.standard.set(koudou44, forKey: "koudou44")
    UserDefaults.standard.set(koudou51, forKey: "koudou51")
    UserDefaults.standard.set(koudou52, forKey: "koudou52")
    UserDefaults.standard.set(koudou53, forKey: "koudou53")
    UserDefaults.standard.set(koudou54, forKey: "koudou54")
    UserDefaults.standard.set(koudou61, forKey: "koudou61")
    UserDefaults.standard.set(koudou62, forKey: "koudou62")
    UserDefaults.standard.set(koudou63, forKey: "koudou63")
    UserDefaults.standard.set(koudou64, forKey: "koudou64")
    UserDefaults.standard.set(koudou71, forKey: "koudou71")
    UserDefaults.standard.set(koudou72, forKey: "koudou72")
    UserDefaults.standard.set(koudou73, forKey: "koudou73")
    UserDefaults.standard.set(koudou74, forKey: "koudou74")
    UserDefaults.standard.set(koudou81, forKey: "koudou81")
    UserDefaults.standard.set(koudou82, forKey: "koudou82")
    UserDefaults.standard.set(koudou83, forKey: "koudou83")
    UserDefaults.standard.set(koudou84, forKey: "koudou84")


    print(koudou11,koudou12,koudou13,koudou14)
    print(koudou21,koudou22,koudou23,koudou24)
    print(koudou31,koudou32,koudou33,koudou34)
    print(koudou41,koudou42,koudou43,koudou44)
    print(koudou51,koudou52,koudou53,koudou54)
    print(koudou61,koudou62,koudou63,koudou64)
    print(koudou71,koudou72,koudou73,koudou74)
    print(koudou81,koudou82,koudou83,koudou84)


    performSegue(withIdentifier: "toViewController5", sender: nil)
  }

}
