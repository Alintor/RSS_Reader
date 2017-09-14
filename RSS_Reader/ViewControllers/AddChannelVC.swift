

import UIKit

class AddChannelVC: UIViewController {
    
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var channelLinkField: UITextField!
    @IBOutlet weak var errorView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        if channelLinkField.text == nil || channelLinkField.text == "" {
            showErrorWithText("Empty!")
        } else {
        
            if let channelLink = getCorrectUrlStringFrom(channelLinkField.text!) {
                
                StorageManager.shared.addChannelWithLink(channelLink, finish: { (response) in
                    switch response {
                    case .failure(errorText: let errorText):
                        self.showErrorWithText(errorText)
                    case .success:
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
            } else {
                showErrorWithText("Not correct!")
            }
        }
        
    }
    
    
    func getCorrectUrlStringFrom(_ currentStr:String) -> String? {
        let urlStr:String
        if currentStr.contains("http://") || currentStr.contains("https://") {
            urlStr = currentStr
        } else {
            urlStr = "https://" + currentStr
        }
        let urlRegEx = "https?://(?:www\\.)?\\S+(?:/|\\b)"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        
        if urlTest.evaluate(with: urlStr) {
            return urlStr
        } else {
            return nil
        }
    }
    
    func showErrorWithText(_ textError:String) {
        errorView.isHidden = false
    }
    
    func hideError() {
        errorView.isHidden = true
    }



}
