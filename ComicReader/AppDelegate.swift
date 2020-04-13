//
//  AppDelegate.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
      
        let persistentContainer: NSPersistentContainer = {
            
            let container = NSPersistentContainer(name: "ComicReaderModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        let name = url.lastPathComponent
        let documentsPath = ComicFinder.getDocumentsDirectory()
        let pathToSave = documentsPath.appendingPathComponent(name)
            
            if !FileManager.default.fileExists(atPath: pathToSave.path){
                do {
                    //try data?.write(to: documentsPath)
                    try FileManager.default.moveItem(at: url, to: pathToSave)
                    if !FileManager.default.fileExists(atPath: pathToSave.path){
                        print("File not saved")
                    }
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Unable to save the comic: " + error.localizedDescription)
                    
                    do {
                        try FileManager.default.removeItem(at: url)
                        return false
                    } catch{
                        print("Unable to save the comic: " + error.localizedDescription)
                        return false
                    }
                }
            }
        
        
        do {
            guard let superView = window?.rootViewController as? UINavigationController else{
                throw ComicError.ViewNotMain
            }
            /*
             let alert = UIAlertController(title: "Comic Added", message: "Please refresh the collection", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
             superView.present(alert, animated: true, completion: nil)*/
            guard let viewController = superView.viewControllers[0] as? ViewController else {
                throw ComicError.ViewNotMain
            }
            let comicsFinder = ComicFinder(container: persistentContainer)
            comicsFinder.updateStorageComics()
            viewController.comics = comicsFinder.getSavedComics()
            
            viewController.reloadData()
            /*
             let alert = UIAlertController(title: "Comic Added", message: "The comic is now in your collection", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
             viewController.present(alert, animated: true, completion: nil)*/
        } catch {
            print("Unable to present the alert  " + error.localizedDescription)
            return false
        }
        
        return true
    }

}

