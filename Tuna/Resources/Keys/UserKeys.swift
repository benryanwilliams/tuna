//
//  UserKeys.swift
//  Tuna
//
//  Created by Ben Williams on 27/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import Foundation

struct UsersKeys {
    
    ///keys for all Collections in the database
    struct Collection {
        static let Users: String = "Users"
        static let UserType: String = "UserType"
    }
    
    ///keys for all User properties
    struct UserInfo {
        static let email: String = "email"
        static let firstName: String = "firstName"
        static let lastName: String = "lastName"
        static let userId: String = "userId"
        static let userType: String = "userType"
        static let photoUrl: String = "photoUrl"
    }
    
    ///keys for all UserType
    struct UserType {
        
    }
}
