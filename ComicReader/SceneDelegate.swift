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
            }else if shortcutItem.type == "com.flavius.ComicReader.openlastcomic"{
                
                if let tabBarController = myScene.windows[0].rootViewController as? MainTabBarController{
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
            }else if shortcutItem.type == "com.flavius.ComicReader.openlastcomic"{
                
                
                
                if let tabBarController = windowScene.windows[0].rootViewController as? MainTabBarController{
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
    
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        for item in URLContexts{
            let name = item.url.lastPathComponent
            
            if !ComicFinder.checkIfFileIsDuplicate(fileName: name){
                let documentsPath = ComicFinder.getDocumentsDirectory()
                let pathToSave = documentsPath.appendingPathComponent(name)
                    
                if !FileManager.default.fileExists(atPath: pathToSave.path){
                        do {
                            
                            try FileManager.default.moveItem(at: item.url, to: pathToSave)
                            if !FileManager.default.fileExists(atPath: pathToSave.path){
                                print("File not saved")
                            }
                            if let windowsScene = scene as? UIWindowScene{
                                if let tabBarController = windowsScene.windows[0].rootViewController as? MainTabBarController{
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
                            }
                            
                            
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
        else{
            do {
                try FileManager.default.removeItem(at: item.url)
                if let windowsScene = scene as? UIWindowScene{
                    if let tabBarController = windowsScene.windows[0].rootViewController as? MainTabBarController{
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
                }
            } catch  {
                print("Unable to present delete item " + error.localizedDescription)
            }
        }
            
    }
    }
    

}

