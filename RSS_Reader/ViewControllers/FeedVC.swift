

import UIKit
import Kingfisher

fileprivate let CELL_NIB_NAME = "FeedItemCell"
fileprivate let CELL_REUSE_IDENTIFIER = "FeedItemCellIdentifier"
fileprivate let SEGUE_DETAIL = "articleDetailSegue"

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var channels = [FeedGroup]()
    
    var requestType = RequestType.all
    var titleName = "All feed"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleName
        tableView.register(UINib(nibName: CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: CELL_REUSE_IDENTIFIER)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
        
        if case RequestType.favorites = requestType {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_FAVORITES_NOTIFICATION), object: nil)
        }
        
        refreshData()
        
    }
    
    func refreshData(useCache:Bool = true) {
        
        
        var searchText = searchBar.text
        if searchText == "" {
            searchText = nil
        }
        StorageManager.shared.getChannelsWithRequest(requestType, andTitleContains: searchText, useCache: useCache, finish: { (results) in
            if let results = results {
                self.channels = results
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_DETAIL {
            if let article = sender as? Article {
                let detailVC = segue.destination as! ArticleDetailVC
                detailVC.article = article
            }
        }

    }
 

}


extension FeedVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return channels.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch requestType {
        case .all, .favorites:
            return channels[section].title
        default:
            return nil
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels[section].feed.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = channels[indexPath.section].feed[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as! FeedItemCell
        cell.title.text = article.title
        cell.desc.text = article.desc
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        cell.date.text = dateFormatter.string(from: article.pubDate as Date)
        
        if let imageLink = article.imageLink {
            cell.itemImage.kf.indicatorType = .activity
            cell.itemImage.kf.setImage(with: URL(string: imageLink))
            cell.hideImage(false)
        } else {
            cell.hideImage(true)
        }
        return cell
    }
    
}

extension FeedVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = channels[indexPath.section].feed[indexPath.row]
        
        performSegue(withIdentifier: SEGUE_DETAIL, sender: article)
    }
    
}

extension FeedVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        refreshData()
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refreshData()
    }
}
