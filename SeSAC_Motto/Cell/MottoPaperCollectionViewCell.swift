//
//  MottoPaperCollectionViewCell.swift
//  SeSAC_Motto
//
//  Created by kokojong on 2021/11/20.
//

import UIKit

class MottoPaperCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MottoPaperCollectionViewCell"

    @IBOutlet weak var gameALabel: UILabel!
    @IBOutlet weak var gameBLabel: UILabel!
    @IBOutlet weak var gameCLabel: UILabel!
    @IBOutlet weak var gameDLabel: UILabel!
    @IBOutlet weak var gameELabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
