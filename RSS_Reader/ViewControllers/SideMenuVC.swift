

import UIKit

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var channels = [Channel]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        StorageManager.shared.getChannelsWithRequest(.all) { (results) in
            if let results = results {
                self.channels = results
                self.tableView.reloadData()
            }
        }

    }
    
    @IBAction func allFeedsAction(_ sender: Any) {
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.all)
    }

    @IBAction func favoriteFeedsAction(_ sender: Any) {
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.favorites)
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
    
}

extension SideMenuVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = channels[indexPath.row]
        
        sideMenuController?.performSegue(withIdentifier: SEGUE_CENTER_CONTROLLER, sender: RequestType.withLink(channel.link))
    }
    
}
