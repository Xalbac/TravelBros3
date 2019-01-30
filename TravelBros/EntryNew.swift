//
//  EntryNew.swift
//  TravelBros
//
//  Created by Peter on 27.09.2018.
//  Copyright © 2018 Edvard Hedlund. All rights reserved.
//

import UIKit
import QuartzCore

class EntryNew: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //Connect to outlets
    @IBOutlet weak var textDatePick: UITextField!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var entryEntry: UITextField!
    @IBOutlet weak var entryImage: UIImageView!
    
    //Connnect to database to save data
    let entryData = TravelBrosSQL()
    
    //Create date picker
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryEntry.layer.borderWidth = 1
        entryEntry.layer.borderColor = UIColor.lightGray.cgColor
        //A bunch of code to create the date picekr
        datePicker = UIDatePicker()
        //Mode for the date?
        datePicker?.datePickerMode = .date
        //Target. Where it should be displayed
        datePicker?.addTarget(self, action: #selector(EntryNew.dataChanged(datePicker:)),for: .valueChanged)
        //Creatre tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EntryNew.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        //IF picker should be displayed
        textDatePick.inputView = datePicker
    }
    

    //When tapped outside the bounds, close the picker
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dataChanged(datePicker: UIDatePicker){
        //Format the date, by day, month, year.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyy"
        //parse the pick
        textDatePick.text = dateFormatter.string(from: datePicker.date)
    }
    @IBAction func saveData(){
        // SAVE THE DATA
        entryData.oneEntry.date = textDatePick.text ?? ""
        entryData.oneEntry.address = textAddress.text ?? ""
        entryData.oneEntry.entry = entryEntry.text ?? ""

        if entryImage.image != nil{
            entryData.oneEntry.img = entryImage.image
        }
    
        entryData.uploadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //SHOW the chosen image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        entryImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    //Open the gallery or the camera, based on TAG in view.
    @IBAction func nyBild(_ sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if sender.tag == 1 {imagePicker.sourceType = .camera}
        else if sender.tag == 2{imagePicker.sourceType = .photoLibrary}
        self.present(imagePicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
