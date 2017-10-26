

import UIKit

class FeedItemCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    
    @IBOutlet weak var withoutImage: NSLayoutConstraint!
    @IBOutlet weak var withImage: NSLayoutConstraint!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func hideImage(_ hide:Bool) {
        if hide {
            itemImage.isHidden = true
            withoutImage.isActive = true
            withImage.isActive = false
        } else {
            itemImage.isHidden = false
            withoutImage.isActive = false
            withImage.isActive = true
        }
    }
    
}


protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: Self.self) }
    static var nib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}
