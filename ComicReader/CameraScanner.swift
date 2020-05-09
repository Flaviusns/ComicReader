//
//  CameraScanner.swift
//  ComicReader
//
//  Created by Flavius Stan on 02/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import Zip

class CameraScanner: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {


    @IBOutlet var ScanButton: UIButton!
    
    @IBOutlet var SaveButton: UIButton!
    
    @IBOutlet var DeleteComic: UIButton!
    
    var comicPages = [UIImage]()
    var numPages = 0
    var pageWidth: CGFloat = 0
    var pageHeight: CGFloat = 0
    var comicName = "New Comic"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        pageWidth = width/3
        pageHeight = height/2
        let scrollView = UIScrollView(frame: CGRect(x: 10, y: 50, width: width - 10, height: height / 2))
        self.view.addSubview(scrollView)
        
        navigationItem.title = NSLocalizedString("CreateComicTitle", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        SaveButton.isHidden = true
        DeleteComic.isHidden = true
        
        
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        comicPages.append(image)
        addImageViewToPreview(imageToAdd: image)
        
    }
    
    
    private func addImageViewToPreview(imageToAdd: UIImage){
        let imageView = UIImageView(frame: CGRect(x: pageWidth * CGFloat(numPages), y: 0, width: pageWidth, height: pageHeight))
        
        imageView.image = imageToAdd
        imageView.contentMode = .scaleAspectFit
        
        numPages+=1
        
        for view in self.view.subviews{
            if let scrollView = view as? UIScrollView {
                scrollView.contentSize = CGSize(width: pageWidth * CGFloat(numPages), height: self.view.bounds.height/2)
                scrollView.addSubview(imageView)
            }
        }
        
        if SaveButton.isHidden{
            SaveButton.isHidden = false
            DeleteComic.isHidden = false
        }
        
    }
    
    @IBAction func deleteComic(_ sender: Any) {
        errasePreviewFromScrollView()
        
        SaveButton.isHidden = true
        DeleteComic.isHidden = true
        
        let confirmAlert = UIAlertController(title: NSLocalizedString("ComicDeleted", comment: ""), message: "", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
        
        self.present(confirmAlert, animated: true)
    }
    
    @IBAction func saveComic(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("InputComicName", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("InputNamePlaceHolder", comment: "")
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                self.comicName = name
                self.saveComicOperations()
                    
                let confirmAlert = UIAlertController(title: NSLocalizedString("ComicSaved", comment: ""), message: "", preferredStyle: .alert)
                    
                confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    
                self.present(confirmAlert, animated: true)
            }
        }
        ))
        
        self.present(alert, animated: true)
        
    }
    
    private func errasePreviewFromScrollView(){
        for view in self.view.subviews{
            if let scrollView = view as? UIScrollView {
                for view in scrollView.subviews{
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    private func saveComicOperations(){
        let fileManager = FileManager.default
        do {
            var tempPath = FileManager.default.temporaryDirectory
            tempPath.appendPathComponent(comicName)
            //TODO: Check if the comic name exist already
            try fileManager.createDirectory(at: tempPath, withIntermediateDirectories: true, attributes: nil)
            for image in comicPages{
                let imageURL = tempPath.path + "/" + "0\(comicPages.firstIndex(of: image)!).jpeg"
                try image.jpegData(compressionQuality: 0.5)?.write(to: URL(fileURLWithPath: imageURL))
            }
            var finalPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            finalPath.appendPathComponent("\(comicName).cbz")
            try Zip.zipFiles(paths: [tempPath], zipFilePath: finalPath, password: nil, progress: nil)
            
            
            try fileManager.removeItem(at: tempPath) //Remove temp file
            
            errasePreviewFromScrollView()
            
        } catch {
            print("Error")
        }
    }
    
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
