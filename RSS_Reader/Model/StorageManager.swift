
//MARK: - Request and response types

enum RequestType {
    case all
    case favorites
    case withLink(_:String)
}

enum SimpleResponse {
    case success
    case failure(errorText:String)
}

//MARK: - Response data

struct FeedGroup {
    var title:String
    var link:String
    var feed:[Article]
    
    init(channel:Channel) {
        title = channel.title
        link = channel.link
        feed = channel.feed ?? [Article]()
    }
    
    init(title:String, link:String, feed:[Article]) {
        self.title = title
        self.link = link
        self.feed = feed
    }
}

let UPDATE_CHANNELS_NOTIFICATION = "UpdateChannelsNotification"
let UPDATE_FAVORITES_NOTIFICATION = "UpdateChannelsNotification"

import UIKit
import CoreData

class StorageManager: NSObject {
    
    let rssParser:RSSParser
    
    var requestTime = [String: Date]()
    
    static let shared = StorageManager()
    
    override init() {
        rssParser = RSSParser()
        super.init()
    }
    
    //MARK: - Support methods
    
    private func canUseCacheData(prevDate:Date?) -> Bool {
        if prevDate != nil {
            let current = NSDate()
            let interval = current.timeIntervalSince(prevDate!)
            if interval < 300 {
                return true
            }
        }
        return false
    }
    
    private func groupArticles(_ articles:[Article]) -> [FeedGroup] {
        
        var groups = [FeedGroup]()
        for article in articles {
            var groupTitle:String
            var groupLink:String
            if let channel = article.channel {
                groupLink = channel.link
                groupTitle = channel.title
            } else { // if channel already deleted
                groupLink = ""
                groupTitle = NSLocalizedString("Unknown", comment: "")
            }
            if let index = groups.index(where: { (feedGroup) -> Bool in
                feedGroup.link == groupLink
            }) {
                groups[index].feed.append(article)
            } else {
                groups.append(FeedGroup(title: groupTitle, link: groupLink, feed: [article]))
            }
        }
        return groups
    }
    
    
    private func addChannelWithTitle(title:String, link:String) {
        let entity =
            NSEntityDescription.entity(forEntityName: "Channel",
                                       in: managedObjectContext)!
        
        let channel = NSManagedObject(entity: entity,
                                     insertInto: managedObjectContext) as! Channel
        channel.title = title
        channel.link = link
        
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
        
    }
    
