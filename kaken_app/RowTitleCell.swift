//
//  RowTitleCell.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/08/25.
//

import UIKit

import UIKit

class rowTitleCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    func configure(text: String) {
        titleLabel.text = text
    }
}

