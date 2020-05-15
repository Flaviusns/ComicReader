//
//  ComicFinder.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import Foundation
import Zip
import CoreData
import LzmaSDK_ObjC

class ComicFinder{
    
    var container: NSPersistentContainer!
    var errorInFile = false
    
    init(container: NSPersistentContainer!) {
        self.container = container
    }
    
    init(){
        
    }
    
    
    func updateStorageComics(){
        
        do {
            let fileManager = FileManager.default
            let documentsPath = ComicFinder.getDocumentsDirectory()
            let tempPath = ComicFinder.getTempDirectory()
            let savedComics = getNameofSavedComics()
            print(documentsPath.path)
            let fileURLs = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            for item in fileURLs {
                if(item.contains(".cbz")){
                    let fileName = item.split(separator: ".")[0]
                    
                    if !savedComics.contains(String(fileName)){
                        
                        if let newComic = decompressCBZ(fileName: String(fileName)){
                            saveNewComic(comicToSave: newComic)
                            
                            //Remove the comic from the temp directory
                            do{
                                try fileManager.removeItem(at: URL(fileURLWithPath: tempPath.path + "/" + fileName))
                            } catch {
                                print("Unable to delete the temp folder")
                            }
                        }
                    }
                }
                else if(item.contains(".cb7")){
                    let fileName = item.split(separator: ".")[0]
                    
                    if !savedComics.contains(String(fileName)){
                        
                        if let newComic = decompressCB7(fileName: String(fileName)){
                            saveNewComic(comicToSave: newComic)
                            
                            //Remove the comic from the temp directory
                            do{
                                try fileManager.removeItem(at: URL(fileURLWithPath: tempPath.path + "/" + fileName))
                            } catch {
                                print("Unable to delete the temp folder")
                            }
                        }
                    }
                }
                else if(item.contains(".cbr")){
                    let fileName = item.split(separator: ".")[0]
                    
                    if !savedComics.contains(String(fileName)){
                        
                        if let newComic = decompressCBR(fileName: String(fileName)){
                            saveNewComic(comicToSave: newComic)
                            
                            //Remove the comic from the temp directory
                            do{
                                try fileManager.removeItem(at: URL(fileURLWithPath: tempPath.path + "/" + fileName))
                            } catch {
                                print("Unable to delete the temp folder")
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
        
    }
    
    func decompressCBZ(fileName:String) -> Comic?{
        let fileManager = FileManager.default
        let documentsPath = ComicFinder.getDocumentsDirectory()
        let tempPath = ComicFinder.getTempDirectory()
        
        let cbzPath = documentsPath.path  + "/" + fileName + ".cbz"
        print(fileManager.fileExists(atPath: cbzPath))
        do {
            try Zip.unzipFile(URL(fileURLWithPath: cbzPath), destination: tempPath, overwrite: true, password: nil) // Unzip
            let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
            
            var comicPages = [Data]()
            //This for it's just to avoid hidden files in the folder
            for page in comicPagesPath {
                if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){ //Find the first image and break.
                    comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                    break
                }
            }
            
            let newComic = Comic(name: fileName,path: cbzPath,cover: comicPages,fileExt: ".cbz")
            return newComic
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            errorInFile = true
            return nil
        }
    }
    
    func decompressCBR(fileName:String) -> Comic?{
        let fileManager = FileManager.default
        let documentsPath = ComicFinder.getDocumentsDirectory()
        let tempPath = ComicFinder.getTempDirectory()
        
        let cbrPath = documentsPath.path  + "/" + fileName + ".cbr"
        
        let extractURL = tempPath.path + "/" + fileName
        do {
            if fileManager.fileExists(atPath: extractURL){
                try fileManager.removeItem(at: URL(fileURLWithPath: extractURL))
            }
            try fileManager.createDirectory(atPath: extractURL, withIntermediateDirectories: false, attributes: nil)
            let decompressRarClass = DecompressRar()
            let extractResult = decompressRarClass.extractFile(cbrPath, withSecond: extractURL)
            if extractResult {
                let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
                
                var comicPages = [Data]()
                //This for it's just to avoid hidden files in the folder
                for page in comicPagesPath {
                    if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){ //Find the first image and break.
                        comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                        break
                    }
                }
                
                let newComic = Comic(name: fileName,path: cbrPath,cover: comicPages,fileExt: ".cbr")
                return newComic
            }else{
                do{//If the file is not a valid Rar file, remove it from the system
                    errorInFile = true
                    try fileManager.removeItem(atPath: cbrPath)
                }
            }
            return nil
            
        } catch {
            errorInFile = true
            print("Error while enumerating files: \(error.localizedDescription)")
            return nil
        }
    }
    
    func decompressCB7(fileName:String) -> Comic?{
        let fileManager = FileManager.default
        let documentsPath = ComicFinder.getDocumentsDirectory()
        let tempPath = ComicFinder.getTempDirectory()
        
        let cb7Path = documentsPath.path  + "/" + fileName + ".cb7"
        if fileManager.fileExists(atPath: cb7Path){
            do {
                let finalURL = URL(fileURLWithPath: tempPath.path + "/" + fileName + ".7z")
                try fileManager.copyItem(at: URL(fileURLWithPath: cb7Path), to: finalURL)
                let reader = LzmaSDKObjCReader(fileURL: finalURL)
                var items = [LzmaSDKObjCItem]()  // Array with selected items.
                try reader.open()
                reader.iterate(handler: {
                    (item: LzmaSDKObjCItem, error: Error?) -> Bool in
                    items.append(item)
                    return true
                })
                if reader.extract(items, toPath: tempPath.path, withFullPaths: true) {
                    print("Extract failed: \(reader.lastError?.localizedDescription ?? "Dead Fail")")
                }
                
                let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
                
                var comicPages = [Data]()
                //This for it's just to avoid hidden files in the folder
                for page in comicPagesPath {
                    if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){ //Find the first image and break.
                        comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                        break
                    }
                }
                
                let newComic = Comic(name: fileName,path: cb7Path,cover: comicPages,fileExt: ".cb7")
                try fileManager.removeItem(at: finalURL)
                return newComic
            } catch {
                errorInFile = true
                print("Error while enumerating files: \(error.localizedDescription)")
                return nil
            }
        }
        errorInFile = true
        return nil
        
    }
    
    func removeComicsNoLongerExist(){
        
        let fileManager = FileManager.default
        let savedComics = getSavedComics()
        let documentsPath = ComicFinder.getDocumentsDirectory()
        do {
            var fileURLs = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            fileURLs = fileURLs.filter({$0 != ".DS_Store" && $0 != "Inbox" && $0 != ".Trash"})
            
            if fileURLs.isEmpty && !savedComics.isEmpty{
                for savedComic in savedComics{
                    removeComicFromDataBase(comicToRemoveName: savedComic.name)
                }
            }
            else if fileURLs.count != savedComics.count{
                fileURLs = fileURLs.map({
                    String($0.split(separator: ".")[0])
                })
                
                for savedComic in savedComics{
                    if !fileURLs.contains(savedComic.name){
                        removeComicFromDataBase(comicToRemoveName: savedComic.name)
                    }
                }
            }
        } catch  {
            print("Error while cheking for removed files")
        }
        
        
    }
    
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    } 
    
    
    
    private static func getTempDirectory() -> URL{
        return FileManager.default.temporaryDirectory
    }
    
    public func getSavedComics() -> [Comic]{
        var savedComics = [Comic]()
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
            request.returnsObjectsAsFaults = false
            let result = try container.viewContext.fetch(request)
            if result.isEmpty{
                print("Empty comic collection")
            }
            else{
                for item in result{
                    guard let comicEntity = item as? NSManagedObject else{
                        fatalError("Unable to cast comicEntity")
                    }
                    savedComics.append(Comic(name: comicEntity.value(forKey: "name") as! String, path: comicEntity.value(forKey: "path") as! String, cover: comicEntity.value(forKey: "cover") as! Data,
                                             fileExt: comicEntity.value(forKey: "fileextension") as! String,
                                             lastPage: comicEntity.value(forKey: "lastpage") as? Int ?? 0,
                                             fav: comicEntity.value(forKey: "favorite") as? Bool ?? false))
                }
            }
        }catch let error as NSError{
            print("FatalError \(error)")
        }
        
        return savedComics
    }
    
    public func getFavComics() -> [Comic]{
        var favComics = [Comic]()
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "favorite == true")
            let result = try container.viewContext.fetch(request)
            if result.isEmpty{
                print("Empty fav collection")
            }
            else{
                for item in result{
                    guard let comicEntity = item as? NSManagedObject else{
                        fatalError("Unable to cast comicEntity")
                    }
                    favComics.append(Comic(name: comicEntity.value(forKey: "name") as! String, path: comicEntity.value(forKey: "path") as! String, cover: comicEntity.value(forKey: "cover") as! Data,fileExt: comicEntity.value(forKey: "fileextension") as! String,
                                           lastPage: comicEntity.value(forKey: "lastpage") as? Int ?? 0,
                                           fav: comicEntity.value(forKey: "favorite") as? Bool ?? true))
                }
            }
        }catch let error as NSError{
            print("FatalError \(error)")
        }
        
