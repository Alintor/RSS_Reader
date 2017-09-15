

import UIKit

class TextFieldWithImage: UITextField {

    public func setActiveImage(name:String)
    {
        let image:UIImage = UIImage(named: name)!
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: self.frame.size.height))
        
        let imageView:UIImageView = UIImageView.init(frame: view.bounds)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.center
        imageView.tintColor = UIColor(red: 25.0/255.0, green: 52.0/255.0, blue: 65.0/255.0, alpha: 1)
        view.addSubview(imageView)
        
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = view;
    }

}
