//
//  TravelBrosSQL.swift
//  TravelBros
//
//  Created by Edvard Hedlund on 2018-09-27.
//  Copyright © 2018 Edvard Hedlund. All rights reserved.
//

import UIKit

class TravelBrosSQL {
    
    struct Entry {
        var id = ""
        var date = ""
        var img:UIImage?
        var address = ""
        var entry = ""
    }
    
    var entryArray:[Entry] = []
    var searchArray:[Entry] = []
    var oneEntry = Entry()
    var dbPath = ""
    
    init() {
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        dbPath = docPath[0].appendingPathComponent("travelbrosDB.db").path
        
        if !FileManager.default.fileExists(atPath: dbPath) {
            if let bundlePath = Bundle.main.resourceURL?.appendingPathComponent("travelbrosDB.db").path {
                do {
                    try FileManager.default.copyItem(atPath: bundlePath, toPath: dbPath)
                    print("Databas kopierad till : \(dbPath)")
                } catch {
                    print("Kan inte kopiera, Error:",error)
                }
            }
        } else {
            print("Databas finns: \(dbPath)")
        }
    }
    
    //laddar ner databasen
    func loadDB() {
        let database = FMDatabase(path: dbPath)
        if database.open() {
            do {
                let entrySet = try database.executeQuery("SELECT * from entries", values: nil)
                while entrySet.next() {
                    var newEntry = Entry()
                    newEntry.id = entrySet.string(forColumn:"id") ?? ""
                    newEntry.date = entrySet.string(forColumn:"date") ?? ""
//                    if let imgData = resSet.data(forColumn:"thumb") {
//                        newEntry.thumb = UIImage(data:imgData)
//                    }
                    entryArray.append(newEntry)
                }
            }catch{
                print(error)
            }
            database.close()
//            dump(entryArray)
        }
    }
    
    //laddar upp ett inlägg för EntryPage
    func loadOne(entryId:String) {
        let database = FMDatabase(path: dbPath)
        if database.open() {
            do {
                let entrySet = try database.executeQuery("SELECT * from entries WHERE id=?", values: [entryId])
                while entrySet.next() {
                    self.oneEntry.date = entrySet.string(forColumn:"date") ?? ""
                     self.oneEntry.entry = entrySet.string(forColumn:"entry") ?? ""
                    self.oneEntry.address = entrySet.string(forColumn:"address") ?? ""
                   
                    if let imgData = entrySet.data(forColumn:"img") {
                        self.oneEntry.img = UIImage(data:imgData)
                    }
                }
            }catch{
                print(error)
            }
            database.close()
        }
    }
    
    func deleteEntry(entryId:String){
        print("WE HAVE ACCESSED THE FUNCTION")
        print(entryId)
        let database = FMDatabase(path: dbPath)
        if database.open(){
            do{
                try database.executeUpdate("delete from entries WHERE id=?", values: [entryId])
                print("WE HAVE ACCESSED THE DATABASE")
                print("WHAT AM I DOING WRONG, WHY ARENT YOU DELETEING!!!!")
                print("ITS WORKING ! ITS WOOORKINGIIIIIGGIGNGGIGINGNIDIBDISADISABSASOANDJSAS!")
            }
            catch{
                print("OH NO AN ERROR")
                print(error)
            }
        database.close()
        }
    }
    
    func editEntry(entryId:String){
        print("=============")
        print("edit entry")
        var imgJpeg:Data?
        if let image = oneEntry.img {
            UIGraphicsBeginImageContext(CGSize(width: 800, height: 475))
            let ratio = Double(image.size.width/image.size.height)
            let scaleWidth = 800.0
            let scaleHeight = 800.0/ratio
            let offsetX = 0.0
            let offsetY = (scaleHeight-475)/2.0
            image.draw(in: CGRect(x: -offsetX, y: -offsetY, width: scaleWidth, height: scaleHeight))
            let largeImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let largeImg = largeImg, let jpegData = largeImg.jpegData(compressionQuality: 0.7) {
                imgJpeg = jpegData
            }
            UIGraphicsEndImageContext()
        }
        let database = FMDatabase(path: dbPath)
        if database.open(){
            do{
                if let imgJpeg = imgJpeg{
                print("Uhhh something wittty")
                try database.executeUpdate("UPDATE entries SET date=?,img=?,address=?,entry=? WHERE id=?", values: [oneEntry.date,oneEntry.entry, oneEntry.address, imgJpeg, entryId])
                print("we did the dartabase execution aweosme")
                }
                
            }catch{
                print("OH NO AN ERROR")
                print(error)
            }
            database.close()
        }
    }
    
    //Laddar upp till data basen
    func uploadData() {
        var imgJpeg:Data?
        if let image = oneEntry.img {
            UIGraphicsBeginImageContext(CGSize(width: 800, height: 475))
            let ratio = Double(image.size.width/image.size.height)
            let scaleWidth = 800.0
            let scaleHeight = 800.0/ratio
            let offsetX = 0.0
            let offsetY = (scaleHeight-475)/2.0
            image.draw(in: CGRect(x: -offsetX, y: -offsetY, width: scaleWidth, height: scaleHeight))
            let largeImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let largeImg = largeImg, let jpegData = largeImg.jpegData(compressionQuality: 0.7) {
                imgJpeg = jpegData
            }
            UIGraphicsEndImageContext()
        }
        
        let database = FMDatabase(path: dbPath)
        if database.open() {
            do {
                if let imgJpeg = imgJpeg {
                    try database.executeUpdate("INSERT INTO entries(date, entry, address, img) VALUES(?,?,?,?)", values: [oneEntry.date, oneEntry.entry, oneEntry.address, imgJpeg])
                }
            }catch{
                print(error)
            }
            database.close()
        }
    }
    
}

