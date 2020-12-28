//
//  Extensions.swift
//  Tuna
//
//  Created by Ben Williams on 07/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

// MARK:- UIView

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

// MARK:- UserDefaults

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

// MARK:- UIColor

extension UIColor {
    static let tunaGreen = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
    static let youtubeRed = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
}

// MARK:- TimeInterval

extension TimeInterval {
    func asFormattedString() -> String {
        let mins = self / 60
        let secs = self.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return ""
        }
        return "\(minsStr):\(secsStr)"
    }
}
