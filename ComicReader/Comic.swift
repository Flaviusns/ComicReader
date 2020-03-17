//
//  Comic.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import Foundation


class Comic :NSObject{
    var name: String
    var path: String
    var comicsPages: [Data]?
    
    init(name:String,path:String,comicsPages:[Data]?){
        self.name = name
        self.path = path
        self.comicsPages = comicsPages
    }
}
