import UIKit

final class RowEditCell: UICollectionViewCell {
    static let reuseIdentifier = "RowEditCell"
    static let nib = UINib(nibName: "RowEditCell", bundle: nil)

    @IBOutlet private weak var button: UIButton!  // XIBで接続
    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderWidth = 1.0 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor.separator.cgColor
        button.setTitleColor(UIColor(red: 157/255.0, green: 133/255.0, blue: 99/255.0, alpha: 1.0), for: .normal)
        assert(button != nil, "RowEditCell.button is nil (check XIB)")
    }

    @IBAction private func tap(_ sender: UIButton) {
        onTap?()
    }

    func configure(title: String = "編集") {
        button.setTitle(title, for: .normal)
    }
}
