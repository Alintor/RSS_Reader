

import UIKit

class AddChannelVC: UIViewController {
    
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var channelLinkField: TextFieldWithImage!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        channelLinkField.setActiveImage(name: "icn_web")
        channelLinkField.placeholder = NSLocalizedString("URL_address", comment: "")
        addButton.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        addKeyboardObservers(scrollView: scrollView)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        if channelLinkField.text == nil || channelLinkField.text == "" {
            showErrorWithText(NSLocalizedString("Error_empty_field", comment: ""))
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
                showErrorWithText(NSLocalizedString("Error_not_correct_url", comment: ""))
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
        textFieldsView.layer.borderWidth = 2
        textFieldsView.layer.borderColor = UIColor.red.cgColor
        AlertManager.shared.showAlert(message: textError)
    }



}
