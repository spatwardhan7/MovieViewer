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
    
    
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + 30)
        
        
        UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView.center.y = 600
            }, completion: nil)
        
        setDetails(movie: movie)
        
        // Do any additional setup after loading the view.
    }
    
    func setDetails(movie : NSDictionary){
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
