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

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var movies : [NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var endpoint : String!
    let searchBar = UISearchBar()
    var shouldShowSearchResults = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    func createSearchBar(){
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.placeholder = "Search movies"
        self.navigationItem.titleView = searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        createSearchBar()
        
        tableView.insertSubview(refreshControl, at: 0)
        
        networkRequest()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                    self.tableView.reloadData()
                    
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
