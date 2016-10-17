//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Patwardhan, Saurabh on 10/13/16.
//  Copyright © 2016 Saurabh Patwardhan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actor1ImageView: UIImageView!
    @IBOutlet weak var actor2ImageView: UIImageView!
    @IBOutlet weak var actor3ImageView: UIImageView!
    @IBOutlet weak var actor4ImageView: UIImageView!
    
    
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.8)
        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + 30)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView.center.y = 600
            }, completion: nil)
        
        circleImageView()
        
        updateLabels(movie: movie)
        
        getMovieDetails()
        
        getMovieCast(movie: movie)
        
        // Do any additional setup after loading the view.
    }
    
    func circleImageView(){
        actor1ImageView.asCircle()
        actor2ImageView.asCircle()
        actor3ImageView.asCircle()
        actor4ImageView.asCircle()
    }
    
    func getMovieCast(movie : NSDictionary){
        
        var cast = [NSDictionary]()
        let movieId = movie["id"] as? Double
        let apiKey = "2bc27eecd1ba89ce134f4ff3d131d126"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId!)/credits?api_key=\(apiKey)"
        print(urlString)
        let url = URL(string : urlString)
        let request = URLRequest(url: url!)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 5.0
        let session = URLSession(configuration : sessionConfig,delegate: nil,delegateQueue: OperationQueue.main)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: {(dataOrNil, response, error)  in
            if let data = dataOrNil {
                if let responseDictionary = try!
                    JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{
                    
                    cast = responseDictionary["cast"] as! [NSDictionary]
                    print(cast)
                    
                    self.loadCastImages(cast: cast)
                    
                }
            } else {
                
                
            }
            
        });
        task.resume()
        
        
    }
    
    func getMovieDetails(){
        
        var fullMovie =  NSDictionary()
        let movieId = movie["id"] as? Double
        let apiKey = "2bc27eecd1ba89ce134f4ff3d131d126"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId!)?api_key=\(apiKey)"
        print(urlString)
        let url = URL(string : urlString)
        let request = URLRequest(url: url!)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 5.0
        let session = URLSession(configuration : sessionConfig,delegate: nil,delegateQueue: OperationQueue.main)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: {(dataOrNil, response, error)  in
            if let data = dataOrNil {
                if let responseDictionary = try!
                    JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{
                    
                    fullMovie = responseDictionary
                    self.movie = fullMovie
                    self.showExtraDetails(movie: self.movie)
                    
                }
            } else {
                
                
            }
            
        });
        task.resume()
    }
    
    func showExtraDetails(movie : NSDictionary){
        let fullMovie = movie
        
        if let runTime = fullMovie["runtime"] as? Int{
            let runTimeString = String(format: "%d hr %d mins", runTime/60, runTime % 60)
            timeLabel.text = runTimeString
        }
    }
    
    func loadCastImages(cast : [NSDictionary]){
        
        let cast1 = cast[0]
        let cast2 = cast[1]
        let cast3 = cast[2]
        let cast4 = cast[3]
        
        let cast1Pic = cast1["profile_path"]
        let cast2Pic = cast2["profile_path"]
        let cast3Pic = cast3["profile_path"]
        let cast4Pic = cast4["profile_path"]
        
        
        insertCastPic(picExtension: cast1Pic as! String, imageView: actor1ImageView)
        insertCastPic(picExtension: cast2Pic as! String, imageView: actor2ImageView)
        insertCastPic(picExtension: cast3Pic as! String, imageView: actor3ImageView)
        insertCastPic(picExtension: cast4Pic as! String, imageView: actor4ImageView)
    }
    
    
    func insertCastPic(picExtension: String, imageView : UIImageView){
        let posterPath = picExtension
        let posterBaseUrlSmallImage = "http://image.tmdb.org/t/p/w45"
        let posterUrlSmallImage = URL(string: posterBaseUrlSmallImage + posterPath)
        imageView.setImageWith(posterUrlSmallImage!)
    }
    
    
    
    func updateLabels(movie : NSDictionary){
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let releaseDate = formatter.date(from: (movie["release_date"] as? String)!)
        
        formatter.dateFormat = "MMMM dd, yyyy"
        let dateString = formatter.string(from: releaseDate!)
        
        releaseLabel.text = dateString
        
        let voteAverge = movie["vote_average"] as? Float
        
        percentLabel.text = "\(voteAverge! * 10) %"
        titleLabel.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrlSmallImage = "http://image.tmdb.org/t/p/w45"
            let posterUrlSmallImage = URL(string: posterBaseUrlSmallImage + posterPath)
            //posterImageView.setImageWith(posterUrl!)
            let posterRequestSmallImage = URLRequest(url: posterUrlSmallImage!)
            
            let posterBaseUrlLargeImage = "http://image.tmdb.org/t/p/original"
            let posterUrlLargeImage = URL(string: posterBaseUrlLargeImage + posterPath)
            let posterRequestLargeImage = URLRequest(url: posterUrlLargeImage!)
            
            
            posterImageView.setImageWith(posterRequestSmallImage, placeholderImage: nil, success: {(request:URLRequest,response:HTTPURLResponse?, smallImage:UIImage!) -> Void in
                if smallImage != nil {
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage
                    
                    self.actor1ImageView.image = smallImage
                    
                    UIView.animate(withDuration: 0.3 , animations: {() -> Void in
                        self.posterImageView.alpha = 1
                        },completion: {(true) -> Void in
                            
                            self.posterImageView.setImageWith(posterRequestLargeImage, placeholderImage: smallImage, success: {(request:URLRequest,response:HTTPURLResponse?, largeImage:UIImage!) -> Void in
                                
                                if largeImage != nil{
                                    self.posterImageView.image = largeImage
                                }
                                
                                }, failure: {(request:URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                                    print("setImage AFNetworking received error")
                            })
                            
                    } )
                } else {
                    //cell.posterView.image = image
                }
                }, failure: {(request:URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                    print("setImage AFNetworking received error")
            })
            
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            posterImageView.image = nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UIImageView{
    
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0;
        /*
         self.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 1.0)
         self.isOpaque = true
         self.alpha = 1.0
         */
    }
    
}
