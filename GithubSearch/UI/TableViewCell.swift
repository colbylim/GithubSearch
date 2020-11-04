//
//  TableViewCell.swift
//  GithubSearch
//
//  Created by colbylim on 2020/11/03.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(name: String, desc: String?) {
        nameLbl.text = name
        
        if let text = desc, text.isEmpty == false {
            descLbl.text = text
        } else {
            descLbl.text = "정보없음"
        }
    }
}
