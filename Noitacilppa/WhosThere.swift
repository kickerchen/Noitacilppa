//
//  WhosThere.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/5/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import UIKit
import Parse

class WhosThere: PFObject {
    
    // PFObject properties are just a set of key-value parameters
    // By using @NSManaged, when you set the value of each property,
    // it will automatically be written as a key-value pair.
    @NSManaged var user: PFUser
    @NSManaged var position: NSDictionary?
 
    override init() {
        super.init()
    }
    
    init(user: PFUser, position: NSDictionary?) {
        super.init()
        
        self.user = user
        self.position = position
    }
    
    override class func query() -> PFQuery? {
        
        let query = PFQuery(className: WhosThere.parseClassName())
        query.includeKey("user")
        query.orderByDescending("createdAt")
        
        return query
    }
    
}

// Strongly-typed subclasses of `PFObject` must conform to the <PFSubclassing> protocol
extension WhosThere: PFSubclassing {
    
    class func parseClassName() -> String {
        return "WhosThere"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once( &onceToken ) {
            self.registerSubclass()
        }
    }
}
