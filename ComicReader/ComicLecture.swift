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
    let thumbnailWith : CGFloat = 50.0
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var scrollView: UIScrollView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = comic?.name ?? "Nulo"
        
        comic?.comicsPages = ComicFinder.getComicPages(fileName: comic!.name)

        prepareScrollView()
        createthumbNails()
        
        self.view.bringSubviewToFront(bottomView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ComicFinder.removeTempComic(fileName: comic!.name)
    }
    
    func prepareScrollView(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideNavigationItem))
        
        let tapBottom = UITapGestureRecognizer(target: self, action: #selector(changePageFromThumbnail))
        
        scrollView.addGestureRecognizer(tap)
        bottomView.addGestureRecognizer(tapBottom)
        
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
    
    func createthumbNails(){
        
        
        let bottomScrollView = UIScrollView(frame: CGRect(x: 5, y: 0, width: bottomView.frame.size.width - thumbnailWith, height: bottomView.frame.size.height))
        bottomScrollView.contentSize = CGSize(width: thumbnailWith * CGFloat((comic?.comicsPages!.count)!), height: bottomView.frame.size.height)
        
        for i in 0...((comic?.comicsPages!.count)! - 1){
            let image = UIImage(data: (comic?.comicsPages![i])!)
            let imageView = UIImageView(frame: CGRect(x: thumbnailWith * CGFloat(i), y: 0, width: 50, height: 75))
            
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            
            bottomScrollView.addSubview(imageView)
        }
        
        bottomView.addSubview(bottomScrollView)
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
        bottomView.isHidden = hideNavBar
    }
    
    @objc func changePageFromThumbnail(sender: UITapGestureRecognizer){
        
        let positionX = sender.location(in: bottomView.subviews[0]).x
        let page = Int((positionX / thumbnailWith).rounded(.down))
        scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat(page) * self.view.bounds.size.width),y: 0), animated: true)
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

