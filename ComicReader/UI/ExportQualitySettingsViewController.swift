//
//  ExportQualityViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 10/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ExportQualitySettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet var SettingsTable: UITableView!
    @IBOutlet var TextInfoLabel: UILabel!
    let ExportOptions = [NSLocalizedString("VeryHighQualityName", comment: "Text inside the row in the settings tab"),NSLocalizedString("HighQualityName", comment: "Text inside the row in the settings tab"),NSLocalizedString("MediumQualityName", comment: "Text inside the row in the settings tab"),NSLocalizedString("LowQualityName", comment: "Text inside the row in the settings tab")]
    let exportOptionsText = [NSLocalizedString("VeryHighQualityExportText", comment: "Text describing the setting"),NSLocalizedString("HighQualityExportText", comment: "Text describing the setting"),NSLocalizedString("MediumQualityExportText", comment: "Text describing the setting"),NSLocalizedString("LowQualityExportText", comment: "Text describing the setting")]
    var settings:ComicReaderAppSettings!
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTable.delegate = self
        SettingsTable.dataSource = self
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("QualityExportSetting", comment: "QualityExport title for navigationbar in the settings tag")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        selectedIndex = settings.getValueFromKey(key: "exportquality")
        TextInfoLabel.text = exportOptionsText[selectedIndex]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("QualityExportHeader", comment: "Header for the settings rows")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExportQualitySetting", for: indexPath) as? SettingRowTableViewCell else {
            fatalError("Big Error")
        }
        
        cell.RowSettingLabel.text = ExportOptions[indexPath.item]
        
        if indexPath.item == selectedIndex{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if settings.setValueForKey(key: "exportquality", value: indexPath.item){
            selectedIndex = indexPath.item
            TextInfoLabel.text = exportOptionsText[selectedIndex]
        }else{
            let alert = UIAlertController(title: NSLocalizedString("UnableToSetSetting", comment: "Unable to set settings title for the alert"), message: NSLocalizedString("UnableToSetSettingMessage", comment: "Unable to set settings subtitle large message for the alert"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        SettingsTable.reloadData()
    }

}