    private func fetchChannels() -> [Channel]? {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Channel")
        
        do {
            let channels = try managedObjectContext.fetch(fetchRequest) as! [Channel]
            return channels
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    private func checkExistenceOfEntity(_ entittyName:String, withLink link:String) -> Bool {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entittyName)
        fetchRequest.predicate = NSPredicate(format: "link == %@", link)
        
        do {
            let channels = try managedObjectContext.fetch(fetchRequest)
            if channels.first != nil {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    private func cleanCacheForChannelWithLink(_ link:String) {
        let articlesFetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Article")
        articlesFetchRequest.predicate = NSPredicate(format: "channel.link == %@ && isFavorite == %@", link, NSNumber(booleanLiteral: false)) // Delete all articles except favorites
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(articlesFetchRequest) as! [Article]
            
            for entity in fetchedEntities {
                self.managedObjectContext.delete(entity)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        saveContext()
    }

    
    private func fetchGroupOfArticlesWithRequest(_ request:RequestType, andTitleContains title:String? = nil) -> [FeedGroup]? {
        let articlesFetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Article")
        switch request {
        case .all:
            if let title = title {
                articlesFetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", title)
            }
        case .favorites:
            if let title = title {
                articlesFetchRequest.predicate = NSPredicate(format: "isFavorite == %@ AND title CONTAINS[c] %@", NSNumber(booleanLiteral: true), title)
            } else {
                articlesFetchRequest.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(booleanLiteral: true))
            }
        case .withLink(let link):
            if let title = title {
                articlesFetchRequest.predicate = NSPredicate(format: "channel.link == %@ AND title CONTAINS[c] %@", link, title)
            } else {
                articlesFetchRequest.predicate = NSPredicate(format: "channel.link == %@", link)
            }
        }
        
        do {
            let articles = try self.managedObjectContext.fetch(articlesFetchRequest) as! [Article]
            return groupArticles(articles)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    //MARK: - Public methods
    
    func addChannelWithLink(_ link:String, finish: @escaping (SimpleResponse) -> Void) {
        if checkExistenceOfEntity(String(describing: Channel.self), withLink: link) {
            finish(SimpleResponse.failure(errorText: NSLocalizedString("Error_already_exist", comment: "")))
        } else {
        
            rssParser.getChannelTitleFromLink(link) { (channelTitle) in
                if let title = channelTitle {
                    self.addChannelWithTitle(title: title, link: link)
                    finish(.success)
                } else {
                    finish(.failure(errorText: NSLocalizedString("Error_not_rss", comment: "")))
                }
            }
        }
    }
    
    func deleteChannelWithLink(_ link:String) {
        cleanCacheForChannelWithLink(link)
        let chanelFetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Channel")
        chanelFetchRequest.predicate = NSPredicate(format: "link == %@", link)
        
        do {
            let channels = try managedObjectContext.fetch(chanelFetchRequest)
            if let channel = channels.first {
                self.managedObjectContext.delete(channel)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
        
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_CHANNELS_NOTIFICATION), object: nil)
    }
    
    func manageFavoriteArticleWithLink(_ link:String) {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "link == %@", link)
        
        do {
            let articles = try managedObjectContext.fetch(fetchRequest)
            if let article = articles.first as? Article {
                article.isFavorite = !(article.isFavorite)
                if !article.isFavorite && article.channel == nil {
                    self.managedObjectContext.delete(article)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_FAVORITES_NOTIFICATION), object: nil)
    }
    
    func getChannels(finish: @escaping ([FeedGroup]?) -> Void) {
        if let channels = fetchChannels() {
            var groups = [FeedGroup]()
            for channel in channels {
                groups.append(FeedGroup(channel: channel))
            }
            finish(groups)
        } else {
            finish(nil)
        }
    }
    
    func getChannelsWithRequest(_ request:RequestType, andTitleContains title:String? = nil, useCache:Bool = true, finish: @escaping ([FeedGroup]?) -> Void) {
        if let channels = fetchChannels() {
            let group = DispatchGroup()
            for channel in channels {
                if channel.feed == nil ||  channel.feed?.count == 0  || !canUseCacheData(prevDate: requestTime[channel.link]) || !useCache {
                    group.enter()
                    rssParser.getRSSFeedForUrl(url: channel.link, finish: { (articles) in
                        if let articles = articles {
                            self.cleanCacheForChannelWithLink(channel.link)
                            
                            for article in articles {
                                
                                if !(self.checkExistenceOfEntity(String(describing: Article.self), withLink: article.link)) {
                                    let entity =
                                        NSEntityDescription.entity(forEntityName: "Article",
                                                               in: self.managedObjectContext)!
                                
                                    let articleEntity = NSManagedObject(entity: entity,
                                                                    insertInto: self.managedObjectContext) as! Article
                                    articleEntity.title = article.title
                                    articleEntity.desc = article.desc
                                    articleEntity.imageLink = article.imageLink
                                    articleEntity.link = article.link
                                    articleEntity.pubDate = article.pubDate
                                    articleEntity.channel = channel
                                    channel.addToArticles(articleEntity)
                                    self.saveContext()
                                }
                            }
                            self.requestTime[channel.link] = Date()
                            group.leave()
                        }
                    })
                }
            }
            group.notify(queue: .main, execute: {
                if let groups = self.fetchGroupOfArticlesWithRequest(request, andTitleContains: title) {
                    finish(groups)
                } else {
                    finish(nil)
                }
            })
            
        } else {
            finish(nil)
        }
        
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = NSManagedObjectModel.mergedModel(from: nil)!
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("RSS_Reader.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
