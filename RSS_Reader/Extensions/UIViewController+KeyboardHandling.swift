import ObjectiveC
import UIKit

private var scrollViewAssociationKey: UInt8 = 0
private var contentInsetAssociationKey:UInt8 = 1

extension UIViewController: UIGestureRecognizerDelegate {
    
    var observableScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &scrollViewAssociationKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var contentInsetCurrent: UIEdgeInsets! {
        get {
            return objc_getAssociatedObject(self, &contentInsetAssociationKey) as? UIEdgeInsets
        }
        set(newValue) {
            objc_setAssociatedObject(self, &contentInsetAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addKeyboardObservers(scrollView:UIScrollView)
    {
        if self.observableScrollView != nil
        {
            return
        }
        
        self.observableScrollView = scrollView
        self.addDismissRecognizer(self)
        self.contentInsetCurrent = scrollView.contentInset
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func addDismissRecognizer(_ delegate: UIGestureRecognizerDelegate)
    {
        let tapRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleSingleTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = delegate
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(_ sender: UITapGestureRecognizer)
    {
        view.endEditing(true)
        adjustScrollViewWithoutKeyboard(self.observableScrollView)
    }
    
    func keyboardFrame(userInfo:NSDictionary) -> CGRect {
        var keyboardFrame:CGRect = ((userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        
        return keyboardFrame
    }
    
    func adjustScrollViewToKeyboard(_ scrollView:UIScrollView, userInfo:NSDictionary) {
        var contentInset:UIEdgeInsets = self.observableScrollView.contentInset
        contentInset.bottom = keyboardFrame(userInfo: userInfo).size.height
        scrollView.contentInset = contentInset
    }
    
    func adjustScrollViewWithoutKeyboard(_ scrollView:UIScrollView) {
        scrollView.contentInset = self.contentInsetCurrent
    }
    
    func keyboardWillShow(_ notification:NSNotification){
        adjustScrollViewToKeyboard(self.observableScrollView, userInfo: notification.userInfo! as NSDictionary)
    }
    
    func keyboardWillHide(_ notification:NSNotification){
        adjustScrollViewWithoutKeyboard(self.observableScrollView)
    }
}

