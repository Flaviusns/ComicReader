//
//  SaveComicViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 08/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class SaveComicViewController: UIViewController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *){
            self.view.backgroundColor = .systemBackground
        }else{
            self.view.backgroundColor = .white
        }
        
        addNavBar()
                

        // Do any additional setup after loading the view.
    }
    
    func addNavBar(){
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        navBar.delegate = self
                
        let navItem = UINavigationItem()
        navItem.title = NSLocalizedString("SaveNewComicViewControllerTitle", comment: "Title for the viewcontroller when you click save button")
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeView))

        navBar.items = [navItem]
        
        self.view.addSubview(navBar)
    }
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: nil)
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
