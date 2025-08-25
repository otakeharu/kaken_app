



import UIKit

class rowEditCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!

    func configure(title: String) {
        button.setTitle(title, for: .normal)
    }

    @IBAction func tap(_ sender: UIButton) {
        print("編集ボタンが押された")
    }
}
