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
    var favorite: Bool
    
    init(name:String,path:String,comicsPages:[Data]?){
        self.name = name
        self.path = path
        self.comicsPages = comicsPages
        self.favorite = false
    }
    
    init(name:String,path:String,cover:Data,fav: Bool = false){
        self.name = name
        self.path = path
        self.comicsPages = [cover]
        self.favorite = fav
    }
    
    init(name:String,path:String,cover:[Data]){
        self.name = name
        self.path = path
        self.comicsPages = cover
        self.favorite = false
    }
}
