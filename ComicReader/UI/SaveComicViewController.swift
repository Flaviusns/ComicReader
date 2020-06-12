//
//  SaveComicViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 08/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class SaveComicViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate {
    
    var characters = ["Link", "Zelda", "Ganondorf", "Midna"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *){
            self.view.backgroundColor = .systemBackground
        }else{
            self.view.backgroundColor = .white
        }
        
        addNavBar()
        addNameTextField()
        addTableView()

        // Do any additional setup after loading the view.
    }
    
    //MARK: UI Related Elementes
    func addNavBar(){
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        navBar.delegate = self
                
        let navItem = UINavigationItem()
        navItem.title = NSLocalizedString("SaveNewComicViewControllerTitle", comment: "Title for the viewcontroller when you click save button")
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeView))

        navBar.items = [navItem]
        
        self.view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
    func addNameTextField(){
        
        let textField = UITextField() //frame: CGRect(x: 0, y: 100, width: self.view.frame.width * 0.75, height: 45))
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 100).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        textField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func addTableView(){
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ComicPageCell.self, forCellReuseIdentifier: "comicPageCell")
        tableView.isEditing = true
    }
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: nil)
    }

}

extension SaveComicViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "comicPageCell", for: indexPath) as? ComicPageCell else {
            fatalError("Unable to dequeue comicPageCell.")
        }
        cell.pageName.text = characters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.characters[sourceIndexPath.row]
        characters.remove(at: sourceIndexPath.row)
        characters.insert(movedObject, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
}
