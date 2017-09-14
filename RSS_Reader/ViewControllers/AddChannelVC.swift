

import UIKit

class AddChannelVC: UIViewController {
    
    @IBOutlet weak var textFieldsView: UIView!
    
    @IBOutlet weak var channelTitleField: UITextField!
    
    @IBOutlet weak var channelLinkField: UITextField!
    
    @IBOutlet weak var errorView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var addButtonAction: UIButton!



}
