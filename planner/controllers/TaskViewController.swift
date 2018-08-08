//
//  TaskViewController.swift
//  planner
//
//  Created by Daniil Subbotin on 01/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    private var currentAddress: Address?
    
    private var currentDate: Date? {
        didSet {
            notificationButton.isEnabled = currentDate != nil
        }
    }
    
    private var currentNotificationType : NotificationType?
    
    var mode: TaskActionMode = .create
    var taskToEdit: Task?
    
    let descriptionPromptText = "Краткое описание задачи"
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        scrollView.delegate = self
        descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        
        showTaskData()
    }
    
    func showTaskData() {
        backButton.isHidden = mode == .create
        cancelButton.isHidden = mode != .create
        deleteButton.isHidden = mode != .edit
        saveButton.isEnabled = mode == .edit
        
        if mode == .edit, let task = taskToEdit {
            checkButton.isSelected = task.isDone
            titleTextField.text = task.title
            descriptionTextView.text = task.comment
            adressLabel.text = task.address?.formattedAddress ?? "Не выбран"
            currentAddress = task.address
            
            if let date = task.dueDate {
                currentDate = date
                dateLabel.text = ShortDateFormat.formatDate(date)
            }
            
            if task.notificationType != -1 {
                currentNotificationType = NotificationType(rawValue: Int(task.notificationType))
                notificationLabel.text = currentNotificationType?.toString()
            }
        }
        
        if mode == .create || mode == .edit && descriptionTextView.text == descriptionPromptText {
            // Workaround because UITextView doesn't have a placeholder
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard(_:)),
            name: .UIKeyboardWillChangeFrame,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard(_:)),
            name: .UIKeyboardWillHide,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func deleteTap(_ sender: Any) {
        
        if let address = currentAddress {
            CoreDataStack.shared.viewContent.delete(address)
        }
        
        if let task = taskToEdit {
            
            CoreDataStack.shared.viewContent.delete(task)
            
            if let id = task.notificationID {
                LocalNotificationHelper.cancel(id)
            }
            CoreDataStack.shared.saveContext()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func adjustForKeyboard(_ notification: NSNotification) {
        
        guard notification.name != .UIKeyboardWillHide else {
            scrollView.contentInset.bottom = 0
            scrollView.scrollIndicatorInsets.bottom = 0
            return
        }
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        
        if let address = currentAddress {
            CoreDataStack.shared.viewContent.delete(address)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        adjustTextViewHeight()
    }
    
    @IBAction func checkTap(_ sender: Any) {
        checkButton.isSelected = !checkButton.isSelected
    }
    
    func setSaveButtonIsEnabled() {
        if let titleLen = titleTextField.text?.count, titleLen > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func backFromMap(segue: UIStoryboardSegue) {
        if let vc = segue.source as? MapViewController {
            currentAddress = vc.currentAddress
            adressLabel.text = currentAddress?.formattedAddress ?? "Не выбран"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewController, currentAddress != nil {
            vc.currentAddress = currentAddress
        } else if let vc = segue.destination as? DatePickerViewController {
            vc.selectedDate = currentDate
            vc.transitioningDelegate = slideInTransitioningDelegate
            vc.modalPresentationStyle = .custom
        } else if let vc = segue.destination as? NotificationPickerViewController {
            vc.selectedNotificationRepeatType = currentNotificationType
            vc.transitioningDelegate = slideInTransitioningDelegate
            vc.modalPresentationStyle = .custom
        }
    }
    
    @IBAction func backFromNotificationPicker(segue: UIStoryboardSegue) {
        if let vc = segue.source as? NotificationPickerViewController {
            if let type = vc.selectedNotificationRepeatType {
                currentNotificationType = type
                notificationLabel.text = currentNotificationType?.toString()
            }
        }
    }
    
    @IBAction func backFromDatePicker(segue: UIStoryboardSegue) {
        if let vc = segue.source as? DatePickerViewController {
            if let dt = vc.selectedDate {
                currentDate = dt
                dateLabel.text = ShortDateFormat.formatDate(dt)
            }
        }
    }
    
    @IBAction func titleChanged(_ sender: Any) {
        setSaveButtonIsEnabled()
    }
    
    @IBAction func saveTap(_ sender: Any) {
        
        let task: Task
        
        if mode == .edit {
            task = taskToEdit!
        } else {
            task = Task(context: CoreDataStack.shared.viewContent)
        }
        
        task.title = titleTextField.text!
        task.address = currentAddress
        task.comment = descriptionTextView.text == descriptionPromptText ? nil : descriptionTextView.text
        task.dueDate = currentDate
        task.isDone = checkButton.isSelected
        task.notificationType = Int64(currentNotificationType?.rawValue ?? -1)
        
        if mode == .edit {
            if let id = task.notificationID {
                LocalNotificationHelper.cancel(id)
                task.notificationID = nil
            }
        }
        
        if let date = currentDate, let type = currentNotificationType {
            LocalNotificationHelper.create(title: type.toTitleString(),
                                           body: task.title!,
                                           date: date,
                                           type: type,
                                           handler: { uuid in
                task.notificationID = uuid
                self.saveTaskAndExit()
            });
            
        } else {
            saveTaskAndExit()
        }
        
    }
    
    func saveTaskAndExit() {
        try? CoreDataStack.shared.viewContent.save()
        
        if mode == .create {
            // workaround due to the ios bug
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        } else if mode == .edit {
            // workaround due to the ios bug
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBOutlet weak var textViewConstraint: NSLayoutConstraint!
}

extension TaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // Workaround
        descriptionTextView.textColor = UIColor.black
        
        if descriptionTextView.text == descriptionPromptText {
            descriptionTextView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text == "" {
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.text = descriptionPromptText
        }
    }
    
    func adjustTextViewHeight() {
        let fixedWidth = descriptionTextView.frame.size.width
        let newSize = descriptionTextView.sizeThatFits(
            CGSize(width: fixedWidth,
                   height: CGFloat.greatestFiniteMagnitude)
        )
        self.textHeightConstraint.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
}

extension TaskViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y > 20 ? 20 : scrollView.contentOffset.y
        let shadowRatio = offsetY / 20 * 20
        
        headerView.layer.shadowRadius = shadowRatio
        headerView.layer.shadowOpacity = 0.2
    }
    
}
