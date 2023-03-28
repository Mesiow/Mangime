//
//  MangimeCell.swift
//  Mangime
//
//  Created by Mesiow on 3/20/23.
//

import UIKit

class MangimeCell: UITableViewCell {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var airedLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterView.layer.cornerRadius = 2;
        
        self.accessoryType = .disclosureIndicator;
        self.selectedBackgroundView = UIView();
        self.selectedBackgroundView?.backgroundColor = UIColor.init(named: "CellSelectedColor");
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
