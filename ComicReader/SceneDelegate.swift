//
//  SceneDelegate.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let myScene = (scene as? UIWindowScene) else { return }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            if shortcutItem.type == "com.flavius.ComicReader.openscancomic" {
                print("ShourtCut")
                if let tabBarController = myScene.windows[0].rootViewController as? MainTabBarController{
                    tabBarController.selectedIndex = 1
                }
            }
        }
        
        
        
        
    }
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
            if shortcutItem.type == "com.flavius.ComicReader.openscancomic" {
                print("ShourtCut")
                if let tabBarController = windowScene.windows[0].rootViewController as? MainTabBarController{
                    tabBarController.selectedIndex = 1
                }
            }
    }
    
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        let persistentContainer: NSPersistentContainer = {
            
            let container = NSPersistentContainer(name: "ComicReaderModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        for item in URLContexts{
            let name = item.url.lastPathComponent
            let documentsPath = ComicFinder.getDocumentsDirectory()
            let pathToSave = documentsPath.appendingPathComponent(name)
            
            if !FileManager.default.fileExists(atPath: pathToSave.path){
                do {
                    //try data?.write(to: documentsPath)
                    try FileManager.default.moveItem(at: item.url, to: pathToSave)
                    if !FileManager.default.fileExists(atPath: pathToSave.path){
                        print("File not saved")
                    }
                    try FileManager.default.removeItem(at: item.url)
                } catch {
                    print("Unable to save the comic: " + error.localizedDescription)
                    
                    do {
                        try FileManager.default.removeItem(at: item.url)
                    } catch{
                        print("Unable to save the comic: " + error.localizedDescription)
                    }
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
        }
    }

}

