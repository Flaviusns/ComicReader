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
    
    let sectionTitles = [NSLocalizedString("CollectionSettings", comment: "Collection Setings Header"),NSLocalizedString("ScanComicSettings", comment: "Scan comic settings header for settings"),NSLocalizedString("PrivacyAndLicense", comment: "Privacy And License Setings Header")]
    
    let firstSection = [NSLocalizedString("CollectionOrder", comment: "First title section inside the settings view")]
    var secondSection = [NSLocalizedString("ExportQuality", comment: "Second title section inside the settings view")]
    let thirdSection = [NSLocalizedString("PrivacyStatement", comment: "Privacy title section row inside the settings view"),
                        NSLocalizedString("LicenseStatement", comment: "License title section row inside the settings view")]
    
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

        navigationItem.title = NSLocalizedString("Settings", comment: "Settings title inside the Settings View")

        navigationItem.largeTitleDisplayMode = .always
        
        if #available(iOS 13, *){
            secondSection.append(NSLocalizedString("ScaningMode", comment: "Scaning mode row inside the settings root options"))
        }
        
        settings = ComicReaderAppSettings(container: persistentContainer)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return firstSection.count
        case 1:
            return secondSection.count
        case 2:
            return thirdSection.count
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
        }else if indexPath.section == 1{
            cell.SettingName.text = secondSection[indexPath.item]
        }else{
            cell.SettingName.text = thirdSection[indexPath.item]
        }
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "CollectionOrderSetting") as? OrderBySettingsController {
                nextVC.settings = self.settings
                navigationController?.pushViewController(nextVC, animated: true)
            }
        case 1:
            switch indexPath.item {
            case 0:
                if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ExportQualitySetting") as? ExportQualitySettingsViewController {
                    nextVC.settings = self.settings
                    navigationController?.pushViewController(nextVC, animated: true)
                }
            default:
                if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ScaningModeSetting") as? ScanModeSettingViewController {
                    nextVC.settings = self.settings
                    navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        case 2:
            switch indexPath.item {
            case 0:
                let nextVC = LicensePrivacyViewController()
                
                nextVC.textView.text = NSLocalizedString("PrivacyNote", comment: "Privacy note for the privacy view")
                nextVC.textView.font = .systemFont(ofSize: 17)
                
                nextVC.myTitle = NSLocalizedString("Privacy", comment: "Privacy title for the privacy note")
                
                navigationController?.pushViewController(nextVC, animated: true)
            case 1:
                let nextVC = LicensePrivacyViewController()
                
                nextVC.textView.text = """
                Every assest in this application, including the icon and the name of the aplicaction is property of Flavius Stan.

                Copyright (c) 2020 Flavius Stan
                You are prohibited from copying, modifying or resdistributing this content withour prior written permission from Flavius Stan.

                Every code file (*.swift, *.m, *.h) is provided by MIT License
                
                MIT License

                Copyright (c) 2020 Flavius Stan

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of this software and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all
                copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                SOFTWARE.
                """
                
                nextVC.myTitle = NSLocalizedString("License", comment: "License title for the privacy note")
                
                navigationController?.pushViewController(nextVC, animated: true)
            default:
                print("Invalid row")
            }
            
        default:
            print("Invalid row")
        }
    }
    

    

}
