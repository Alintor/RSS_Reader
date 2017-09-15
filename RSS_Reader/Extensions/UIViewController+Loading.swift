
import UIKit

extension UIViewController {
    
    func createLoadingView() -> UIView
    {
        let loading = UIView.init()
        loading.backgroundColor = UIColor.clear
        loading.tag = 1123002
        loading.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(loading)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loading]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["loading":loading]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loading]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["loading":loading]))
        
        let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activity.startAnimating()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.color = REFRESH_CONTROL_TINT_COLOR
        
        loading.addSubview(activity)
        
        
        let centerX:NSLayoutConstraint = NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: loading, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerY:NSLayoutConstraint = NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: loading, attribute: .bottom, multiplier: 0.5, constant: 0.0)
        
        
        loading.addConstraints([centerX, centerY])
        loading.setNeedsUpdateConstraints()
        loading.layoutIfNeeded()
        
        self.view.bringSubview(toFront: loading)
        
        return loading
    }
    
    func loading(visible:Bool)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
        
        var loadingView:UIView? = self.view.viewWithTag(1123002)
        
        if loadingView == nil
        {
            if !visible
            {
                return
            }
            
            loadingView = self.createLoadingView()
        }
        
        if !visible && loadingView!.isHidden
        {
            return
        }
        
        loadingView!.isUserInteractionEnabled = !visible
        
        if(visible)
        {
            loadingView!.isHidden = false
            self.view.bringSubview(toFront: loadingView!)
        }
        
        loadingView!.alpha = visible ? 0 : 1
        
        DispatchQueue.main.async {
            
            UIView .animate(withDuration: 0.3, animations: {
                
                loadingView!.alpha = visible ? 1 : 0
            },
                            completion: { (finished:Bool) in
                                
                                if(!visible)
                                {
                                    loadingView!.isHidden = true
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
            })
        }
    }
}
