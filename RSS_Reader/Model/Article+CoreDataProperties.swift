

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var title: String
    @NSManaged public var link: String
    @NSManaged public var imageLink: String?
    @NSManaged public var desc: String?
    @NSManaged public var pubDate: NSDate
    @NSManaged public var channel: Channel?

}
