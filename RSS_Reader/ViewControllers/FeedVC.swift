

import UIKit
import Kingfisher

fileprivate let CELL_NIB_NAME = "FeedItemCell"
fileprivate let CELL_REUSE_IDENTIFIER = "FeedItemCellIdentifier"

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var channels = [Channel]()
    
    var requestType = RequestType.all
    var titleName = "All feed"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleName
        tableView.register(UINib(nibName: CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: CELL_REUSE_IDENTIFIER)
        
        
        StorageManager.shared.getChannelsWithRequest(requestType) { (results) in
            if let results = results {
                self.channels = results
                self.tableView.reloadData()
            }
        }
        
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


extension FeedVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return channels.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return channels[section].title
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (channels[section].feed?.count)!
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = channels[indexPath.section].feed?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as! FeedItemCell
        cell.title.text = article?.title
        cell.desc.text = article?.desc
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        cell.date.text = dateFormatter.string(from: article!.pubDate as Date)
        
        if let imageLink = article?.imageLink {
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
    
}
