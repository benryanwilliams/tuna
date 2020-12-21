//
//  YoutubeLibraryModel+CoreDataProperties.swift
//  
//
//  Created by Ben Williams on 22/12/2020.
//
//

import Foundation
import CoreData


extension YoutubeLibraryModel {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<YoutubeLibraryModel> {
        return NSFetchRequest<YoutubeLibraryModel>(entityName: "YoutubeLibraryModel")
    }

    @NSManaged public var thumbnail: String
    @NSManaged public var title: String
    @NSManaged public var user: String
    @NSManaged public var viewCount: String
    @NSManaged public var id: String
    @NSManaged public var url: String
    @NSManaged public var isInLibrary: Bool
    @NSManaged public var dateAdded: Date

}
