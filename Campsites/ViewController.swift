//
//  ViewController.swift
//  Campsites
//
//  Created by Ryan Kreiter on 4/20/16.
//  Copyright © 2016 Ryan Kreiter. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var sizePicker: UIPickerView!
    @IBOutlet weak var difficultyPicker: UIPickerView!
    
    let sizeData = ["Small - 10x10", "Medium - 15X15", "Large - 20x20"]
    let difficultyData = ["Easy", "Challenging"]
    
    var size: Int = 0
    var difficulty: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sizePicker.dataSource = self
        sizePicker.delegate = self
        difficultyPicker.dataSource = self
        difficultyPicker.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "startSegue") {
            let gvc = segue.destinationViewController as! GameViewController;
            gvc.gridSize = (size+2)*5 + 1
            gvc.difficulty = difficultyData[difficulty]
        }
    }
    
    // Number of columns
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of items
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == sizePicker){
            return sizeData.count
        }
        else{
            return difficultyData.count
        }
    }
    
    // Returns display string
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == sizePicker){
            return sizeData[row]
        }
        else{
            return difficultyData[row]
        }
    }
    
    // Selection handler
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == sizePicker){
            size = row
        }
        else{
            difficulty = row
        }
    }
    
}
