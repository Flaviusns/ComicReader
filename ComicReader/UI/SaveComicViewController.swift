//
//  SaveComicViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 08/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import Zip

class SaveComicViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate,UIAdaptivePresentationControllerDelegate,UITextFieldDelegate {
    
    var comicPages = [UIImage]()
    let textField = UITextField()
    var exportQualityValue: CGFloat = 0.5
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAndExit))
    var parentView : CameraScanner?
    let invalidChars = ["/","\\","'",";",":","|","."]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self
        
        if #available(iOS 13, *){
            self.view.backgroundColor = .systemBackground
        }else{
            self.view.backgroundColor = .white
        }
        
        doneButton.isEnabled = false
        
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
        navItem.rightBarButtonItem = doneButton
        navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeView))
        navBar.items = [navItem]
        
        self.view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
    func addNameTextField(){
        
        textField.center.x = self.view.center.x
        textField.textAlignment = .center
        textField.placeholder = NSLocalizedString("InputNamePlaceHolder", comment: "Placeholder inside the enter comic name textfiled. Scan comic view")
        textField.keyboardType = .alphabet
        textField.returnKeyType = .done
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.autocapitalizationType = .words
        textField.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        
        let errorNameImg = UIImageView(image: UIImage(named: "BadName"))
        errorNameImg.frame = CGRect(x: 2, y: 2, width: 28, height: 28)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        leftView.addSubview(errorNameImg)
        errorNameImg.contentMode = .scaleToFill
    
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        
        self.view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 100).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 260).isActive = true
        textField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.leftView?.isHidden = true

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
    
    @objc func closeViewWithAlert(){
        self.dismiss(animated: true, completion: { () -> Void
            in
            self.parentView?.shouldPresentSavedAlert = true
        })
    }
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveAndExit(){
        saveComicOperations()
    }
    
        
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let dimissAlert: UIAlertController
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            dimissAlert = UIAlertController(title: nil, message: NSLocalizedString("MessageDiscardActionSheet", comment: "Message displaying the advise for the user"), preferredStyle: .alert)
        }else{
          dimissAlert = UIAlertController(title: nil, message: NSLocalizedString("MessageDiscardActionSheet", comment: "Message displaying the advise for the user"), preferredStyle: .actionSheet)
        }
        
        let removeAll = UIAlertAction(title: NSLocalizedString("DiscardComic", comment: "Discard button removing the entire new comic from the save screen"), style: .destructive, handler: { action in
            print("Remove all clicked")
            self.parentView?.shouldRemove = true
            self.closeView()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the operation"), style: .cancel, handler: nil)
        dimissAlert.addAction(removeAll)
        dimissAlert.addAction(cancel)
        
        
        self.present(dimissAlert, animated: true, completion: nil)
    }
    
    
    
    private func saveComicOperations(){
        let fileManager = FileManager.default
        do {
            var tempPath = FileManager.default.temporaryDirectory
            tempPath.appendPathComponent(textField.text!)
            //Check if the comic name exist already
            try fileManager.createDirectory(at: tempPath, withIntermediateDirectories: true, attributes: nil)
            for image in comicPages{
                let imageURL = tempPath.path + "/" + "0\(comicPages.firstIndex(of: image)!).jpeg"
                try image.jpegData(compressionQuality: exportQualityValue)?.write(to: URL(fileURLWithPath: imageURL))
            }
            var finalPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            finalPath.appendPathComponent("\(textField.text!).cbz")
            try Zip.zipFiles(paths: [tempPath], zipFilePath: finalPath, password: nil, progress: nil)
            
            
            try fileManager.removeItem(at: tempPath) //Remove temp file
            self.parentView?.shouldRemove = true
            
                
            closeViewWithAlert()
            
        } catch {
            print("Error")
        }
    }
    
    @objc func textFieldChange(_ textField: UITextField){
        
        if let comicName = textField.text{
            if comicName == ""{
                doneButton.isEnabled = false
                textField.leftView?.isHidden = true
            }else{
                doneButton.isEnabled = true
                textField.leftView?.isHidden = true
                
                let chars = Array(comicName)
                for character in chars{
                    if invalidChars.contains(String(character)){
                        textField.leftView?.isHidden = false
                        doneButton.isEnabled = false
                        break
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    

        
}

extension SaveComicViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return comicPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "comicPageCell", for: indexPath) as? ComicPageCell else {
            fatalError("Unable to dequeue comicPageCell.")
        }
        cell.pageName.text = "Page \(indexPath.row)"
        cell.pageImage.image = comicPages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = comicPages[sourceIndexPath.row]
        comicPages.remove(at: sourceIndexPath.row)
        comicPages.insert(movedObject, at: destinationIndexPath.row)
        //let movedObject = names[sourceIndexPath.row]
        //names.remove(at: sourceIndexPath.row)
        //names.insert(movedObject, at: destinationIndexPath.row)
        tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    

    
}
