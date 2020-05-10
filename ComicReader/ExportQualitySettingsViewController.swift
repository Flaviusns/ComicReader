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
    let orderByOptions = [NSLocalizedString("VeryHighQualityName", comment: ""),NSLocalizedString("HighQualityName", comment: ""),NSLocalizedString("MediumQualityName", comment: ""),NSLocalizedString("LowQualityName", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTable.delegate = self
        SettingsTable.dataSource = self
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("QualityExportSetting", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        TextInfoLabel.text = NSLocalizedString("QualityExportText", comment: "")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("QualityExportHeader", comment: "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExportQualitySetting", for: indexPath) as? SettingRowTableViewCell else {
            fatalError("Big Error")
        }
        
        cell.RowSettingLabel.text = orderByOptions[indexPath.item]
        
        cell.accessoryType = .checkmark
        
        return cell
    }

}
