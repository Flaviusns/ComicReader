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
    @IBOutlet weak var SelectedTick: UIImageView!
    
    override var isSelected: Bool {
        didSet{
            if !isSelected{
                SelectedTick.isHidden = true
            }else{
                SelectedTick.isHidden = false
            }
        }
    }
}
