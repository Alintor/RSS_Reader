

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
    }
    
    @IBOutlet weak var favoriteFeedAction: UIButton!

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
