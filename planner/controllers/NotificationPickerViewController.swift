//
//  NotificationPickerViewController.swift
//  planner
//
//  Created by Daniil Subbotin on 08/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import UIKit

class NotificationPickerViewController: HalfScreenViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var selectedNotificationRepeatType: NotificationType?
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        handlePanGesture(sender)
    }
    
    @IBAction func chooseTap(_ sender: Any) {
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        let enumValue = NotificationType.allValues[selectedIndex]
        selectedNotificationRepeatType = enumValue
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        if let type = selectedNotificationRepeatType {
            if let index = NotificationType.allValues.index(of: type) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        contentView.layer.cornerRadius = 10
    }

}

extension NotificationPickerViewController: UIPickerViewDataSource  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return NotificationType.allValues.count
    }
    
}

extension NotificationPickerViewController: UIPickerViewDelegate  {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NotificationType.allValues[row].toString()
    }
    
}
