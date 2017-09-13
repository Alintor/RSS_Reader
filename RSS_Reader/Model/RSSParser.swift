
struct FeedItem {
    var title:String
    var desc:String?
    var link:String
    var imageLink:String?
    var pubDate:NSDate
}


import UIKit
import Alamofire
import SWXMLHash

class RSSParser: NSObject {
    
    func getRSSFeedForUrl(url:String, finish: @escaping ([FeedItem]?) -> Void) {
        
        Alamofire.request(url).responseString { response in
            switch response.result {
            case .success:
                
                let xml = SWXMLHash.parse(response.data!)
                let items = xml["rss"]["channel"]["item"].all
                var articles = [FeedItem]()
                for item in items {
                    
                    let dateString = item["pubDate"].element?.text
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                    let pubDate = dateFormatter.date(from: dateString!)
                    let article = FeedItem(title: (item["title"].element?.text)!,
                                                desc: item["description"].element?.text,
                                                link: (item["link"].element?.text)!,
                                                imageLink: item["enclosure"].element?.attribute(by: "url")?.text,
                                                pubDate: pubDate! as NSDate)
                    articles.append(article)
                    
                }
                finish(articles)
                
            case .failure:
                print(response.error!.localizedDescription)
                finish(nil)
            }
        }
        
    }

}
