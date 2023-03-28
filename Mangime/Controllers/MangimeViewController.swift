//
//  ViewController.swift
//  Mangime
//
//  Created by Mesiow on 3/16/23.
//

import UIKit

struct Constants {
    static let reusableCellIdentifier = "ReusableMangimeCell";
    static let cellNibName = "MangimeCell";
    
    static let infoSegueIdentifier = "goToMediaInfo";
}


class MangimeViewController: UIViewController, MangimeManagerDelegate{
    
    //navbar outlets
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var pageNavBar: UINavigationBar!
    @IBOutlet weak var rightArrowItem: UIBarButtonItem!
    @IBOutlet weak var leftArrowItem: UIBarButtonItem!
    @IBOutlet weak var navBarBackgroundView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    let maxCountInView : Int = 5;
    var currentPage : Int = 1; //current page that we are viewing of the searched anime/manga
    var pageCount : Int?; //is set when the model is updated and tells us how many pages of results there are
    var mediaName: String = "";
    
    var fetchedModels : [MangimeModel] = [];
    var mangaSelected : Bool = false;
    var animeSelected : Bool = true;
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var manager = MangimeManager();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUi();
        searchBar.delegate = self;
        
        activityIndicator.isHidden = true;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.reusableCellIdentifier);
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension;
        
        manager.delegate = self;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.infoSegueIdentifier {
            let destinationVC = segue.destination as! MangimeInfoViewController;
            
            let object = sender as! MangimeModel;
            destinationVC.model = object;
        }
    }

    func initUi(){
        searchBar.backgroundImage = UIImage();
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground();
        pageNavBar.standardAppearance = standardAppearance;
        
        navBarBackgroundView.layer.cornerRadius = 10;
      
        navTitle.title = "";
        leftArrowItem.isEnabled = false;
        rightArrowItem.isEnabled = false;
        
        filterButton.showsMenuAsPrimaryAction = true
        filterButton.changesSelectionAsPrimaryAction = false
            
        reloadFilterMenu();
    }
    
    func updateUi(){
        navTitle.title = "\(currentPage) of \(pageCount!)"; //Page count will not be nil once we update the UI
        if pageCount! > currentPage { //enable right arrow is there are available pages to traverse thru
            rightArrowItem.isEnabled = true;
        }
        
        toggleLoadingIndicator(show: false);
        tableView.reloadData();
    }
    
    func reloadFilterMenu(){
        filterButton.menu = UIMenu(children: [
            UIAction(title: "Anime", state: animeSelected ? .on : .off) { _ in
                self.animeSelected = true;
                self.mangaSelected = false;
                self.reloadFilterMenu();
            },
            UIAction(title: "Manga", state: mangaSelected ? .on : .off) { _ in
                self.mangaSelected = true;
                self.animeSelected = false;
                self.reloadFilterMenu();
            }
        ])
    }
    
    func toggleLoadingIndicator(show : Bool){
        if show {
            activityIndicator.isHidden = false;
            activityIndicator.startAnimating();
        }else{
            activityIndicator.isHidden = true;
            activityIndicator.stopAnimating();
        }
    }
    
    
    func didUpdateData(_ mangimeManager : MangimeManager, mangimeModels : [MangimeModel], numberOfPages: Int) {
        //protocol method from mangime manager
        
        self.fetchedModels = mangimeModels; //load current models
        self.pageCount = numberOfPages;
        
        DispatchQueue.main.async {
            //update ui data
            self.updateUi();
        }
    }
    
    func didFailWithInput(error: Error) {
        print("MangimeManager error: \(error)");
    }
    
    func fetchMedia(){
        if fetchedModels.count > 0 { //clear tableview to show loading indicator
            fetchedModels = [];
            tableView.reloadData();
        }
        toggleLoadingIndicator(show: true);
        if animeSelected {
            manager.fetchAnime(name: mediaName, page: currentPage);
        }
        else if mangaSelected {
            manager.fetchManga(name: mediaName, page: currentPage);
        }
    }
    
    func modelSelected(_ model: MangimeModel){
        performSegue(withIdentifier: Constants.infoSegueIdentifier, sender: model);
    }
}


//MARK: - Page navigation
extension MangimeViewController {
    @IBAction func leftPageClicked(_ sender: UIBarButtonItem) {
        if currentPage <= 1 {
            leftArrowItem.isEnabled = false;
            currentPage = 1;
        }else{
            currentPage -= 1;
            rightArrowItem.isEnabled = true;
            if currentPage <= 1 { leftArrowItem.isEnabled = false; }
            
            fetchMedia();
        }
    }
    
    @IBAction func rightPageClicked(_ sender: UIBarButtonItem) {
        if let pgCount = pageCount {
            if currentPage < pgCount {
                currentPage += 1;
                leftArrowItem.isEnabled = true;
                if currentPage >= pgCount { rightArrowItem.isEnabled = false; }
                
                fetchMedia();
            }
        }
    }
}


// MARK: - TableView delegate methods
extension MangimeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedModels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableCellIdentifier, for: indexPath) as! MangimeCell;
        
        let model = fetchedModels[indexPath.row];
        
        cell.titleLabel.text = model.title;
        cell.typeLabel.text = model.type;
        cell.posterView.image = model.image;
        cell.airedLabel.text = model.aired;
      
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        modelSelected(fetchedModels[indexPath.row]);
    }
}


//MARK: - Search Bar delegate methods
extension MangimeViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchBar.resignFirstResponder();
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text != "" {
                mediaName = text;
                fetchMedia();
                
                searchBar.text = nil;
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil;
        searchBar.resignFirstResponder();
    }
}


