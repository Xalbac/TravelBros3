//
//  EntryList.swift
//  TravelBros
//
//  Created by Edvard Hedlund on 2018-09-27.
//  Copyright © 2018 Edvard Hedlund. All rights reserved.
//

import UIKit

class EntryList: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {
    
    
    
    // Connnect to DB
    // LOCAL DATAASE SHOULD BE IN USERS/YOURUSERNAME/travelbrosDB.db
    var entryData = TravelBrosSQL()
    
    //Create the search controller
    let searchController = UISearchController(searchResultsController: nil)

    //Connect items in view to the outlet, so we can use them here.
    @IBOutlet weak var entriesTable: UITableView!
    @IBOutlet weak var loadActivity: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryData.loadDB()
        loadActivity.isHidden = true //WHen the view loads, hide this.
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search entries"
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        entriesTable.tableHeaderView = searchController.searchBar
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
                entriesTable.reloadData()
    }
    
    // Load the table
    func laddaTabell() {
        entriesTable.reloadData()
        loadActivity.isHidden = true
    }
    
    //View the table of searches
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return entryData.searchArray.count
        } else {
            return entryData.entryArray.count
        }
    }
    
    //View the entries based on entry ID
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryID", for: indexPath) as! EntryCell
        let row = indexPath.row
        var entryCell = entryData.entryArray[row]
        if searchController.isActive {
            entryCell = entryData.searchArray[row]
        }
        cell.entryLabel.text = entryCell.date
        return cell
    }
    
    //Based on the user choice, show the approptriate detail.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        performSegue(withIdentifier: "TravelBroItemShowDetails", sender: row)
    }
    
    //Update search results
    func updateSearchResults(for searchController: UISearchController) {
        if let search = searchController.searchBar.text {
            entryData.searchArray = entryData.entryArray.filter {$0.date == search }
            entriesTable.reloadData()
        }
    }
    
    //Go to the details of an entry
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TravelBroItemShowDetails" {
            if let entryPage = segue.destination as? EntryPage {
                if let indx = sender as? Int {
                    var newEntry = entryData.entryArray[indx]
                    if searchController.isActive {
                        newEntry = entryData.searchArray[indx]
                    }
                    entryPage.entryID = newEntry.id
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

