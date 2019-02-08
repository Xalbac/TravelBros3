//
//  EntryPage.swift
//  TravelBros
//
//  Created by Edvard Hedlund on 2018-09-27.
//  Copyright © 2018 Edvard Hedlund. All rights reserved.
//

import UIKit

class EntryPage: UIViewController {
    
    // Connect all outlets to appropriate things. 
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var entryImage: UIImageView!
    @IBOutlet weak var entryText: UITextView!
    
    var entryID = ""
    let entryData = TravelBrosSQL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryData.loadOne(entryId: entryID)
        setEntryData()
    }
    
    //Connect to map, get data from our entryPage to be parsed into map.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            if let mPage = segue.destination as? MapPage {
                mPage.entryDate = entryData.oneEntry.date
                mPage.address = entryData.oneEntry.address
            }
        }
    }
    
    //tar infon från entry data och databasen och lägger upp den i sidan
    func setEntryData(){
        dateLabel.text = entryData.oneEntry.date
        entryText.text = entryData.oneEntry.entry
        addressLabel.text = entryData.oneEntry.address
        entryImage.image = entryData.oneEntry.img
    }
    
    //File sharing image (non-facebook)
    @IBAction func exportImage() {
        
        let fileName = "image.jpg"
        
        let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
        if let fileURL = tempURL.appendingPathComponent(fileName), let theImage = entryImage.image, let jpegData = theImage.jpegData(compressionQuality: 0.7){
            
            do {
                try jpegData.write(to: fileURL)
                
                let objectsToShare = [fileURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC,animated: true,completion: nil)
            }
            catch {
                //hantera fel
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
