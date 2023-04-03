//
//  SavedGame.swift
//  Dodge Balls
//
//  Created by Chiristofer Patrick Paes on 5/3/19.
//  Copyright © Chiristofer Patrick Paes 2019 RSC. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SavedGame: NSObject, NSCoding {
    
    // Mark Properties
    
    var name: String
    var score: Int
    
    // Mark Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory,
    in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("savedGame")
    
    //Mark Types
    struct PropertyKey {
        
        static let name = "name"
        static let score = "score"
    }
    
    
    //Mark: Initialization
    init?(name: String, score: Int) {
        
        //The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        //Initialized stored properties
        self.name = name
        self.score = score
        
    }
    
    //Mark: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(score,forKey: PropertyKey.score)
        
    }
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If WE cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
            else {
            os_log("Unable to decode the name for saved score.", log: OSLog.default,
            type: .debug)
            return nil
        }
        let score = aDecoder.decodeInteger(forKey: PropertyKey.score)
        self.init(name: name, score: score)
    }
}
