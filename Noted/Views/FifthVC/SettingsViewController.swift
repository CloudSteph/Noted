//
//  SettingsViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 11/30/22.
//

import Foundation
import UIKit

enum TapOptions: CaseIterable {
    case one, two, three, four, five
    
    var title: String {
        switch self {
        case .one:
            return "One"
        case .two:
            return "Two"
        case .three:
            return "Three"
        case .four:
            return "Four"
        case .five:
            return "Five"
        }
    }
    
    var value: Int {
        switch self {
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        }
    }
}

final class SettingsViewController: UITableViewController, Storyboardable, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet private(set) weak var numOfTapsTextField: UITextField!
    @IBOutlet private(set) weak var saveBtn: UIButton!
    
    private var viewModel: NoteViewModel = .init()
    
    var numPickerView = UIPickerView()
    var selectedTapOption: TapOptions = .one
    var textField = UITextField()
    
    override func viewDidLoad() {
        title = "Settings"
        saveBtn.tintColor = .black
        saveBtn.layer.cornerRadius = 5
        setupNumOfTapsTextField()
        
        self.numPickerView.delegate = self
        self.numPickerView.dataSource = self
    }
    
    private func setupNumOfTapsTextField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let massFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePickerBtn(sender:)))
        
        toolBar.items = [massFlexibleSpace, doneBtn]
        
        numOfTapsTextField.inputView = numPickerView
        numOfTapsTextField.textAlignment = .center
        numOfTapsTextField.text = viewModel.currentSavedTapRequirement().title
        textField = numOfTapsTextField
        numOfTapsTextField.inputAccessoryView = toolBar
    }
    
    @objc private func donePickerBtn(sender: Any) {
        numOfTapsTextField.resignFirstResponder()
    }
    
    //Data source method to return the number of column shown in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Data source method to return the number of row shown in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numTapsData.count
    }
    
    //Delegate method to return the value shown in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.numTapsData[row].title
    }
    
    //Delegate method called when the row was selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(viewModel.numTapsData[row])
        numOfTapsTextField.text = viewModel.numTapsData[row].title
        selectedTapOption = viewModel.numTapsData[row]
    }

    @IBAction func didPressSaveBtn() {
        print(selectedTapOption.value)
        //standard default object used and set a certain value to the user defaults
        UserDefaults.standard.setValue(selectedTapOption.value, forKey: "numOfTaps")
        
        let alert = UIAlertController(title: "Tap(s) Saved", message: "Tap(s): \(viewModel.currentSavedTapRequirement().title)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
}

