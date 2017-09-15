

import UIKit

class AlertManager: NSObject {
    static let shared = AlertManager()
    
    func showAlert(message: String)
    {
        self.showAlert(title: nil, message: message)
    }
    
    func showToast(title:String? = nil, message: String) {
        self.showAlert(title: title, message: message, isToast: true)
    }
    
    func showAlert(title:String?, message: String?, isToast: Bool = false)
    {
        let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.blue
        if isToast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                topWindow.isHidden = true
            }
        } else {
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel) { (action: UIAlertAction) in
                topWindow.isHidden = true
            })
        }
        
        
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController!.present(alertController, animated: true, completion: nil)
    }

}
