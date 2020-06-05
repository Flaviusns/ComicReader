//
//  ViewController.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class ViewController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, SFSafariViewControllerDelegate {
    //MARK: View Variables
    var comics = [Comic]()
    var selectedComic : Comic? = nil
    var selectedComics = [String]()
    var favSelected = false
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
    lazy var share: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
    }()
    lazy var filter: UIBarButtonItem = {
        let image = self.favSelected ? UIImage(named: "FavSelectedMini") : UIImage(named: "FavUnselectedMini")
        return UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(getFavorites))
    }()
    enum viewMode {
        case view
        case edit
    }
    
    var viewM: viewMode = .view {
        didSet{
            switch viewM {
            case .view:
                navigationItem.rightBarButtonItem = filter
                navigationItem.leftBarButtonItems = [edit]
                collectionView.allowsMultipleSelection = false
            case .edit:
                navigationItem.rightBarButtonItem = done
                navigationItem.leftBarButtonItems = [trash,share]
                collectionView.allowsMultipleSelection = true
            }
        }
    }
    
    var settings:ComicReaderAppSettings!
    
    
    var presentErrorinFile = false {
        didSet{
            if presentErrorinFile==true{
                let alert = UIAlertController(title: NSLocalizedString("ErrorInFile", comment: "Error in file title in the alert"), message: NSLocalizedString("InvalidFileMessage", comment: "Error in file message in the alert"), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("MoreInfo", comment: "More info button in the alert"), style: .default, handler: {
                    _ in
                    let urlString = "https://www.apple.com/"
                    
                    if let url = URL(string: urlString) {
                        let vc = SFSafariViewController(url: url)
                        vc.delegate = self
                        
                        self.present(vc, animated: true)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: nil))
                self.present(alert, animated: true)
                }
        }
    }
    
    //MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        ]
        navigationItem.title = NSLocalizedString("MyComics", comment: "My comics title for the collection view")
        
        collectionView.allowsSelection = true
        comicsFinder = ComicFinder(container: persistentContainer)
        
        comics = comicsFinder.getSavedComics()
        
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = NSLocalizedString("SearchComic", comment: "Search comic placeholder inside the collection view")
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.searchController = searchController
        
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.refreshControl = refresher
        collectionView.addSubview(refresher)
        
        viewM = .view
        
        settings = ComicReaderAppSettings(container: persistentContainer)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.comicsFinder.updateStorageComics()
            self.comicsFinder.removeComicsNoLongerExist()
            self.comics = self.comicsFinder.getSavedComics()
            if self.settings.getValueFromKey(key: "orderby") == 0{
                self.comics.sort()
            }
            DispatchQueue.main.async {
                if self.comicsFinder.getErrorInFile(){
                    self.presentErrorinFile = true
                }else{
                    self.presentErrorinFile = false
                }
                self.collectionView.reloadData()
            }
        }
        self.tabBarController?.tabBar.isHidden = false

    }
    
    func forceUpdate(){

        self.comicsFinder.updateStorageComics()
        self.comicsFinder.removeComicsNoLongerExist()
        self.comics = self.comicsFinder.getSavedComics()
        if self.settings.getValueFromKey(key: "orderby") == 0{
            self.comics.sort()
            
            
            if self.comicsFinder.getErrorInFile(){
                self.presentErrorinFile = true
            }else{
                self.presentErrorinFile = false
            }
            self.collectionView.reloadData()
            
        }
    }
    
    
    //MARK: override CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            if filtered.count == 0 {
                collectionView.setEmptyView(title: NSLocalizedString("NoItemMatch", comment: "No item match text as title when the search collection it's empty"), message: NSLocalizedString("NoItemMatchMessage", comment: "No item match text as message when the search collection it's empty"))
            } else {
                collectionView.restore()
            }
            return filtered.count
        }
        else
        {
            if favSelected {
                if comics.count == 0 {
                    collectionView.setEmptyView(title: NSLocalizedString("NotFavorites", comment: "Not favorite text as title when the favorite collection it's empty"), message: NSLocalizedString("NotFavoritesMessage", comment: "Not favorite text as message when the favorite collection it's empty"))
                } else {
                    collectionView.restore()
                }
            }else{
                if comics.count == 0 {
                    collectionView.setEmptyView(title: NSLocalizedString("EmptyCollection", comment: "Empty collection text as title when the main collection it's empty"), message: NSLocalizedString("EmptyCollectionMessage", comment: "Empty collection text as message when the main collection it's empty"))
                } else {
                    collectionView.restore()
                }
            }
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
        }else{
            cell.FavButton.isHidden = true
        }
        
        cell.FavButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        cell.FavButton.setImage(comic.favourite ? UIImage(named: "FavSelected") : UIImage(named: "FavUnselected"), for: .normal)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewM {
        case .view:
            selectedComic = comics[indexPath[1]]
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ComicLectureTop") as? ComicLecture {
                nextVC.comic = selectedComic
                nextVC.comicFinder = comicsFinder
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
    
    //MARK: Bar Operations
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
    
    @objc func shareSelection(){
        
        var filesURL = [NSURL]()
        for comicName in selectedComics {
            let path = self.comicsFinder.getPathofComic(comicName: comicName)
            filesURL.append(NSURL.fileURL(withPath: path) as NSURL)
        }
        
        let vc = UIActivityViewController(activityItems: filesURL, applicationActivities: nil)
        self.present(vc, animated: true)
    }
    
    
    @objc func addToFavorites(_ sender: UIButton){
        guard let comicCell = sender.superview?.superview as? ComicMiniature else{
            fatalError("Unable to convert the comic")
        }
        
        let comic = comics.first(where: {$0.name == comicCell.ComicName.text!})
        self.comicsFinder.toggleFavComic(comicName: comic!.name)
        if comic!.favourite{
            sender.setImage(UIImage(named: "FavUnselected"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "FavSelected"), for: .normal)
        }
        comic?.favourite.toggle()
    }
    
    @objc func getFavorites(){
        favSelected.toggle()
        
        if favSelected{
            comics = comicsFinder.getFavComics()
            navigationItem.rightBarButtonItem?.image = UIImage(named: "FavSelectedMini")
            collectionView.reloadData()
        }else{
            comics = comicsFinder.getSavedComics()
            navigationItem.rightBarButtonItem?.image = UIImage(named: "FavUnselectedMini")
            collectionView.reloadData()
        }
        
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
        self.selectedComics.removeAll()
        self.comicsFinder.updateStorageComics()
        self.comics = self.comicsFinder.getSavedComics()
        if self.comicsFinder.getErrorInFile(){
            self.presentErrorinFile = true
        }else{
            self.presentErrorinFile = false
        }
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    func reloadData(){
        DispatchQueue.global(qos: .background).async {
            self.comicsFinder.updateStorageComics()
            self.comicsFinder.removeComicsNoLongerExist()
            self.comics = self.comicsFinder.getSavedComics()
            DispatchQueue.main.async {
                if self.comicsFinder.getErrorInFile(){
                    self.presentErrorinFile = true
                }else{
                    self.presentErrorinFile = false
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Safari view
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
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
        
        
        let favourite = UIAction(title: comic.favourite ? NSLocalizedString("RemoveFavourite", comment: "Remove Favourite text for the 3DTouch option") : NSLocalizedString("AddFavourite", comment: "Add favourite text for the 3DTouch option"), image: comic.favourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")) { action in
            if comic.favourite{
                self.comicsFinder.toggleFavComic(comicName: comic.name)
                comic.favourite = false
            }else{
                self.comicsFinder.toggleFavComic(comicName: comic.name)
                comic.favourite = true
            }
        }
        if let image = UIImage(named: "myImage") {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            present(vc, animated: true)
        }
        
        let share = UIAction(title: NSLocalizedString("Share", comment: "Share text for the 3DTouch option"), image: UIImage(systemName: "square.and.arrow.up")) { action in
            let path = self.comicsFinder.getPathofComic(comicName: comic.name)
            
                let url = NSURL.fileURL(withPath: path)
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                self.present(vc, animated: true)
            
        }
        
        let deleted = UIAction(title: NSLocalizedString("DeleteComic", comment: "Delete text for the 3DTouch option"), image: UIImage(systemName: "trash")) { action in
            // Show system share sheet
            if(!self.comicsFinder.removeComic(comicToRemove: comic)){
                let alert = UIAlertController(title: NSLocalizedString("UnableDelete", comment: "Unable to delete comic alert title"), message: NSLocalizedString("UnableDeleteMessage", comment: "Unable to delete comic alert message"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Okay option inside the alert"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                let index = self.comics.firstIndex(of: comic)!
                self.comics.remove(at: index)
                self.collectionView.reloadData()
            }
        }
        
        // Create and return a UIMenu with the share action
        return UIMenu(title: comic.name, children: [favourite,share,deleted])
    }
}

// MARK: UICollectionView extension
extension UICollectionView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .systemGray
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        messageLabel.textColor = .systemGray
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .thin)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
    }
    func restore() {
        self.backgroundView = nil
    }
}

