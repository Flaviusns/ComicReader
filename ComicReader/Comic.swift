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
    var fileExtension: String
    
    init(name:String,path:String,comicsPages:[Data]?,fileExt: String){
        self.name = name
        self.path = path
        self.comicsPages = comicsPages
        self.favorite = false
        self.fileExtension = fileExt
    }
    
    init(name:String,path:String,cover:Data,fileExt: String,fav: Bool = false){
        self.name = name
        self.path = path
        self.comicsPages = [cover]
        self.favorite = fav
        self.fileExtension = fileExt
    }
    
    
    init(name:String,path:String,cover:[Data],fileExt: String){
        self.name = name
        self.path = path
        self.comicsPages = cover
        self.favorite = false
        self.fileExtension = fileExt
    }
    
    
}
