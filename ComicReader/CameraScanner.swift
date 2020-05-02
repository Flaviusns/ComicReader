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
    
    var comicPages = [UIImage]()
    var numPages = 0
    var pageWidth: CGFloat = 0
    var pageHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        pageWidth = width/3
        pageHeight = height/2
        let scrollView = UIScrollView(frame: CGRect(x: 10, y: 50, width: width - 10, height: height / 2))
        self.view.addSubview(scrollView)
        
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
        
    }
    
    
    @IBAction func saveComic(_ sender: Any) {
        let fileManager = FileManager.default
        do {
            var tempPath = FileManager.default.temporaryDirectory
            tempPath.appendPathComponent("TestComic")
            try fileManager.createDirectory(at: tempPath, withIntermediateDirectories: true, attributes: nil)
            for image in comicPages{
                let imageURL = tempPath.path + "/" + "0\(comicPages.firstIndex(of: image)!).png"
                try image.fixOrientation()!.pngData()?.write(to: URL(fileURLWithPath: imageURL))
            }
            var finalPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            finalPath.appendPathComponent("TestComic.cbz")
            try Zip.zipFiles(paths: [tempPath], zipFilePath: finalPath, password: nil, progress: nil)
            print("Comic created")
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
