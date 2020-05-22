//
//  OrderBySettingsController.swift
//  ComicReader
//
//  Created by Flavius Stan on 09/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class OrderBySettingsController: UIViewController,UITableViewDelegate,UITableViewDataSource{
        
    
    @IBOutlet var SettingsTable: UITableView!
    @IBOutlet var TextInfoLabel: UILabel!
    
    let orderByOptions = [NSLocalizedString("OrderByName", comment: "Order by Name row title"),NSLocalizedString("OrderByAdditionDate", comment: "Order by Addition date row title")]
    let orderByTextInfo = [NSLocalizedString("OrderByNameText", comment: "Order by Name text describing information"),NSLocalizedString("OrderByAdditionText", comment: "Order by addition text describing information")]
    var settings:ComicReaderAppSettings!
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTable.delegate = self
        SettingsTable.dataSource = self

        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("OrderBySetting", comment: "Order by settings title of the view order by settings")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndex = settings.getValueFromKey(key: "orderby")
        TextInfoLabel.text = orderByTextInfo[selectedIndex]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("OrderByHeader", comment: "Order by header of the rows inside the order by setttings")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderBySetting", for: indexPath) as? SettingRowTableViewCell else {
            fatalError("Big Error")
        }
        
        cell.RowSettingLabel.text = orderByOptions[indexPath.item]
        
        if indexPath.item == selectedIndex{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if settings.setValueForKey(key: "orderby", value: indexPath.item){
            selectedIndex = indexPath.item
            TextInfoLabel.text = orderByTextInfo[selectedIndex]
        }else{
            let alert = UIAlertController(title: NSLocalizedString("UnableToSetSetting", comment: "Unable to set settings title for the alert"), message: NSLocalizedString("UnableToSetSettingMessage", comment: "Unable to set settings subtitle large message for the alert"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        SettingsTable.reloadData()
    }
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
