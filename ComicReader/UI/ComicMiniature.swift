//
//  ComicMiniature.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ComicMiniature: UICollectionViewCell {
 
    @IBOutlet var ComicImage: UIImageView!
    @IBOutlet var ComicName: UILabel!
    @IBOutlet var FavButton: UIButton!
    @IBOutlet var SelectedButton: UIButton!
    @IBOutlet weak var SelectedTick: UIImageView!
    
    override var isSelected: Bool {
        didSet{
            if !isSelected{
                SelectedButton.setImage(UIImage(named: "Unselected"), for: .normal)
                SelectedTick.isHidden = true
            }else{
                SelectedButton.setImage(UIImage(named: "Selected"), for: .normal)
                SelectedTick.isHidden = false
            }
            
        }
    }
}
