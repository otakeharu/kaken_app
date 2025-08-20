
import UIKit

class ViewController1: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!   // ← Storyboardでボタンをここに接続

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewController1 loaded")
        print("nextButton is nil: \(nextButton == nil)")
        print("textField is nil: \(textField == nil)")
        
        nextButton?.layer.cornerRadius = 10
    }

    @IBAction func nextButton(_ sender: UIButton) {
        let mokuhyou = textField.text ?? ""
        UserDefaults.standard.set(mokuhyou, forKey: "mokuhyou")
        print(mokuhyou)
        performSegue(withIdentifier: "toViewController2", sender: nil)
    }
}
