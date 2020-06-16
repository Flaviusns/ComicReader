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
    
    let pageImage : UIImageView = {
        let image = UIImageView()
        //image.image = UIImage(named: "P1")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(pageName)
        self.addSubview(pageImage)

        
        NSLayoutConstraint.activate([
            pageName.centerXAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.centerXAnchor),
            pageName.centerYAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.centerYAnchor),
            pageName.heightAnchor.constraint(equalToConstant: 45),
            pageName.widthAnchor.constraint(equalToConstant: 100),
            pageImage.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor, constant: 5),
            pageImage.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            pageImage.heightAnchor.constraint(equalToConstant: 150),
            pageImage.widthAnchor.constraint(equalToConstant: 75),
            pageImage.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor, constant: 5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
