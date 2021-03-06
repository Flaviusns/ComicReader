//
//  ComicLectureViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData

class ComicLecture: UIViewController,UIScrollViewDelegate {
    
    var comic: Comic? = nil
    var comicFinder: ComicFinder? = nil
    var currentPage = 0
    var hideNavBar = false
    var totalWidth : CGFloat = 0.0
    var thumbnailWith : CGFloat = 50.0
    @IBOutlet var PageIndicator: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ComicReaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        
        
        navigationItem.title = comic?.name ?? "Null"
        navigationItem.largeTitleDisplayMode = .never
        
        
        loadingIndicator.startAnimating()
        self.view.bringSubviewToFront(bottomView)
        self.view.bringSubviewToFront(loadingIndicator)
        
        PageIndicator.textColor = .white
        PageIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        PageIndicator.isHidden = true
        PageIndicator.textAlignment = .center
        PageIndicator.adjustsFontSizeToFitWidth = true
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        comic?.comicsPages = ComicFinder.getComicPages(file: comic!)
        if comic?.comicsPages?.count ?? 0 > 0{
            prepareScrollView()
            createthumbNails(width: self.view.bounds.size.width)
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
            
            PageIndicator.isHidden = false
            currentPage = comic?.lastPage ?? 0
            PageIndicator.text = "\(currentPage + 1) \(NSLocalizedString("Of", comment: "Of keyword betwen the numbers of actual and total comic pages")) \((comic?.comicsPages!.count)!)"
            scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat(currentPage) * self.view.bounds.size.width),y: 0), animated: true)
            if self.view.bounds.width < ((CGFloat((self.comic?.comicsPages!.count)! - 1)) * self.thumbnailWith){
                let subscrollView = self.bottomView.subviews[0] as! UIScrollView
                subscrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat(currentPage) * self.thumbnailWith),y: 0), animated: true)
            }
            self.view.bringSubviewToFront(PageIndicator)
        }else{
            let alert = UIAlertController(title: NSLocalizedString("ComicNoLongerExistTitle", comment: "Alert title when the comic was erased"), message: NSLocalizedString("ComicNoLongerExistTitle", comment: "Alert message when the comic was erased"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: {(action:UIAlertAction!) in
                _ = self.navigationController?.popViewController(animated: true)
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if comic?.comicsPages?.count ?? 0 > 0{
            comicFinder?.container = persistentContainer
            comicFinder?.saveLastPage(comicName: comic!.name, lastPage: currentPage + 1 == (comic?.comicsPages!.count)! ? 0 : currentPage)
            comicFinder?.setLastComicRead(comicName: comic!.name)
            ComicFinder.removeTempComic(fileName: comic!.name)
        }
        
        super.viewWillDisappear(true)
        
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
    
    func createthumbNails(width: CGFloat){
        
        
            for view in self.bottomView.subviews{
                for subView in view.subviews{
                    subView.removeFromSuperview()
                }
                view.removeFromSuperview()
            }
            
            
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                let pageNumbInCGFloat = (self.comic?.comicsPages!.count)!
                self.thumbnailWith = (width - self.thumbnailWith) / CGFloat(pageNumbInCGFloat)
            }else{
                self.thumbnailWith = 50
            }
            
            let bottomScrollView = UIScrollView(frame: CGRect(x: self.thumbnailWith / 3, y: 0, width: width - self.thumbnailWith, height: self.bottomView.frame.size.height))
            bottomScrollView.contentSize = CGSize(width: self.thumbnailWith * CGFloat((self.comic?.comicsPages!.count)!), height: self.bottomView.frame.size.height)
            
            for i in 0...((self.comic?.comicsPages!.count)! - 1){
                let image = UIImage(data: (self.comic?.comicsPages![i])!)
                let imageView = UIImageView(frame: CGRect(x: self.thumbnailWith * CGFloat(i), y: 0, width: 50, height: 75))
                
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                
                bottomScrollView.addSubview(imageView)
            }
        
        if width >= ((CGFloat((self.comic?.comicsPages!.count)! - 1)) * self.thumbnailWith){
            bottomScrollView.isDirectionalLockEnabled = true
        }else{
            bottomScrollView.isDirectionalLockEnabled = false
        }
        self.bottomView.addSubview(bottomScrollView)
    }
    
    func loadPages(width: CGFloat,heigth: CGFloat){
        
        for view in scrollView.subviews{
            for subView in view.subviews{
                subView.removeFromSuperview()
            }
            view.removeFromSuperview()
        }
        
        totalWidth = width * CGFloat((comic?.comicsPages!.count)!)
        scrollView.contentSize = CGSize(width: totalWidth, height: heigth)
        
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
        PageIndicator.isHidden = hideNavBar
    }
    
    @objc func changePageFromThumbnail(sender: UITapGestureRecognizer){
        
        let positionX = sender.location(in: bottomView.subviews[0]).x
        let page = Int((positionX / thumbnailWith).rounded(.down))
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat(page) * self.view.bounds.size.width),y: 0), animated: true)
        changeCurrentPage(currentPage: page)
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
        loadPages(width: size.width, heigth: size.height)
        createthumbNails(width: size.width)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < totalWidth){
            let realPage = scrollView.contentOffset.x / self.view.bounds.width
            if(Int(realPage.rounded(.down)) != currentPage){
                currentPage = Int(realPage.rounded(.down))
                changeCurrentPage(currentPage: currentPage)
            }
        }
    }
    
    func changeCurrentPage(currentPage: Int){
        PageIndicator.text = "\(currentPage + 1) \(NSLocalizedString("Of", comment: "Of keyword betwen the numbers of actual and total comic pages")) \((comic?.comicsPages!.count)!)"
        if self.view.bounds.width < ((CGFloat((self.comic?.comicsPages!.count)! - 1)) * self.thumbnailWith){
            let subscrollView = self.bottomView.subviews[0] as! UIScrollView
            subscrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat(currentPage) * self.thumbnailWith),y: 0), animated: true)
        }
    }
}

