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
    //MARK: View Variables
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
    
    //MARK: View Functions
    
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
            self.comicsFinder.removeComicsNoLongerExist()
            self.comics = self.comicsFinder.getSavedComics()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.comicsFinder.updateStorageComics()
            self.comicsFinder.removeComicsNoLongerExist()
            self.comics = self.comicsFinder.getSavedComics()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    //MARK: override CollectionView
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
        
        cell.FavButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        cell.FavButton.setImage(comic.favorite ? UIImage(named: "FavSelected") : UIImage(named: "FavUnselected"), for: .normal)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewM {
        case .view:
            selectedComic = comics[indexPath[1]]
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                nextVC.comic = selectedComic
                navigationController?.pushViewController(nextVC, animated: true)
            }
        case .edit:
            let name = comics[indexPath[1]].name
            selectedComics.append(name)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch viewM {
        case .edit:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComicMin", for: indexPath) as? ComicMiniature else {
                fatalError("Unable to dequeue PersonCell.")
            }
            cell.isSelected = false
            let name = comics[indexPath[0]].name
            if selectedComics.contains(name){
                let pos = selectedComics.firstIndex(of: name)!
                selectedComics.remove(at: pos)
            }
        default:
            print("Default")
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
                        break
                    }
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    
    @objc func addToFavorites(_ sender: UIButton){
        guard let comicCell = sender.superview?.superview as? ComicMiniature else{
            fatalError("Unable to convert the comic")
        }
        
        let comic = comics.first(where: {$0.name == comicCell.ComicName.text!})
        self.comicsFinder.toggleFavComic(comicName: comic!.name)
        if comic!.favorite{
            sender.setImage(UIImage(named: "FavUnselected"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "FavSelected"), for: .normal)
        }
        comic?.favorite.toggle()
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
    
    //MARK: Refresher functions
    @objc func loadData() {
        self.comicsFinder.updateStorageComics()
        self.comics = self.comicsFinder.getSavedComics()
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    
}

//MARK: Extension ViewController
extension ViewController{
    
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
        let favorite = UIAction(title: comic.favorite ? "Remove from favorite" : "Add to favorite", image: comic.favorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")) { action in
            if comic.favorite{
                self.comicsFinder.toggleFavComic(comicName: comic.name)
                comic.favorite = false
            }else{
                self.comicsFinder.toggleFavComic(comicName: comic.name)
                comic.favorite = true
            }
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
        return UIMenu(title: comic.name, children: [favorite,deleted])
    }
}

