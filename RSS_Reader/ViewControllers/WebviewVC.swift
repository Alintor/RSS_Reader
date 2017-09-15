

import UIKit

class WebviewVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var link:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: link)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    @IBAction func closeBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    



}
