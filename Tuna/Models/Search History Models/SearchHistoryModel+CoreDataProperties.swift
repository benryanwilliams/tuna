//
//  SearchHistoryModel+CoreDataProperties.swift
//  
//
//  Created by Ben Williams on 23/12/2020.
//
//

import Foundation
import CoreData


extension SearchHistoryModel {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<SearchHistoryModel> {
        return NSFetchRequest<SearchHistoryModel>(entityName: "SearchHistoryModel")
    }

    @NSManaged public var text: String?
    @NSManaged public var dateAdded: Date

}
