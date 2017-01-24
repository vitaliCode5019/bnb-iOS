//
//  AccommodationTableViewCell.swift
//  rider
//
//  Created by admin on 1/2/17.
//  Copyright © 2017 BicycleBNB. All rights reserved.
//

import UIKit
import SDWebImage

class AccommodationTableViewCell: UITableViewCell {
    private var _data: AccommodationModel?
    
    var data : AccommodationModel? {
        get {
            return _data
        }
        set {
            _data = newValue
            updateUI()
        }
    }
    weak var delegate: AccommodationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        let bookButton = contentView.viewWithTag(105) as! UIButton
        bookButton.addTarget(self, action: #selector(self.onBookNowClicked(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onBookNowClicked(_ sender: Any) {
        delegate?.accommodationTableViewCell(self, didBookButtonClicked: self.data)
    }
    
    func updateUI() {
        let image = contentView.viewWithTag(100) as? UIImageView
        let name = contentView.viewWithTag(101) as? UILabel
        let price = contentView.viewWithTag(102) as? UILabel
        let location = contentView.viewWithTag(103) as? UILabel
        let category = contentView.viewWithTag(104) as? UILabel
        let proximity = contentView.viewWithTag(106) as? UILabel
        
        if let urlString = data?.imageUrl,
            let url = URL(string: urlString) {
            image?.sd_setImage(with: url)
        }
        name?.text = data?.name
        price?.text = data?.price
        location?.text = data?.location
        category?.text = data?.category
        proximity?.text = data?.proximity()
    }
}

protocol AccommodationTableViewCellDelegate: class {
    func accommodationTableViewCell(_ : AccommodationTableViewCell, didBookButtonClicked cellData: AccommodationModel?)
}
