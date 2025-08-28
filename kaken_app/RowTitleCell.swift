import UIKit

final class RowTitleCell: UICollectionViewCell {
    static let reuseIdentifier = "RowTitleCell"
    static let nib = UINib(nibName: "RowTitleCell", bundle: nil)

    @IBOutlet weak var titleLabel: UILabel!   // XIBで接続

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderWidth = 1.0 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor.separator.cgColor
        titleLabel.numberOfLines = 2
        assert(titleLabel != nil, "RowTitleCell.titleLabel is nil (check XIB)")
    }

    func configure(text: String) {
        titleLabel.text = text
    }
}
