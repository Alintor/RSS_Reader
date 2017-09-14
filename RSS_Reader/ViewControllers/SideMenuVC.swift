

import UIKit

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var channels = [FeedGroup]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
        
        refreshData()
        

    }
    
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
    

    
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_CENTER_CONTROLLER {
            if let feedVC = segue.destination as? FeedVC,
                let requestType = sender as? RequestType {
                feedVC.requestType = requestType
            }
        }
    }
    

}

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
    
}

extension SideMenuVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = channels[indexPath.row]
        
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.withLink(channel.link))
    }
    
}
