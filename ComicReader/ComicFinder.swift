//
//  ComicFinder.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import Foundation
import Zip

class ComicFinder{
    static func getStorageComics()-> [Comic]{
        var comicCollection = [Comic]()
        do {
            let fileManager = FileManager.default
            let documentsPath = getDocumentsDirectory()
            let tempPath = getTempDirectory()
            
            
            let fileURLs = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            for item in fileURLs {
                if(item.contains(".cbz")){
                    let fileName = item.split(separator: ".")[0]
                    try Zip.unzipFile(URL(fileURLWithPath: documentsPath.path  + "/" + item), destination: tempPath, overwrite: true, password: nil) // Unzip
                    let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
                    
                    var comicPages = [Data]()
                    
                    
                    
                    for page in comicPagesPath {
                        if(page.contains(".jpg") || page.contains(".png")){
                            comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                        }
                    }
                    
                    comicCollection.append(Comic(name: String(fileName),path: tempPath.path + "/" + fileName + "/",comicsPages: comicPages))
                }
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
        
        
        return comicCollection
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
    private static func getTempDirectory() -> URL{
        return FileManager.default.temporaryDirectory
    }
}
