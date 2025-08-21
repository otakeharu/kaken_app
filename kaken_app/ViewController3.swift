//
//  ViewController3.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/22.
//

import UIKit

class ViewController3: UIViewController, UITextViewDelegate {

  @IBOutlet var mokuhyoulabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!

  @IBOutlet var textView1: UITextView!
  @IBOutlet var textView2: UITextView!
  @IBOutlet var textView3: UITextView!
  @IBOutlet var textView4: UITextView!
  @IBOutlet var textView5: UITextView!
  @IBOutlet var textView6: UITextView!
  @IBOutlet var textView7: UITextView!
  @IBOutlet var textView8: UITextView!

  @IBAction func saveButtontapped(){
    var youso1 = textView1.text ?? ""
    var youso2 = textView2.text ?? ""
    var youso3 = textView3.text ?? ""
    var youso4 = textView4.text ?? ""
    var youso5 = textView5.text ?? ""
    var youso6 = textView6.text ?? ""
    var youso7 = textView7.text ?? ""
    var youso8 = textView8.text ?? ""

    UserDefaults.standard.set(youso1, forKey: "youso1")
    UserDefaults.standard.set(youso2, forKey: "youso2")
    UserDefaults.standard.set(youso3, forKey: "youso3")
    UserDefaults.standard.set(youso4, forKey: "youso4")
    UserDefaults.standard.set(youso5, forKey: "youso5")
    UserDefaults.standard.set(youso6, forKey: "youso6")
    UserDefaults.standard.set(youso7, forKey: "youso7")
    UserDefaults.standard.set(youso8, forKey: "youso8")
    print(youso1,youso2,youso3,youso4,youso5,youso6,youso7,youso8)


  }
  @IBAction func nextButtontapped(_ sender: UIButton) {
    var youso1 = textView1.text ?? ""
    var youso2 = textView2.text ?? ""
    var youso3 = textView3.text ?? ""
    var youso4 = textView4.text ?? ""
    var youso5 = textView5.text ?? ""
    var youso6 = textView6.text ?? ""
    var youso7 = textView7.text ?? ""
    var youso8 = textView8.text ?? ""

    UserDefaults.standard.set(youso1, forKey: "youso1")
    UserDefaults.standard.set(youso2, forKey: "youso2")
    UserDefaults.standard.set(youso3, forKey: "youso3")
    UserDefaults.standard.set(youso4, forKey: "youso4")
    UserDefaults.standard.set(youso5, forKey: "youso5")
    UserDefaults.standard.set(youso6, forKey: "youso6")
    UserDefaults.standard.set(youso7, forKey: "youso7")
    UserDefaults.standard.set(youso8, forKey: "youso8")

    performSegue(withIdentifier: "toViewController4", sender: nil)

    print(youso1,youso2,youso3,youso4,youso5,youso6,youso7,youso8)

  }
    override func viewDidLoad() {
        super.viewDidLoad()
        mokuhyoulabel.text = UserDefaults.standard.string(forKey: "mokuhyou")
        
        textView1.delegate = self
        textView2.delegate = self
        textView3.delegate = self
        textView4.delegate = self
        textView5.delegate = self
        textView6.delegate = self
        textView7.delegate = self
        textView8.delegate = self
        
        textView1.text = UserDefaults.standard.string(forKey: "youso1") ?? ""
        textView2.text = UserDefaults.standard.string(forKey: "youso2") ?? ""
        textView3.text = UserDefaults.standard.string(forKey: "youso3") ?? ""
        textView4.text = UserDefaults.standard.string(forKey: "youso4") ?? ""
        textView5.text = UserDefaults.standard.string(forKey: "youso5") ?? ""
        textView6.text = UserDefaults.standard.string(forKey: "youso6") ?? ""
        textView7.text = UserDefaults.standard.string(forKey: "youso7") ?? ""
        textView8.text = UserDefaults.standard.string(forKey: "youso8") ?? ""

      nextButton.layer.cornerRadius = 15
      nextButton.clipsToBounds = true
      saveButton.layer.cornerRadius = 15
      saveButton.clipsToBounds = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case textView1:
            UserDefaults.standard.set(textView.text, forKey: "youso1")
        case textView2:
            UserDefaults.standard.set(textView.text, forKey: "youso2")
        case textView3:
            UserDefaults.standard.set(textView.text, forKey: "youso3")
        case textView4:
            UserDefaults.standard.set(textView.text, forKey: "youso4")
        case textView5:
            UserDefaults.standard.set(textView.text, forKey: "youso5")
        case textView6:
            UserDefaults.standard.set(textView.text, forKey: "youso6")
        case textView7:
            UserDefaults.standard.set(textView.text, forKey: "youso7")
        case textView8:
            UserDefaults.standard.set(textView.text, forKey: "youso8")
        default:
            break
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

}
