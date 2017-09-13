

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var title: String
    @NSManaged public var link: String
    @NSManaged public var articles: NSSet?
    
    public var feed: [Article]? {
        return articles?.sorted(by: { ($0 as! Article).pubDate.compare(($1 as! Article).pubDate as! Date) == ComparisonResult.orderedDescending }) as? [Article]
    }

}

// MARK: Generated accessors for articles
extension Channel {

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: Article)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: Article)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSSet)

}
