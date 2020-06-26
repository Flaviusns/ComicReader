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
        
        navigationItem.title = comic?.name
        navigationItem.largeTitleDisplayMode = .never
        
        self.tabBarController?.tabBar.isHidden = true
        
        createMainAndThumbsScrollView()
        
        self.view.bringSubviewToFront(thumbnailsScroll)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        comic?.comicsPages = ComicFinder.getComicPages(file: comic!)
        addPagesToView(pages: (comic?.comicsPages)!)
        
    }
    
    
    func createMainAndThumbsScrollView(){
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.delegate = self
        mainScrollView.minimumZoomScale = 1.0
        mainScrollView.maximumZoomScale = 4.0
        mainScrollView.zoomScale = 1.0
        mainScrollView.isPagingEnabled = true
        
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
            thumbnailsScroll.heightAnchor.constraint(equalToConstant: 75),
            
            mainScrollView.bottomAnchor.constraint(equalTo: thumbnailsScroll.topAnchor)
        ])
        
    }
    
    func addPagesToView(pages: [Data]){
        
        totalWidth = self.view.bounds.width * CGFloat(pages.count)
        
        mainScrollView.contentSize = CGSize(width: totalWidth, height: self.view.bounds.height)
        thumbnailsScroll.contentSize = CGSize(width: thumbnailWith * CGFloat(pages.count), height: 75)

        for i in 0...(pages.count - 1){
            let image = UIImage(data: pages[i])
            
            let imageViewForMainScroll = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            
            imageViewForMainScroll.image = image
            imageViewForMainScroll.contentMode = .scaleAspectFit
            
            let pageScroll = UIScrollView(frame: CGRect(x:self.view.bounds.width * CGFloat(i), y: 0, width: imageViewForMainScroll.bounds.width, height: imageViewForMainScroll.bounds.height))
            
            pageScroll.minimumZoomScale = 1.0
            pageScroll.maximumZoomScale = 4.0
            pageScroll.zoomScale = 1.0
            pageScroll.isUserInteractionEnabled = true
            pageScroll.delegate = self
            
            pageScroll.addSubview(imageViewForMainScroll)
            
            mainScrollView.addSubview(pageScroll)
            
            let imageViewForThumbScroll = UIImageView(frame: CGRect(x:thumbnailWith * CGFloat(i), y: 0, width: thumbnailWith, height: 75))
            
            imageViewForThumbScroll.image = image
            imageViewForThumbScroll.contentMode = .scaleAspectFit
            
            thumbnailsScroll.addSubview(imageViewForThumbScroll)
            
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        if(scrollView.subviews.count > 0){
            return scrollView.subviews[0]
        }
        return nil
    }
    

    

}
