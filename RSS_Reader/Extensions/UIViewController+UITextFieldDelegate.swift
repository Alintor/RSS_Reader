import UIKit

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let fieldTag=textField.tag
        // Try to find next responder
        var nextTag = fieldTag+1
        var nextResponder = view.viewWithTag(nextTag)
        while nextResponder != nil && nextResponder!.isHidden {
            nextTag+=1
            nextResponder = view.viewWithTag(nextTag)
        }
        
        if nextResponder != nil {
            // Found next responder, so set it.
            if let nextBtn = nextResponder as? UIButton {
                textField.resignFirstResponder()
                nextBtn.sendActions(for: .touchUpInside)
            } else {
                nextResponder?.becomeFirstResponder()
            }
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false
    }
}
