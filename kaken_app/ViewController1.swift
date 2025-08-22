import UIKit

class ViewController1: UIViewController {

  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var nextButton: UIButton!   // ← ボタンのIBOutlet

  override func viewDidLoad() {
    super.viewDidLoad()

    textView.text = UserDefaults.standard.string(forKey: "mokuhyou") ?? ""

    nextButton.layer.cornerRadius = 20
    nextButton.clipsToBounds = true
  }

  @IBAction func nextButtonTapped(_ sender: UIButton) {  // ← 名前を変更
    let mokuhyou = textView.text ?? ""
    UserDefaults.standard.set(mokuhyou, forKey: "mokuhyou")
    print(mokuhyou)
    performSegue(withIdentifier: "toViewController2", sender: nil)
  }
}
