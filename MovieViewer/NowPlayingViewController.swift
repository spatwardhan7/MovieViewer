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

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var movies : [NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var endpoint : String!
    var shouldShowSearchResults = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    func createSearchBar(){
        searchBar.barTintColor = UIColor.black
        searchBar.delegate = self
        searchBar.placeholder = "Search movies"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        
        createSearchBar()
        
        initializeFlowLayout()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.insertSubview(refreshControl, at: 0)
        
        networkRequest()
        // Do any additional setup after loading the view.
    }
    
    func initializeFlowLayout(){
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 3, 0, 7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return safeNumberOfRowsInSection()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return safeNumberOfRowsInSection()
    }
    
    func safeNumberOfRowsInSection() -> Int {
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
            reloadData()
        } else {
            shouldShowSearchResults = false
            reloadData()
        }
    }
    
    func reloadData(){
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func showSearchBarCancelButton(show: Bool, searchBar : UISearchBar) {
        searchBar.setShowsCancelButton(show, animated: true)
    }
    
    
    func switchViews(index: Int){
        var fromView : UIView
        var toView : UIView
        
        if (index == 0){
            fromView = self.collectionView
            toView = self.tableView
        }else {
            fromView = self.tableView
            toView = self.collectionView
        }
        
        fromView.isHidden = true
        toView.isHidden = false
        
        refreshControl.removeFromSuperview()
        toView.addSubview(refreshControl)
        
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIViewAnimationOptions.transitionFlipFromBottom, completion: nil)
        
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if(segmentedControl.selectedSegmentIndex == 0) {
            print("Segmented Control value: 0")
            switchViews(index: 0)
        } else {
            print("Segmented Control value: 1")
            switchViews(index: 1)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchBar.endEditing(true)
        reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        shouldShowSearchResults = false
        reloadData()
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
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
                    JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.reloadData()
                    
                    self.hideNetworkErrorView(show: true)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    // Tell the refreshControl to stop spinning
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.hideNetworkErrorView(show: false)
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        });
        task.resume()
    }
    
    func hideNetworkErrorView(show : Bool){
        self.networkErrorView.isHidden = show
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellId", for: indexPath as IndexPath) as! CollectionViewCell
        
        let movie : NSDictionary!
        if shouldShowSearchResults {
            movie = filteredMovies?[indexPath.row]
        } else {
            movie = movies?[indexPath.row]
        }
        
        if let posterPath = movie?["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w92"
            let posterUrl = URL(string: posterBaseUrl + posterPath)
            let posterRequest = URLRequest(url: posterUrl!)
            
            cell.posterImageCollectionViewCell.setImageWith(posterRequest, placeholderImage: nil, success: {(request:URLRequest,response:HTTPURLResponse?, image:UIImage!) -> Void in
                if image != nil {
                    cell.posterImageCollectionViewCell.alpha = 0.0
                    cell.posterImageCollectionViewCell.image = image
                    UIView.animate(withDuration: 0.3 , animations: {() -> Void in
                        cell.posterImageCollectionViewCell.alpha = 1
                    })
                } else {
                    cell.posterImageCollectionViewCell.image = image
                }
                }, failure: {(request:URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                    print("setImage AFNetworking received error")
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterImageCollectionViewCell.image = nil
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
        
        var movie : NSDictionary!
        
        if(segue.identifier == "tableViewSegue"){
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            movie = movies![(indexPath! as NSIndexPath).row]
        } else if (segue.identifier == "collectionViewSeque"){
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            movie = movies![(indexPath! as NSIndexPath).row]
        }
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
    }
    
}
