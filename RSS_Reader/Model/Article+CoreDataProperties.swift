//
//  Article+CoreDataProperties.swift
//  RSS_Reader
//
//  Created by Alexandr Ovchinnikov on 13.09.17.
//  Copyright © 2017 Alexandr Ovchinnikov. All rights reserved.
//

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
    @NSManaged public var isFavorite: Bool
    @NSManaged public var channel: Channel?

}
