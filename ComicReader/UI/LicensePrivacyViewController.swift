//
//  LicensePrivacyViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 21/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class LicensePrivacyViewController: UIViewController {

    let textView = UITextView()
    var myTitle = "View"
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        navigationItem.title = myTitle
        
        createTextView()
        
        // Do any additional setup after loading the view.
    }
    
    func createTextView(){
        
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
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
