//
//  ViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import Zip

class ViewController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var comics = [Comic]()
    var selectedComic : Comic? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewComic))
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gesture(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        collectionView?.addGestureRecognizer(tap)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComicMin", for: indexPath) as? ComicMiniature else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let comic = comics[indexPath.item]
        
        cell.ComicName.text = comic.name
        
        
        cell.ComicImage.image = UIImage(named: comic.path)
        
        cell.ComicImage.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.ComicImage.layer.borderWidth = 2
        cell.ComicImage.layer.cornerRadius = 3
                
        return cell
    }
    
    @objc func addNewComic(){
        comics.append(Comic(name: "Spiderman", path: "P1", comicsPages: nil))
        collectionView.reloadData()
    }
    

    
    @IBAction func gesture(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            selectedComic = comics[indexPath[1]]
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                nextVC.comic = selectedComic
                navigationController?.pushViewController(nextVC, animated: true)
                
            }

        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let nextVC = segue.destination as? ComicLecture {
            nextVC.comic = self.selectedComic
        }
    }
    
    
    
    
    

}
extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point),
            let cell = collectionView?.cellForItem(at: indexPath) {
            return touch.location(in: cell).y > 50
        }
        
        return false
    }
}

