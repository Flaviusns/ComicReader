//
//  ComicLectureViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit

class ComicLecture: UIViewController {
    
    var comic: Comic? = nil
    var currentPage = 0
    
    @IBOutlet var ComicPage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ComicPage.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        print("My comic is: " + (comic?.name ?? "Nulo"))
        
        ComicPage.image = UIImage(data: (comic?.comicsPages![0])!)
        let left = UISwipeGestureRecognizer(target : self, action : #selector(nextPage))
        left.direction = .left
        let rigth = UISwipeGestureRecognizer(target : self, action : #selector(lastPage))
        rigth.direction = .right
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        
        ComicPage.addGestureRecognizer(left)
        ComicPage.addGestureRecognizer(rigth)
        ComicPage.addGestureRecognizer(pinchGesture)
        
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
    
        
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

