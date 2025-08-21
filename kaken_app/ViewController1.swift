import UIKit

class ViewController1: UIViewController {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var nextButton: UIButton!   // ← ボタンのIBOutlet

  override func viewDidLoad() {
    super.viewDidLoad()

    textField.text = UserDefaults.standard.string(forKey: "mokuhyou") ?? ""

    nextButton.layer.cornerRadius = 15
    nextButton.clipsToBounds = true
  }

  @IBAction func nextButtonTapped(_ sender: UIButton) {  // ← 名前を変更
    let mokuhyou = textField.text ?? ""
    UserDefaults.standard.set(mokuhyou, forKey: "mokuhyou")
    print(mokuhyou)
    performSegue(withIdentifier: "toViewController2", sender: nil)
  }
}
