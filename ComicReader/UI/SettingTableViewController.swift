//
//  SettingTableViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 09/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData

class SettingTableViewController: UITableViewController {
    
    let sectionTitles = [NSLocalizedString("CollectionSettings", comment: "Collection Setings Header"),NSLocalizedString("ScanComicSettings", comment: "Scan comic settings header for settings")]
    let firstSection = [NSLocalizedString("CollectionOrder", comment: "First title section inside the settings view")]
    var secondSection = [NSLocalizedString("ExportQuality", comment: "Second title section inside the settings view")]
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ComicReaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var settings:ComicReaderAppSettings!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.title = NSLocalizedString("Settings", comment: "Settings title inside the Settings View")
        //self.navigationController?.navigationBar.titleTextAttributes = [
        //    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        //]
        navigationItem.largeTitleDisplayMode = .always
        
        if #available(iOS 13, *){
            secondSection.append(NSLocalizedString("ScaningMode", comment: "Scaning mode row inside the settings root options"))
        }
        
        settings = ComicReaderAppSettings(container: persistentContainer)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return firstSection.count
        case 1:
            return secondSection.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as? SettingTableViewCell else {
            fatalError("Big Error")
        }
        if indexPath.section == 0{
            cell.SettingName.text = firstSection[indexPath.item]
        }else{
            cell.SettingName.text = secondSection[indexPath.item]
        }
        
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "CollectionOrderSetting") as? OrderBySettingsController {
                nextVC.settings = self.settings
                navigationController?.pushViewController(nextVC, animated: true)
            }
        }
        else if indexPath.section == 1{
            if indexPath.item == 0{
                if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ExportQualitySetting") as? ExportQualitySettingsViewController {
                    nextVC.settings = self.settings
                    navigationController?.pushViewController(nextVC, animated: true)
                }
            }else{
                if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ScaningModeSetting") as? ScanModeSettingViewController {
                    nextVC.settings = self.settings
                    navigationController?.pushViewController(nextVC, animated: true)
                }
                
            }
        }
        
    }
    

    

}
