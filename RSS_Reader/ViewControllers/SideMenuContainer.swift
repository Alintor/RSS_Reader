
let SEGUE_CENTER_CONTROLLER = "embedCenterController"
let SEGUE_SIDE_CONTROLLER = "embedSideController"

import UIKit
import SideMenuController

class SideMenuContainer: SideMenuController {
    
    required init?(coder aDecoder: NSCoder) {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "icn_menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .showUnderlay
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSegue(withIdentifier: "embedCenterController", sender: nil)
        performSegue(withIdentifier: "embedSideController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_CENTER_CONTROLLER {
            if let navVC = segue.destination as? UINavigationController,
                let feedVC = navVC.topViewController as? FeedVC,
                let requestType = sender as? RequestType {
                feedVC.requestType = requestType
            }
        }
    }
}
