//
//  ViewController4.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/30.
//

import UIKit

class ViewController4: UIViewController, UITextViewDelegate {

  @IBOutlet var yousoLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
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

      let koudou = koudou(
        youso: youso,
        koudou1: UserDefaults.standard.string(forKey: "koudou\(i)1") ?? "",
        koudou2: UserDefaults.standard.string(forKey: "koudou\(i)2") ?? "",
        koudou3: UserDefaults.standard.string(forKey: "koudou\(i)3") ?? "",
        koudou4: UserDefaults.standard.string(forKey: "koudou\(i)4") ?? ""
      )
      koudouArray.append(koudou)
    }

    setUI()
    nextButton.layer.cornerRadius = 20
    nextButton.clipsToBounds = true
  }


  lazy var koudouArray: [koudou] = [
    koudou(youso: youso1,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso2,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso3,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso4,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso5,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso6,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso7,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),
    koudou(youso: youso8,
           koudou1: textView1?.text ?? "",
           koudou2: textView2?.text ?? "",
           koudou3: textView3?.text ?? "",
           koudou4: textView4?.text ?? ""),

  ]

  @IBAction func next() {
    savePage()
    if index < yousoArray.count - 1 {
      index += 1
      setUI()
    }
  }

  @IBAction func back() {
    savePage()
    if index > 0 {
      index -= 1
      setUI()
    }
  }

  func setUI() {
    yousoLabel.text = yousoArray[index]
    textView1.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)1") ?? ""
    textView2.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)2") ?? ""
    textView3.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)3") ?? ""
    textView4.text = UserDefaults.standard.string(forKey: "koudou\(index + 1)4") ?? ""

  }

  func savePage() {
    koudouArray[index].koudou1 = textView1.text ?? ""
    koudouArray[index].koudou2 = textView2.text ?? ""
    koudouArray[index].koudou3 = textView3.text ?? ""
    koudouArray[index].koudou4 = textView4.text ?? ""

    UserDefaults.standard.set(textView1.text ?? "", forKey: "koudou\(index + 1)1")
    UserDefaults.standard.set(textView2.text ?? "", forKey: "koudou\(index + 1)2")
    UserDefaults.standard.set(textView3.text ?? "", forKey: "koudou\(index + 1)3")
    UserDefaults.standard.set(textView4.text ?? "", forKey: "koudou\(index + 1)4")
  }

  func saveAll() {
    for i in 0..<koudouArray.count {
      let k = koudouArray[i]
      UserDefaults.standard.set(k.koudou1, forKey: "koudou\(i+1)1")
      UserDefaults.standard.set(k.koudou2, forKey: "koudou\(i+1)2")
      UserDefaults.standard.set(k.koudou3, forKey: "koudou\(i+1)3")
      UserDefaults.standard.set(k.koudou4, forKey: "koudou\(i+1)4")
    }
  }
  func printKoudou() {
      for i in 1...8 {
          for j in 1...4 {
              let key = "koudou\(i)\(j)"
              let value = UserDefaults.standard.string(forKey: key) ?? "（×）"
            print("koudou\(i)\(j)",value)
          }
      }
  }

  @IBAction func nextButtontapped(_ sender: UIButton) {
    savePage()
    saveAll()
    printKoudou()

    performSegue(withIdentifier: "toViewController5", sender: self)
  }

}
