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
        addNameTextField()

        // Do any additional setup after loading the view.
    }
    
    //MARK: UI Related Elementes
    func addNavBar(){
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        navBar.delegate = self
                
        let navItem = UINavigationItem()
        navItem.title = NSLocalizedString("SaveNewComicViewControllerTitle", comment: "Title for the viewcontroller when you click save button")
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeView))

        navBar.items = [navItem]
        
        self.view.addSubview(navBar)
    }
    
    func addNameTextField(){
        
        let textField = UITextField(frame: CGRect(x: 0, y: 100, width: self.view.frame.width * 0.75, height: 45))
        textField.center.x = self.view.center.x
        textField.textAlignment = .center
        textField.placeholder = NSLocalizedString("InputNamePlaceHolder", comment: "Placeholder inside the enter comic name textfiled. Scan comic view")
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.autocapitalizationType = .words
        textField.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        
        self.view.addSubview(textField)
        
        textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -50).isActive = true
        textField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
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
