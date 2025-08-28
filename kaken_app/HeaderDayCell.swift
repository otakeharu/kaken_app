import UIKit

final class HeaderDayCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!   // XIBで接続（上）
    @IBOutlet weak var wdayLabel: UILabel!  // XIBで接続（下）

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderWidth = 1.0 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.backgroundColor = .systemGray6

        dayLabel.textAlignment = .center
        wdayLabel.textAlignment = .center

        // 開発時の配線チェック
        assert(dayLabel != nil && wdayLabel != nil, "HeaderDayCell outlets not connected")
    }

    /// VCから文字列だけ渡す（Date依存を無くしてコンパイルエラー回避）
    func configure(dayText: String, weekdayText: String) {
        dayLabel.text  = dayText
        wdayLabel.text = weekdayText
    }
}
