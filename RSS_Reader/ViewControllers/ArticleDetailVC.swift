

import UIKit

class ArticleDetailVC: UIViewController {
    
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var pubDate: UILabel!
    @IBOutlet weak var articleDescription: UITextView!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    
    var article:Article!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTitle.text = article.title
        articleDescription.text = article.desc
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        pubDate.text = dateFormatter.string(from: article.pubDate as Date)
        
        if let imageLink = article.imageLink {
            articleImage.kf.indicatorType = .activity
            articleImage.kf.setImage(with: URL(string: imageLink))
        } else {
            imageHeight.constant = titleViewHeight.constant
        }
        
        refreshFavoriteButtonIcon()
    }
    
    func refreshFavoriteButtonIcon() {
        if article.isFavorite {
            favoriteBtn.image = UIImage(named: "icn_favorite_filled")
        } else {
            favoriteBtn.image = UIImage(named: "icn_favorite_bordered")
        }
    }

    @IBAction func favoriteBtnAction(_ sender: Any) {
        StorageManager.shared.manageFavoriteArticleWithLink(article.link)
        refreshFavoriteButtonIcon()
    }

}
