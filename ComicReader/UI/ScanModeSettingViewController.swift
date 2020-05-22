//
//  ScanModeSettingViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 10/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ScanModeSettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet var SettingsTable: UITableView!
    @IBOutlet var TextInfoLabel: UILabel!
    let scanModeOptions = [NSLocalizedString("VisionKitName", comment: "Scan Mode name in the row"),NSLocalizedString("CameraName", comment: "Scan Mode name in the row")]
    let scanModeText = [NSLocalizedString("CameraModeText", comment: "Scan Mode text explaining the row selected the row"),NSLocalizedString("VisionKitText", comment: "Scan Mode text explaining the row selected the row")]
    
    var settings:ComicReaderAppSettings!
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTable.delegate = self
        SettingsTable.dataSource = self
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("ScanningModeSetting", comment: "Scanning mode title for the navigation bar")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        selectedIndex = settings.getValueFromKey(key: "cameramode")
        TextInfoLabel.text = scanModeText[selectedIndex]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("ScanningModeHeader", comment: "Header for the rows in Scannig mode")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanModeOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanModeSetting", for: indexPath) as? SettingRowTableViewCell else {
            fatalError("Big Error")
        }
        
        cell.RowSettingLabel.text = scanModeOptions[indexPath.item]
        
        if indexPath.item == selectedIndex{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if settings.setValueForKey(key: "cameramode", value: indexPath.item){
            selectedIndex = indexPath.item
            TextInfoLabel.text = scanModeText[selectedIndex]
        }else{
            let alert = UIAlertController(title: NSLocalizedString("UnableToSetSetting", comment: "Unable to set settings title for the alert"), message: NSLocalizedString("UnableToSetSettingMessage", comment: "Unable to set settings subtitle large message for the alert"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        SettingsTable.reloadData()
    }

}
