
enum RequestType {
    case all
    case favorites
    case withLink(_:String)
}

enum SimpleResponse {
    case success
    case failure(errorText:String)
}

let UPDATE_CHANNELS_NOTIFICATION = "UpdateChannelsNotification"

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
    
    private func fetchChannelsWithRequest(_ request:RequestType) -> [Channel]? {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Channel")
        
        switch request {
        case .all: break
            
        case .favorites:
            fetchRequest.predicate = NSPredicate(format: "ANY articles.isFavorite == %@", NSNumber(booleanLiteral: true))
            
        case .withLink(let link):
            fetchRequest.predicate = NSPredicate(format: "link == %@", link)
        }
        
        do {
            let channels = try managedObjectContext.fetch(fetchRequest)
            return channels as? [Channel]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    
    func addChannelWithLink(_ link:String, finish: @escaping (SimpleResponse) -> Void) {
        if isChannelExistWithLink(link) {
            finish(SimpleResponse.failure(errorText: "Already Exist"))
        } else {
        
            rssParser.getChannelTitleFromLink(link) { (channelTitle) in
                if let title = channelTitle {
                    self.addChannelWithTitle(title: title, link: link)
                    finish(.success)
                } else {
                    finish(.failure(errorText: "It's not RSS!"))
                }
            }
        }
        
        
    }
    
    
    
    private func isChannelExistWithLink(_ link:String) -> Bool {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Channel")
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
    
    func getChannelsWithRequest(_ request:RequestType, useCache:Bool = true, finish: @escaping ([Channel]?) -> Void) {
        if let channels = fetchChannelsWithRequest(request) {
            let group = DispatchGroup()
            for channel in channels {
                if channel.feed == nil ||  channel.feed?.count == 0  || !canUseCacheData(prevDate: requestTime[channel.link]) || !useCache {
                    group.enter()
                    rssParser.getRSSFeedForUrl(url: channel.link, finish: { (articles) in
                        if let articles = articles {
                            let fetchRequest =
                                NSFetchRequest<NSManagedObject>(entityName: "Article")
                            fetchRequest.predicate = NSPredicate(format: "channel == %@ && isFavorite == %@", channel, NSNumber(booleanLiteral: false))
                            do {
                                let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest) as! [Article]
                                
                                for entity in fetchedEntities {
                                    self.managedObjectContext.delete(entity)
                                }
                            } catch let error as NSError {
                                print("Could not fetch. \(error), \(error.userInfo)")
                            }
                            self.saveContext()
                            
                            for article in articles {
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
                            self.requestTime[channel.link] = Date()
                            group.leave()
                        }
                    })
                    
                }
            }
            group.notify(queue: .main, execute: {
                finish(channels)
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
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "RSS_Reader", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
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
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
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
