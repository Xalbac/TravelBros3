//
//  DBManager.swift
//  TravelBros
//
//  Created by Peter on 2019-02-12.
//  Copyright © 2019 Edvard Hedlund. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    static let shared: DBManager = DBManager()
    let databaseFileName = "travelbrosDB.db"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    override init(){
        super.init()
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
}
