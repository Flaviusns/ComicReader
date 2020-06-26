//
//  ComicLectureViewController.swift
//  Tham!
//
//  Created by Flavius Stan on 26/06/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ComicLectureViewController: UIViewController, UIScrollViewDelegate {
    
    let mainScrollView = UIScrollView()
    let thumbnailsScroll = UIScrollView()
    
    var comic: Comic? = nil
    var comicFinder: ComicFinder? = nil
    var currentPage = 0
    var hideNavBar = false
    var totalWidth : CGFloat = 0.0
    var thumbnailWith : CGFloat = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *){
            self.view.backgroundColor = .systemBackground
        }else{
            self.view.backgroundColor = .white
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        
        self.navigationController?.title = comic?.name
        
        createMainAndThumbsScrollView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addPagesToView(pages: (comic?.comicsPages)!)
        
    }
    
    
    func createMainAndThumbsScrollView(){
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = 1.0
        mainScrollView.maximumZoomScale = 4.0
        mainScrollView.zoomScale = 1.0
        
        thumbnailsScroll.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mainScrollView)
        self.view.addSubview(thumbnailsScroll)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            thumbnailsScroll.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            thumbnailsScroll.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            thumbnailsScroll.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            thumbnailsScroll.heightAnchor.constraint(equalToConstant: 50),
            
            mainScrollView.bottomAnchor.constraint(equalTo: thumbnailsScroll.topAnchor)
        ])
        
    }
    
    func addPagesToView(pages: [Data]){
        
        totalWidth = self.view.bounds.width * CGFloat(pages.count)
        
        mainScrollView.contentSize = CGSize(width: totalWidth, height: mainScrollView.bounds.height)
        thumbnailsScroll.contentSize = CGSize(width: thumbnailWith * CGFloat(pages.count), height: thumbnailsScroll.bounds.height)
        
        for i in 0...(pages.count - 1){
            let image = UIImage(data: pages[i])
            
            let imageViewForMainScroll = UIImageView(frame: CGRect(x: mainScrollView.bounds.width * CGFloat(i), y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height))
            
            imageViewForMainScroll.image = image
            imageViewForMainScroll.contentMode = .scaleAspectFit
            
            mainScrollView.addSubview(imageViewForMainScroll)
            
            let imageViewForThumbScroll = UIImageView(frame: CGRect(x:thumbnailWith * CGFloat(i), y: 0, width: thumbnailWith, height: thumbnailsScroll.bounds.height))
            
            imageViewForMainScroll.image = image
            imageViewForMainScroll.contentMode = .scaleAspectFit
            
            thumbnailsScroll.addSubview(imageViewForThumbScroll)
            
        }
        
    }
    

    

}
