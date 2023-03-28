//
//  MangimeInfoViewController.swift
//  Mangime
//
//  Created by Mesiow on 3/24/23.
//

import UIKit
import WebKit

class MangimeInfoViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var airedLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    
    @IBOutlet var viewHeight: [NSLayoutConstraint]!
    @IBOutlet weak var firstStarImage: UIImageView!
    @IBOutlet weak var secondStarImage: UIImageView!
    @IBOutlet weak var thirdStarImage: UIImageView!
    @IBOutlet weak var fourthStarImage: UIImageView!
    @IBOutlet weak var fifthStarImage: UIImageView!
    
    var ratingImages : [UIImageView] = []
    var model : MangimeModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRatingImages();
        
        if let mangimeModel = model {
            if mangimeModel.trailerId != "" {
                loadEmbeddedTrailer(id: mangimeModel.trailerId);
            }else{
                //remove embedded trailer because this is a manga
                webView.removeFromSuperview();
            }
            
            titleLabel.text = mangimeModel.title;
            posterImage.image = mangimeModel.image;
            airedLabel.text = mangimeModel.aired;
            typeLabel.text = mangimeModel.type;
            synopsisLabel.text = mangimeModel.synopsis;
            
            if let score = mangimeModel.score {
                let scoreOutOfFive : Float = (score / 2.0);
                let scoreRounded : Int = Int(scoreOutOfFive.rounded());
                updateRatingImages(scoreRounded);
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        synopsisLabel.numberOfLines = 0;
        synopsisLabel.sizeToFit();
        
        if let mm = model {
            if mm.trailerId == "" {
                viewHeight[0].constant = viewHeight[0].constant - synopsisLabel.frame.height / 2
            }
        }
    }
    
    func loadEmbeddedTrailer(id: String){
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(id)") else
        { return }
        webView.load(URLRequest(url: youtubeURL));
    }
    
    func initRatingImages(){
        ratingImages.append(firstStarImage);
        ratingImages.append(secondStarImage);
        ratingImages.append(thirdStarImage);
        ratingImages.append(fourthStarImage);
        ratingImages.append(fifthStarImage);
        
        for imageView in ratingImages {
            imageView.image = UIImage(systemName: "star");
            imageView.tintColor = UIColor.gray;
        }
    }
    
    func updateRatingImages(_ roundedScore : Int){
        switch roundedScore {
        case 1:
            fillRatingStar(index: 0)
            break;
        case 2:
            for i in 0...1 { fillRatingStar(index: i); }
            break;
        case 3:
            for i in 0...2 { fillRatingStar(index: i); }
            break;
        case 4:
            for i in 0...3 { fillRatingStar(index: i); }
            break;
        case 5:
            for i in 0...4 { fillRatingStar(index: i); }
            break;
            
        default:
            print("Rating image score not found");
            break;
        }
        
    }
    
    func fillRatingStar(index: Int){
        ratingImages[index].image = UIImage(systemName: "star.fill");
        ratingImages[index].tintColor = UIColor.systemYellow;
    }

}
