//
//  WelcomeViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 27/11/20.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.main.bounds
    var constraints: [CGFloat] = [170,240,310]
    
    var image1: UIStackView? = nil
    var image2: UIStackView? = nil
    var image3: UIStackView? = nil
    
    var comicFinder:ComicFinder? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13, *){
            self.view.backgroundColor = .systemBackground
        }else{
            self.view.backgroundColor = .white
        }
        if(screenSize.height > 667){
            constraints = [250,350,450]
        }
        addTitle()
        addLabel(titleText: "Transfer your comics", text: "Send your comics from your Mac to your device", imageName: "Transfer", topConstraint: constraints[0])
        addLabel(titleText: "Read your comics", text: "Read your comcis whetever you are", imageName: "ComicCollectionWelcome", topConstraint: constraints[1])
        addLabel(titleText: "Scan your comics", text: "Scan your paper comics and read it from your device", imageName: "CameraWelcome", topConstraint: constraints[2])
        addContinueButton()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.image1?.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0.25, options: .curveEaseOut, animations: {
            self.image2?.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0.50, options: .curveEaseOut, animations: {
            self.image3?.alpha = 1.0
        }, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    func addTitle(){
        let title = UILabel()
        title.textAlignment = .center
        title.text = "Welcome to Tham!"
        title.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        title.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.heightAnchor.constraint(equalToConstant: 155).isActive = true
        title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 15).isActive = true
        title.widthAnchor.constraint(equalToConstant: 350).isActive = true
        title.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true

    }
    
    func addLabel(titleText: String, text: String, imageName: String, topConstraint: CGFloat){
        
        let horizontalStack = UIStackView()
        horizontalStack.alpha = 0.0
        self.view.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.heightAnchor.constraint(equalToConstant: 155).isActive = true
        horizontalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: topConstraint).isActive = true
        horizontalStack.widthAnchor.constraint(equalToConstant: screenSize.width - 30).isActive = true
        horizontalStack.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        let image = UIImage(named: imageName)
        let imageView = UIImageView(frame: CGRect(x: 25, y: 0, width: 50, height: 50))
        
        if(imageName == "Transfer"){
            image1 = horizontalStack
        }else if(imageName == "ComicCollectionWelcome"){
            image2 = horizontalStack
        }else{
            image3 = horizontalStack
        }
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        horizontalStack.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let verticalStack = UIStackView()
        horizontalStack.addSubview(verticalStack)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.heightAnchor.constraint(equalToConstant: 155).isActive = true
        verticalStack.topAnchor.constraint(equalTo: horizontalStack.safeAreaLayoutGuide.topAnchor,constant: 0).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,constant: 5).isActive = true
        verticalStack.widthAnchor.constraint(equalToConstant: 300).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor,constant: 0).isActive = true
        
        let title = UILabel()
        title.textAlignment = .center
        title.text = titleText
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.numberOfLines = 1
        title.adjustsFontSizeToFitWidth = true
        
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.numberOfLines = 2
        textLabel.adjustsFontSizeToFitWidth = true
        
        verticalStack.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        title.topAnchor.constraint(equalTo: verticalStack.topAnchor,constant: 0).isActive = true
        title.widthAnchor.constraint(equalToConstant: 200).isActive = true
        title.centerXAnchor.constraint(equalTo: verticalStack.centerXAnchor, constant: 0).isActive = true
        
        verticalStack.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textLabel.topAnchor.constraint(equalTo: title.bottomAnchor,constant: 0).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: verticalStack.centerXAnchor, constant: 0).isActive = true
        
        
    }
    
    func addContinueButton(){
        let continueButton = UIButton()
        continueButton.backgroundColor = .systemBlue
        continueButton.setTitle("Continue", for: .normal)
        continueButton.layer.cornerRadius = 16
        
        continueButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        self.view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -50).isActive = true
        continueButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
    }
    
    @objc func dismissViewController(){
        if(comicFinder != nil){
            comicFinder!.toggleWelcomePresented()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
