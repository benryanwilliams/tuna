//
//  Extensions.swift
//  Tuna
//
//  Created by Ben Williams on 07/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
}

extension UserDefaults {
    
    open func setStruct<T: Codable>(_ value: T?, forKey defaultName: String){
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: defaultName)
    }
    
    open func getStruct<T>(_ type: T.Type, forKey defaultName: String) -> T? where T : Decodable {
        guard let encodedData = data(forKey: defaultName) else {
            return nil
        }
        return try! JSONDecoder().decode(type, from: encodedData)
    }
    
    open func setStructArray<T: Codable>(_ value: [T], forKey defaultName: String){
        let data = value.map { try? JSONEncoder().encode($0) }
        set(data, forKey: defaultName)
    }
    
    open func getStructArray<T>(_ type: T.Type, forKey defaultName: String) -> [T] where T : Decodable {
        guard let encodedData = array(forKey: defaultName) as? [Data] else {
            return []
        }
        return encodedData.map { try! JSONDecoder().decode(type, from: $0) }
    }
    
    //delete everything in UserDefaults except for exemptedKeys
    open func deleteAllKeys(exemptedKeys: [String] = []) {
        if exemptedKeys.count == 0 {
            let domain = Bundle.main.bundleIdentifier!
            self.removePersistentDomain(forName: domain)
        } else {
            self.dictionaryRepresentation().keys.forEach { key in
                if !exemptedKeys.contains(key) { //if key is not exempted, delete it
                    self.removeObject(forKey: key)
                }
            }
        }
        self.synchronize()
    }
}
