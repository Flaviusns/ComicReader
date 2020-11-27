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
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ComicReaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = ComicReaderAppSettings(container: persistentContainer)
        
        #if !targetEnvironment(macCatalyst)
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            if shortcutItem.type == "com.flavius.ComicReader.openscancomic" {
                if let tabBarController = application.windows[0].rootViewController as? MainTabBarController{
                    tabBarController.selectedIndex = 1
                }
            }else if shortcutItem.type == "com.flavius.ComicReader.openlastcomic"{
                
                if let tabBarController = application.windows[0].rootViewController as? MainTabBarController{
                    tabBarController.selectedIndex = 0
                    for view in tabBarController.viewControllers!{
                        if let mainViewController = view as? MainNavController{
                            for subview in mainViewController.viewControllers{
                                if let viewController = subview as? ViewController{
                                    let comicsFinder = ComicFinder()
                                    let comicName = comicsFinder.getLastComicRead()
                                    if let comic = comicsFinder.getComicbyName(comicName: comicName){
                                        
                                        if let nextVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                                            nextVC.comic = comic
                                            nextVC.comicFinder = comicsFinder
                                            viewController.navigationController?.pushViewController(nextVC, animated: true)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        #endif
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == "com.flavius.ComicReader.openscancomic" {
            if let tabBarController = application.windows[0].rootViewController as? MainTabBarController{
                tabBarController.selectedIndex = 1
            }
        }else if shortcutItem.type == "com.flavius.ComicReader.openlastcomic"{
            
            if let tabBarController = application.windows[0].rootViewController as? MainTabBarController{
                tabBarController.selectedIndex = 0
                for view in tabBarController.viewControllers!{
                    if let mainViewController = view as? MainNavController{
                        for subview in mainViewController.viewControllers{
                            if let viewController = subview as? ViewController{
                                let comicsFinder = ComicFinder()
                                let comicName = comicsFinder.getLastComicRead()
                                if let comic = comicsFinder.getComicbyName(comicName: comicName){
                                    
                                    if let nextVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                                        nextVC.comic = comic
                                        nextVC.comicFinder = comicsFinder
                                        viewController.navigationController?.pushViewController(nextVC, animated: true)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
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
        
      
        
        
        let name = url.lastPathComponent
        
        if !ComicFinder.checkIfFileIsDuplicate(fileName: name){
            let documentsPath = ComicFinder.getDocumentsDirectory()
            let pathToSave = documentsPath.appendingPathComponent(name)
            if !FileManager.default.fileExists(atPath: pathToSave.path){
                do {
                    //try data?.write(to: documentsPath)
                    try FileManager.default.moveItem(at: url, to: pathToSave)
                    if !FileManager.default.fileExists(atPath: pathToSave.path){
                        print("File not saved")
                    }
                    
                    if let tabBarController = app.windows[0].rootViewController as? MainTabBarController{
                        tabBarController.selectedIndex = 0
                        for view in tabBarController.viewControllers!{
                            if let mainViewController = view as? MainNavController{
                                for subview in mainViewController.viewControllers{
                                    if let viewController = subview as? ViewController{
                                        viewController.forceUpdate()
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    return true
                    
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
        }else{
            do{
                try FileManager.default.removeItem(at: url)
                if let tabBarController = app.windows[0].rootViewController as? MainTabBarController{
                    tabBarController.selectedIndex = 0
                    for view in tabBarController.viewControllers!{
                        if let mainViewController = view as? MainNavController{
                            for subview in mainViewController.viewControllers{
                                if let viewController = subview as? ViewController{
                                    viewController.presentErrorinFile = true
                                    break
                                }
                            }
                        }
                    }
                }
                return true
            }catch {
                return false
            }
        }
        return true
    }

}

