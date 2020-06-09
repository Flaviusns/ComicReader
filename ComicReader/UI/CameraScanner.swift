//
//  CameraScanner.swift
//  ComicReader
//
//  Created by Flavius Stan on 02/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import Zip
import VisionKit
import CoreData

class CameraScanner: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    



    @IBOutlet var ScanButton: UIButton!
    
    @IBOutlet var SaveButton: UIButton!
    
    @IBOutlet var DeleteComic: UIButton!
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ComicReaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var settings:ComicReaderAppSettings!
    var enableVisionKit = false
    
    struct exportQuality {
        let VeryHighQuality = 1.0
        let HighQuality = 0.75
        let MediumQuality = 0.5
        let LowQuality = 0.25
    }
    
    var exportQualityValue: CGFloat = 0.5
    
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
        
        let scrollView = UIScrollView()
        if UIApplication.shared.statusBarOrientation.isLandscape {
            if UIDevice.current.userInterfaceIdiom == .pad{
                scrollView.frame = CGRect(x: 0, y: height/5, width: width, height: height/5)
            }else{
                scrollView.frame = CGRect(x: 0, y: height/4, width: width, height: height/5)
            }
            
        } else {
            scrollView.frame = CGRect(x: 0, y: pageHeight*0.25, width: width, height: pageHeight)
        }
        

        self.view.addSubview(scrollView)
        
        
        
        
        
        navigationItem.title = NSLocalizedString("CreateComicTitle", comment: "Title at Scanner Comic View")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        
        
        
        
        
        
        SaveButton.isHidden = false
        DeleteComic.isHidden = true
        
        
        settings = ComicReaderAppSettings(container: persistentContainer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            let exportQualityValue = self.settings.getValueFromKey(key: "exportquality")
            switch exportQualityValue{
            case 0:
                self.exportQualityValue = 1.0
            case 1:
                self.exportQualityValue = 0.75
            case 2:
                self.exportQualityValue = 0.5
            case 3:
                self.exportQualityValue = 0.25
            default:
                self.exportQualityValue = 0.5
            }
            let cameraModeValue = self.settings.getValueFromKey(key: "cameramode")
            if cameraModeValue==0{
                self.enableVisionKit=true
            }else{
                self.enableVisionKit=false
            }
            
        }
    }
    
    @IBAction func openCamera(_ sender: Any) {
        if #available(iOS 13.0, *), enableVisionKit{
            let vc = VNDocumentCameraViewController()
            vc.delegate = self
            present(vc, animated: true)
        }else{
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = false
            vc.delegate = self
            present(vc, animated: true)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        addImageViewToPreview(imageToAdd: image)
        
    }
    
    
    private func addImageViewToPreview(imageToAdd: UIImage){
        
        var newHeigth:CGFloat
        if UIApplication.shared.statusBarOrientation.isLandscape{
            newHeigth = pageHeight/3
        }else{
            newHeigth = pageHeight
        }
        
        let imageView = UIImageView(frame: CGRect(x: pageWidth * CGFloat(numPages), y: 0, width: pageWidth, height: newHeigth))
        
        imageView.image = imageToAdd
        imageView.contentMode = .scaleAspectFit
        
        comicPages.append(imageToAdd)
        
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
    
    private func addImagetoPreviewOrientation(imageToAdd: UIImage,height: CGFloat, _ landscape: Bool){
        var newHeigth:CGFloat
        if landscape{
            newHeigth = pageHeight/3
        }else{
            newHeigth = pageHeight
        }
        
        let imageView = UIImageView(frame: CGRect(x: pageWidth * CGFloat(numPages), y: 0, width: pageWidth, height: newHeigth))
        
        imageView.image = imageToAdd
        imageView.contentMode = .scaleAspectFit
        
        numPages+=1
        
        for view in self.view.subviews{
            if let scrollView = view as? UIScrollView {
                scrollView.contentSize = CGSize(width: pageWidth * CGFloat(numPages), height: height/2)
                scrollView.addSubview(imageView)
            }
        }
        
        if SaveButton.isHidden{
            SaveButton.isHidden = false
            DeleteComic.isHidden = false
        }
    }
    
    private func changeScrollViewOrientation(width: CGFloat, height: CGFloat){
        var landscape = false
        for view in self.view.subviews{
            if let scrollView = view as? UIScrollView {
                for subview in scrollView.subviews{
                    subview.removeFromSuperview()
                }
                scrollView.removeFromSuperview()
            }
        }
        
        if width>height{ //Landscape
            landscape = true
            let scrollView = UIScrollView()
            if UIDevice.current.userInterfaceIdiom == .pad{
                scrollView.frame = CGRect(x: 0, y: height/5, width: width, height: height/5)
            }else{
                scrollView.frame = CGRect(x: 0, y: height/4, width: width, height: height/5)
            }
            
            
            self.view.addSubview(scrollView)
        }else{
            let scrollView = UIScrollView()
            scrollView.frame = CGRect(x: 0, y: pageHeight*0.25, width: width, height: pageHeight)
            
            self.view.addSubview(scrollView)
        }
        numPages = 0
        for image in comicPages{
            addImagetoPreviewOrientation(imageToAdd: image,height: height,landscape)
        }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        changeScrollViewOrientation(width: size.width, height: size.height)
    }
    
    @IBAction func deleteComic(_ sender: Any) {
        errasePreviewFromScrollView()
        
        SaveButton.isHidden = true
        DeleteComic.isHidden = true
        
        let confirmAlert = UIAlertController(title: NSLocalizedString("ComicDeleted", comment: "Delete Comic alert title inside the scan comic view"), message: nil, preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay inside the delete comic alert title. Scan comic view"), style: .default, handler: nil))
        
        comicPages.removeAll()
        numPages = 0
        
        self.present(confirmAlert, animated: true)
    }
    
    @IBAction func saveComic(_ sender: Any) {
        /*let alert = UIAlertController(title: NSLocalizedString("InputComicName", comment: "Input title in the save comic's alert at Scan comic view"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button inside the save comic alert at Scan comic view"), style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("InputNamePlaceHolder", comment: "Placeholder inside the enter comic name textfiled. Scan comic view")
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay inside the delete comic alert title. Scan comic view"), style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                self.comicName = name
                self.saveComicOperations()
                self.SaveButton.isHidden=true
                self.DeleteComic.isHidden=true
                let confirmAlert = UIAlertController(title: NSLocalizedString("ComicSaved", comment: "Comic saved message inside the Scan comic view"), message: nil, preferredStyle: .alert)
                    
                confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay inside the delete comic alert title. Scan comic view"), style: .default, handler: nil))
                    
                self.present(confirmAlert, animated: true)
            }
        }
        ))
        
        self.present(alert, animated: true)
        */
        let newVC = SaveComicViewController()
        
        present(newVC,animated: true,completion: nil)
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
            //MARK: Check if the comic name exist already
            try fileManager.createDirectory(at: tempPath, withIntermediateDirectories: true, attributes: nil)
            for image in comicPages{
                let imageURL = tempPath.path + "/" + "0\(comicPages.firstIndex(of: image)!).jpeg"
                try image.jpegData(compressionQuality: exportQualityValue)?.write(to: URL(fileURLWithPath: imageURL))
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
@available(iOS 13.0, *)
extension CameraScanner: VNDocumentCameraViewControllerDelegate{
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0 ..< scan.pageCount {
            let img = scan.imageOfPage(at: i)

            addImageViewToPreview(imageToAdd: img)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
