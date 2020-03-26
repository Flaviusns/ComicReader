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
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var ComicPage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ComicPage.isUserInteractionEnabled = true
        
        
        ComicPage.image = UIImage(data: (comic?.comicsPages![0])!)
        
        
        navigationItem.title = comic?.name ?? "Nulo"
        
        prepareScrollView()
        
    }
    
    func prepareScrollView(){
        
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(nextPage))
        left.direction = .left
        let rigth = UISwipeGestureRecognizer(target : self, action : #selector(lastPage))
        rigth.direction = .right
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideNavigationItem))
        
        //scrollView.addGestureRecognizer(rigth)
        //scrollView.addGestureRecognizer(left)
        scrollView.addGestureRecognizer(tap)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        
        scrollView.contentSize = CGSize(width: width * CGFloat((comic?.comicsPages!.count)!), height: height)
        scrollView.isPagingEnabled = true

    }
    
    func loadPages(){
        for i in 0...(comic?.comicsPages!.count)!{
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(data: (comic?.comicsPages![i])!)
            scrollView.addSubview(imageView)
        }
    }
    
    func imageHeight() -> CGFloat{
        return ComicPage.image?.size.height ?? CGFloat(1200)
    }
    
    func imageWidth() -> CGFloat{
        return ComicPage.image?.size.width ?? CGFloat(1200)
    }
    
    
    @objc func nextPage(){
       
        if(currentPage < (comic?.comicsPages!.count)! - 1){
            currentPage+=1
            ComicPage.image = UIImage(data: (comic?.comicsPages![currentPage])!)
        }
    }
    
    @objc func lastPage(){
        if(currentPage > 0){
            currentPage-=1
            ComicPage.image = UIImage(data: (comic?.comicsPages![currentPage])!)
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
        return ComicPage
    }
    


}

