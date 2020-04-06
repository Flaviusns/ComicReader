//
//  ViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var comics = [Comic]()
    var selectedComic : Comic? = nil
    var selectedComics = [String]()
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ComicReaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var comicsFinder :ComicFinder!
    
    var filtered:[Comic] = []
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    var refresher:UIRefreshControl!
    lazy var done: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(entryEditMode))
    }()
    lazy var trash : UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(removeSelection))
    }()
    lazy var edit : UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(entryEditMode))
    }()
    
    enum viewMode {
        case view
        case edit
    }
    
    var viewM: viewMode = .view {
        didSet{
            switch viewM {
            case .view:
                navigationItem.rightBarButtonItem = nil
                navigationItem.leftBarButtonItem = edit
                collectionView.allowsMultipleSelection = false
            case .edit:
                navigationItem.rightBarButtonItem = done
                navigationItem.leftBarButtonItem = trash
                collectionView.allowsMultipleSelection = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        navigationItem.title = "My Comics"
        
        collectionView.allowsSelection = true
        comicsFinder = ComicFinder(container: persistentContainer)
        
        comics = comicsFinder.getSavedComics()
        
        
        DispatchQueue.global(qos: .background).async {
            self.comicsFinder.updateStorageComics()
            self.comics = self.comicsFinder.getSavedComics()
        }
        
        
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for comics"
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.searchController = searchController
        
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.refreshControl = refresher
        collectionView.addSubview(refresher)
        
        viewM = .view
    
    }
    
    
       
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        else
        {
            return comics.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComicMin", for: indexPath) as? ComicMiniature else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let comic = comics[indexPath.item]
        
        cell.ComicName.text = comic.name
        
        
        cell.ComicImage.image = UIImage(data: comic.comicsPages![0])
        
        cell.ComicImage.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.ComicImage.layer.borderWidth = 2
        cell.ComicImage.layer.cornerRadius = 3
        
        if viewM == .edit{
            cell.FavButton.isHidden = false
            cell.SelectedButton.isHidden = false
        }else{
            cell.FavButton.isHidden = true
            cell.SelectedButton.isHidden = true
        }
        
        return cell
    }
        
    @objc func addToSelection(_ sender: UIButton){
        
        guard let comic = sender.superview as? ComicMiniature else{
            fatalError("Unable to convert the comic")
        }
        if #available(iOS 13.0, *) {
            if(selectedComics.contains(comic.ComicName.text!)){
                let configuration = UIImage.SymbolConfiguration(weight: .bold)
                sender.setImage(UIImage(systemName: "circle",withConfiguration: configuration), for: .normal)
                let index = selectedComics.firstIndex(of: comic.ComicName.text!)!
                selectedComics.remove(at: index)
            }else{
                let configuration = UIImage.SymbolConfiguration(weight: .bold)
                selectedComics.append(comic.ComicName.text!)
                sender.setImage(UIImage(systemName: "circle.fill",withConfiguration: configuration), for: .normal)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func entryEditMode(){
        viewM = viewM == .view ? .edit : .view
        collectionView.reloadData()
    }
    
    
    @objc func removeSelection(){
        for comicName in selectedComics {
            if(comicsFinder.removeComic(comicToRemoveName: comicName)){
                for comic in comics{
                    if comic.name == comicName{
                        let index = self.comics.firstIndex(of: comic)!
                        self.comics.remove(at: index)
                    }
                }
            }
        }
        
        self.collectionView.reloadData()
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
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchString = searchController.searchBar.text
        
        filtered = comics.filter({ (item) -> Bool in
            let comicName: NSString = item.name as NSString
            
            return (comicName.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        collectionView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    @objc func loadData() {
        self.comicsFinder.updateStorageComics()
        self.comics = self.comicsFinder.getSavedComics()
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewM {
        case .view:
            selectedComic = comics[indexPath[1]]
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                nextVC.comic = selectedComic
                navigationController?.pushViewController(nextVC, animated: true)
            }
        default:
            print("Default")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch viewM {
        case .view:
            print("No Select")
        default:
            print("Default")
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
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            
            // "puppers" is the array backing the collection view
            return self.makeContextMenu(comic: self.comics[indexPath.row])
        })
    }

    @available(iOS 13.0, *)
    func makeContextMenu(comic: Comic) -> UIMenu {
        
        // Create a UIAction for sharing
        let share = UIAction(title: "Add to favorites", image: UIImage(systemName: "heart")) { action in
            // Show system share sheet
        }
        
        let deleted = UIAction(title: "Delete Comic", image: UIImage(systemName: "trash")) { action in
            // Show system share sheet
            if(!self.comicsFinder.removeComic(comicToRemove: comic)){
                let alert = UIAlertController(title: "Unable to delete the comic", message: "The app cannot delete the comic.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                let index = self.comics.firstIndex(of: comic)!
                self.comics.remove(at: index)
                self.collectionView.reloadData()
            }
        }
        
        // Create and return a UIMenu with the share action
        return UIMenu(title: comic.name, children: [share,deleted])
    }
}

