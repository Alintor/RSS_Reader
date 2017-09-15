

import UIKit

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allFeedLbl: UILabel!
    @IBOutlet weak var favoritesLbl: UILabel!
    
    var channels = [FeedGroup]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allFeedLbl.text = NSLocalizedString("All_feeds", comment: "")
        favoritesLbl.text = NSLocalizedString("Favorites", comment: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
        
        refreshData()
    }
    
    //MARK: - Actions
    
    @IBAction func allFeedsAction(_ sender: Any) {
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.all)
    }

    @IBAction func favoriteFeedsAction(_ sender: Any) {
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.favorites)
    }
    
    func refreshData() {
        StorageManager.shared.getChannelsWithRequest(.all) { (results) in
            if let results = results {
                self.channels = results
                self.tableView.reloadData()
            }
        }
    }
    

}

//MARK: - UITableViewDataSource implementation

extension SideMenuVC : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = channels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = channel.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channel = channels[indexPath.row]
            StorageManager.shared.deleteChannelWithLink(channel.link)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if channels.count > 0 {
            return NSLocalizedString("Channels", comment: "")
        } else {
            return nil
        }
        
    }
    
}

//MARK: - UITableViewDelegate implementation

extension SideMenuVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = channels[indexPath.row]
        
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.withLink(channel.link))
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = SECTION_BG_COLOR
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = SECTION_TITLE_COLOR
        }
    }
    
}
