//
//  Page.swift
//  ComicReader
//
//  Created by Flavius Stan on 26/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class Page: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("I'm here 2")
        return self.subviews[0]
    }
    

}
