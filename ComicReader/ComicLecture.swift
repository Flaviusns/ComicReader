//
//  ComicLectureViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ComicLecture: UIViewController,UIScrollViewDelegate {
    
    var comic: Comic? = nil
    var currentPage = 0
    var hideNavBar = false
    var totalWidth : CGFloat = 0.0
    
    @IBOutlet var scrollView: UIScrollView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = comic?.name ?? "Nulo"
        
        comic?.comicsPages = ComicFinder.getComicPages(fileName: comic!.name)

        prepareScrollView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ComicFinder.removeTempComic(fileName: comic!.name)
    }
    
    func prepareScrollView(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideNavigationItem))
        
        
        scrollView.addGestureRecognizer(tap)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        
                
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        totalWidth = width * CGFloat((comic?.comicsPages!.count)!)
        scrollView.contentSize = CGSize(width: totalWidth, height: height)
        scrollView.isPagingEnabled = true
        
        loadPages(width: self.view.bounds.size.width, heigth: self.view.bounds.size.height)

    }
    
    func loadPages(width: CGFloat,heigth: CGFloat){
        
        for view in scrollView.subviews{
            for subView in view.subviews{
                subView.removeFromSuperview()
            }
            view.removeFromSuperview()
        }
        
        for i in 0...((comic?.comicsPages!.count)! - 1){
            
            let pageScroll = UIScrollView(frame: CGRect(x: width * CGFloat(i), y: self.view.frame.origin.y, width: width, height: heigth))
            
            pageScroll.minimumZoomScale = 1.0
            pageScroll.maximumZoomScale = 4.0
            pageScroll.zoomScale = 1.0
            pageScroll.isUserInteractionEnabled = true
            pageScroll.delegate = self
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: heigth))
            imageView.image = UIImage(data: (comic?.comicsPages![i])!)
            imageView.contentMode = .scaleAspectFit
            
            pageScroll.addSubview(imageView)
            scrollView.addSubview(pageScroll)
        }
    }
    
    @objc func hideNavigationItem(){
        
        hideNavBar.toggle()
        navigationController?.setNavigationBarHidden(hideNavBar, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideNavBar
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        if(scrollView.subviews.count > 0){
            return scrollView.subviews[0]
        }
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            loadPages(width: size.width, heigth: size.height)
        } else {
            loadPages(width: size.width, heigth: size.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < totalWidth){
            let realPage = scrollView.contentOffset.x / self.view.bounds.width
            if(Int(realPage.rounded(.down)) != currentPage){
                currentPage = Int(realPage.rounded(.down))
                print(currentPage)
            }
        }
    }
}

