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
    func configure(dayText: String, weekdayText: String, isKikanDay: Bool = false) {
        dayLabel.text  = dayText
        wdayLabel.text = weekdayText
        
        if isKikanDay {
            // kikan日付を目立たせる（ダークモード対応）
            contentView.backgroundColor = UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor.systemRed.withAlphaComponent(0.8) // ダークモード用赤
                } else {
                    return UIColor.systemRed // ライトモード用赤
                }
            }
            dayLabel.textColor = .white
            wdayLabel.textColor = .white
            dayLabel.font = .boldSystemFont(ofSize: dayLabel.font.pointSize)
            wdayLabel.font = .boldSystemFont(ofSize: wdayLabel.font.pointSize)
        } else {
            // 通常の表示（ダークモード自動対応）
            contentView.backgroundColor = .systemGray6
            dayLabel.textColor = .label // 自動でダークモード対応
            wdayLabel.textColor = .label // 自動でダークモード対応
            dayLabel.font = .systemFont(ofSize: dayLabel.font.pointSize)
            wdayLabel.font = .systemFont(ofSize: wdayLabel.font.pointSize)
        }
    }
}