        return favComics
    }
    
    static func removeTempComic(fileName: String){
        
        //Remove the comic from the temp directory
        do{
            
            try FileManager.default.removeItem(at: URL(fileURLWithPath: getTempDirectory().path + "/" + fileName))
            
        } catch {
            print("Unable to delete the temp folder")
        }
    }
    
    private func getNameofSavedComics() -> [String]{
        
        var savedComics = [String]()
        
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
            request.returnsObjectsAsFaults = false
            let result = try container.viewContext.fetch(request)
            if result.isEmpty{
                print("Empty comic collection")
            }
            else{
                for item in result{
                    guard let comicEntity = item as? NSManagedObject else{
                        fatalError("Unable to cast comicEntity")
                    }
                    savedComics.append(comicEntity.value(forKey: "name") as! String)
                }
            }
        }catch let error as NSError{
            print("FatalError \(error)")
        }
        
        return savedComics
    }
    
    static func getComicPages(fileName: String)-> [Data]{
        
        var comicPages = [Data]()
        let fileManager = FileManager.default
        let tempPath = getTempDirectory()
        let docPath = getDocumentsDirectory()
        let completePath = docPath.path + "/" + fileName + ".cbz"
        
        do {
            try Zip.unzipFile(URL(fileURLWithPath: completePath), destination: tempPath, overwrite: true, password: nil) // Unzip
            let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
            
            for page in comicPagesPath {
                if(page.contains(".jpg") || page.contains(".png")){
                    comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                }
            }
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
        }
        
        return comicPages
    }
    
    static func getComicPages(file: Comic)-> [Data]{
        
        var comicPages = [Data]()
        let fileManager = FileManager.default
        let tempPath = getTempDirectory()
        let docPath = getDocumentsDirectory()
        let completePath = docPath.path + "/" + file.name + file.fileExtension
        
        do {
            if file.fileExtension == ".cbz"{
                try Zip.unzipFile(URL(fileURLWithPath: completePath), destination: tempPath, overwrite: true, password: nil) // Unzip
                let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + file.name + "/").sorted()
                
                for page in comicPagesPath {
                    if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){
                        comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + file.name + "/" + page)))
                    }
                }
            }
            else if file.fileExtension == ".cb7"{
                let finalURL = URL(fileURLWithPath: tempPath.path + "/" + file.name + ".7z")
                try fileManager.copyItem(at: URL(fileURLWithPath: completePath), to: finalURL)
                let reader = LzmaSDKObjCReader(fileURL: finalURL)
                var items = [LzmaSDKObjCItem]()  // Array with selected items.
                try reader.open()
                reader.iterate(handler: {
                    (item: LzmaSDKObjCItem, error: Error?) -> Bool in
                    items.append(item)
                    return true
                })
                if reader.extract(items, toPath: tempPath.path, withFullPaths: true) {
                    print("Extract failed: \(reader.lastError?.localizedDescription ?? "Dead Fail")")
                }
                
                let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + file.name + "/").sorted()
                
                for page in comicPagesPath {
                    if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){
                        comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + file.name + "/" + page)))
                    }
                }
                try fileManager.removeItem(at: finalURL)
            }
            else if file.fileExtension == ".cbr"{
                
                let extractURL = tempPath.path + "/" + file.name
                do {
                    try fileManager.createDirectory(atPath: extractURL, withIntermediateDirectories: false, attributes: nil)
                    let decompressRarClass = DecompressRar()
                    let extractResult = decompressRarClass.extractFile(completePath, withSecond: extractURL)
                    if extractResult {
                        let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + file.name + "/").sorted()
                        
                        
                        //This for it's just to avoid hidden files in the folder
                        for page in comicPagesPath {
                            if(page.contains(".jpg") || page.contains(".png") || page.contains(".jpeg")){ //Find the first image and break.
                                comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + file.name + "/" + page)))
                            }
                        }
                        
                    }
                    
                    try fileManager.removeItem(atPath: extractURL)
                    
                } catch {
                    print("Error while enumerating files: \(error.localizedDescription)")
                }
            }
            
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
        }
        
        return comicPages
    }
    
    func removeComic(comicToRemove: Comic) -> Bool{
        let docPath = ComicFinder.getDocumentsDirectory()
        let comicFile = comicToRemove.name + comicToRemove.fileExtension
        do {
            removeComicFromDataBase(comicToRemove: comicToRemove)
            try FileManager.default.removeItem(atPath: docPath.path + "/" + comicFile)
            return true
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
            return false
        }
    }
    
    func removeComic(comicToRemoveName: String) -> Bool{
        let docPath = ComicFinder.getDocumentsDirectory()
        let comicExtension = getComicExtension(comicName: comicToRemoveName)
        let comicFile = comicToRemoveName + comicExtension
        do {
            removeComicFromDataBase(comicToRemoveName: comicToRemoveName)
            try FileManager.default.removeItem(atPath: docPath.path + "/" + comicFile)
            return true
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
            return false
        }
    }
    
    private func saveNewComic(comicToSave: Comic){
        
        let managedContext = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ComicEntity", in: managedContext)!
        let newComic = NSManagedObject(entity: entity, insertInto: managedContext)
        
        newComic.setValue(comicToSave.name, forKeyPath: "name")
        newComic.setValue(comicToSave.path, forKey: "path")
        newComic.setValue(comicToSave.comicsPages![0], forKey: "cover")
        newComic.setValue(false, forKey: "favorite")
        newComic.setValue(comicToSave.fileExtension, forKey: "fileextension")
        
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func removeComicFromDataBase(comicToRemove: Comic){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicToRemove.name)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                managedContext.delete(entity)
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }
    
    
    private func removeComicFromDataBase(comicToRemoveName: String){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicToRemoveName)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                managedContext.delete(entity)
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    private func getComicExtension(comicName: String) -> String{
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicName)
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
                return ""
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                let comicExtension = entity.value(forKey: "fileextension") as! String
                return comicExtension
            }
        } catch {
            return ""
        }
    }
    
    func toggleFavComic(comicName: String){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicName)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                let currentStatus = entity.value(forKey: "favorite") as! Bool
                entity.setValue(!currentStatus, forKey: "favorite")
                
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func saveLastPage(comicName: String, lastPage: Int){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicName)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                
                entity.setValue(lastPage, forKey: "lastpage")
                
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func getPathofComic(comicName: String) -> String{
        let documentPath = ComicFinder.getDocumentsDirectory()
        return documentPath.path + "/" + comicName + ".cbz"
    }
    
    func getErrorInFile() -> Bool{
        let error = errorInFile
        if error{
            errorInFile.toggle()
        }
        return error
    }
    
    func getComicbyName(comicName: String) -> Comic? {
        let persistentContainer: NSPersistentContainer = {
            
            let container = NSPersistentContainer(name: "ComicReaderModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        let managedContext = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicName)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let comicEntity = result[0] as? NSManagedObject else{
                    fatalError("Unable to cast comicEntity")
                }
                
                return Comic(name: comicEntity.value(forKey: "name") as! String, path: comicEntity.value(forKey: "path") as! String, cover: comicEntity.value(forKey: "cover") as! Data,fileExt: comicEntity.value(forKey: "fileextension") as! String,
                      lastPage: comicEntity.value(forKey: "lastpage") as? Int ?? 0,
                      fav: comicEntity.value(forKey: "favorite") as? Bool ?? true)
            }
        } catch {
            return nil
        }
        return nil
    }
}
