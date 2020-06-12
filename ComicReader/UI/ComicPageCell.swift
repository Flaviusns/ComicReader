//
//  ComicPageCell.swift
//  Tham!
//
//  Created by Flavius Stan on 12/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ComicPageCell: UITableViewCell {
    
    let pageName : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14,weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(pageName)
        pageName.heightAnchor.constraint(equalToConstant: 45).isActive = true
        pageName.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        pageName.widthAnchor.constraint(equalToConstant: 100).isActive = true
        pageName.centerXAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
