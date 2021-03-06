import UIKit
import Kingfisher

fileprivate let SEGUE_DETAIL = "articleDetailSegue"

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var emptyDataTitle: UILabel!
    
    var channels = [FeedGroup]()
    var requestType = RequestType.all
    
    var selectedSection = 0
    var selectedRow = 0
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(FeedItemCell.self)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
        
        if case RequestType.favorites = requestType {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_FAVORITES_NOTIFICATION), object: nil)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = REFRESH_CONTROL_TINT_COLOR
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        loading(visible:true)
        refreshData()
    }
    
    func setTitle() {
        switch requestType {
        case .all:
            navigationItem.title = NSLocalizedString("All_feeds", comment: "")
        case .favorites:
            navigationItem.title = NSLocalizedString("Favorites", comment: "")
        case .withLink(_):
            navigationItem.title = channels.first?.title ?? ""
        }
    }
    
    func updateData() {
        refreshData(useCache: false)
        refreshControl.endRefreshing()
    }
    
    func showEmptyDataWithTitle(_ title:String) {
        emptyDataTitle.text = title
        tableView.isHidden = true
    }
    
    func hideEmptyData() {
        tableView.isHidden = false
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
                self.setTitle()
                if self.channels.count == 0 && searchText == nil {
                    if case RequestType.favorites = self.requestType {
                        self.showEmptyDataWithTitle(NSLocalizedString("Empty_favorites", comment: ""))
                    } else {
                        self.showEmptyDataWithTitle(NSLocalizedString("Empty_feeds", comment: ""))
                    }
                    
                } else {
                    self.hideEmptyData()
                }
            }
            self.loading(visible:false)
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_DETAIL {
            if let article = sender as? Article {
                let detailVC = segue.destination as! ArticleDetailVC
                detailVC.article = article
                detailVC.delegate = self
            }
        }

    }
 

}

//MARK: - UITableViewDataSource implementation

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
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as FeedItemCell
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

//MARK: - UITableViewDelegate implementation

extension FeedVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = channels[indexPath.section].feed[indexPath.row]
        selectedSection = indexPath.section
        selectedRow = indexPath.row
        
        performSegue(withIdentifier: SEGUE_DETAIL, sender: article)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = SECTION_BG_COLOR
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = SECTION_TITLE_COLOR
        }
    }
    
}

//MARK: - UISearchBarDelegate implementation

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

//MARK: - ArticleDetailFlipper implementation

extension FeedVC: ArticleDetailFlipper {
    func nextArticle() -> Article? {
        let newRow = selectedRow + 1
        if newRow < channels[selectedSection].feed.count {
            selectedRow = newRow
            tableView.scrollToRow(at: IndexPath(row: selectedRow, section: selectedSection), at: .top, animated: false)
            return channels[selectedSection].feed[selectedRow]
            
        } else {
            let newSection = selectedSection + 1
            if newSection < channels.count {
                selectedSection = newSection
                selectedRow = 0
                tableView.scrollToRow(at: IndexPath(row: selectedRow, section: selectedSection), at: .top, animated: false)
                return channels[selectedSection].feed[selectedRow]
            } else {
                return nil
            }
        }
    }
    func prevArticle() -> Article? {
        let newRow = selectedRow - 1
        if newRow >= 0 {
            selectedRow = newRow
            tableView.scrollToRow(at: IndexPath(row: selectedRow, section: selectedSection), at: .top, animated: false)
            return channels[selectedSection].feed[selectedRow]
        } else {
            let newSection = selectedSection - 1
            if newSection < 0 {
                return nil
            } else {
                selectedSection = newSection
                selectedRow = channels[selectedSection].feed.count - 1
                tableView.scrollToRow(at: IndexPath(row: selectedRow, section: selectedSection), at: .top, animated: false)
                return channels[selectedSection].feed[selectedRow]
            }
        }
    }
}
