//
//  NowPlayingViewController.swift
//  MovieViewer
//
//  Created by Patwardhan, Saurabh on 10/13/16.
//  Copyright © 2016 Saurabh Patwardhan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let LAUNCHED_BEFORE = "LAUNCHED BEFORE"
    let VIEW_PREFERENCE = "VIEW PREFERENCE"
    let LIST = "LIST"
    let GRID = "GRID"
    
    var movies : [NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var endpoint : String!
    //let searchBar = UISearchBar()
    let defaults = UserDefaults.standard
    var shouldShowSearchResults = false
    var isList : Bool!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    func createSearchBar(){
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.placeholder = "Search movies"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        
        /*
        let isFirstLaunch = !defaults.bool(forKey: LAUNCHED_BEFORE)
        if isFirstLaunch {
            isList = true
            defaults.set(isList, forKey: VIEW_PREFERENCE)
            defaults.set(true, forKey: LAUNCHED_BEFORE)
        }else {
            isList = defaults.bool(forKey: VIEW_PREFERENCE)
        }
        */
        
        //createInitialView()
        
        self.view.addSubview(self.tableView)
        
        //tableView.insertSubview(refreshControl, at: 0)

        createSearchBar()
        
        networkRequest()
        // Do any additional setup after loading the view.
    }
    
    func createInitialView(){
        if isList == true {
            self.view.addSubview(self.tableView)
            tableView.isHidden = false
            tableView.insertSubview(refreshControl, at: 0)
        } else {
            self.view.addSubview(self.collectionView)
            collectionView.isHidden = false
            collectionView.insertSubview(refreshControl, at: 0)
        }
    }
    
    func switchViews(){
        var fromView : UIView
        var toView : UIView
        
        if(isList == true){
            fromView = self.collectionView
            toView = self.tableView
            
        } else {
            
            fromView = self.tableView
            toView = self.collectionView
            
        }
        
        fromView.isHidden = true
        toView.isHidden = false
        
        //refreshControl.removeFromSuperview()
        //oView.insertSubview(refreshControl, at: 0)
        
        //fromView.removeFromSuperview()
        //self.view.addSubview(toView)
        
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIViewAnimationOptions.transitionFlipFromTop , completion: nil)
        
    }
    
    @IBAction func segmentIndexChanged(_ sender: AnyObject) {
        if(segmentedControl.selectedSegmentIndex == 0){
            isList = true;
            
        }else if (segmentedControl.selectedSegmentIndex == 1){
            isList = false
        }
        switchViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return safeValueReturn()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return safeValueReturn()
    }
    
    func safeValueReturn() -> Int {
        if let movies = movies {
            if shouldShowSearchResults{
                return (filteredMovies?.count)!
            }
            else {
                return movies.count
            }
        }else {
            return 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies?.filter({(movie: NSDictionary) -> Bool in
            let movieTitle = movie["title"] as! String
            return movieTitle.lowercased().range(of: searchText.lowercased()) != nil
            
        })
        
        if searchText != ""{
            shouldShowSearchResults = true
            tableView.reloadData()
        } else {
            shouldShowSearchResults = false
            tableView.reloadData()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        networkRequest()
    }
    
    func networkRequest(){
        print ("endpoint: " , endpoint)
        let apiKey = "2bc27eecd1ba89ce134f4ff3d131d126"
        let urlString = "https://api.themoviedb.org/3/movie/\(self.endpoint!)?api_key=\(apiKey)"
        let url = URL(string : urlString)
        let request = URLRequest(url: url!)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 5.0
        let session = URLSession(configuration : sessionConfig,delegate: nil,delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: {(dataOrNil, response, error)  in
            if let data = dataOrNil {
                if let responseDictionary = try!
                    JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{NSLog("responses \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    
                    self.refreshView()
                    
                    self.hideNetworkErrorView(hide: true)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    // Tell the refreshControl to stop spinning
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.hideNetworkErrorView(hide: false)
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        });
        task.resume()
    }
    
    func refreshView(){
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    func hideNetworkErrorView(hide : Bool){
        self.networkErrorView.isHidden = hide
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCollectionCell", for: indexPath as IndexPath) as! NowPlayingCollectionViewCell
        
        
        let movie = movies?[indexPath.row]
        
        if let posterPath = movie?["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w92"
            let posterUrl = URL(string: posterBaseUrl + posterPath)
            let posterRequest = URLRequest(url: posterUrl!)
            
            cell.collectionPosterView.setImageWith(posterRequest, placeholderImage: nil, success: {(request:URLRequest,response:HTTPURLResponse?, image:UIImage!) -> Void in
                if image != nil {
                    cell.collectionPosterView.alpha = 0.0
                    cell.collectionPosterView.image = image
                    UIView.animate(withDuration: 0.3 , animations: {() -> Void in
                        cell.collectionPosterView.alpha = 1
                    })
                } else {
                    cell.collectionPosterView.image = image
                }
                }, failure: {(request:URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                    print("setImage AFNetworking received error")
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.collectionPosterView.image = nil
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPlayingCell", for: indexPath) as! NowPlayingViewCell
        let movie : NSDictionary!
        
        if shouldShowSearchResults {
            movie = filteredMovies?[indexPath.row]
        } else {
            movie = movies?[indexPath.row]
        }
        
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        
        if let posterPath = movie?["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w92"
            let posterUrl = URL(string: posterBaseUrl + posterPath)
            let posterRequest = URLRequest(url: posterUrl!)
            
            cell.posterView.setImageWith(posterRequest, placeholderImage: nil, success: {(request:URLRequest,response:HTTPURLResponse?, image:UIImage!) -> Void in
                if image != nil {
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animate(withDuration: 0.3 , animations: {() -> Void in
                        cell.posterView.alpha = 1
                    })
                } else {
                    cell.posterView.image = image
                }
                }, failure: {(request:URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                    print("setImage AFNetworking received error")
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath! as NSIndexPath).row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
    }
}
