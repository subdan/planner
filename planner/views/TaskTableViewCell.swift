//
//  TaskTableViewCell.swift
//  planner
//
//  Created by Daniil Subbotin on 01/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    var task: Task! {
        didSet {
            self.titleLabel.text = task.title
            self.descriptionLabel.text = task.comment
            
            if let date = task.dueDate {
                self.dateLabel.text = ShortDateFormat.formatDate(date)
            } else {
                self.dateLabel.text = nil
            }
            self.checkButton.isSelected = task.isDone
        }
    }
    
    func update() {
        checkButton.isSelected = task.isDone
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        checkButton.addTarget(self, action: #selector(accessoryButtonTapped), for: .touchUpInside)
        
        // shadows
        bg.layer.cornerRadius = 3
        bg.layer.shadowColor = #colorLiteral(red: 0.1450980392, green: 0.1490196078, blue: 0.368627451, alpha: 1).cgColor
        bg.layer.shadowOffset = CGSize(width: 0, height: 4)
        bg.layer.shadowRadius = 12
        bg.layer.shadowOpacity = 0.1
        bg.layer.masksToBounds = false
        layer.masksToBounds = false
        clipsToBounds = false
        isOpaque = false
    }
    
    @objc func accessoryButtonTapped(button: UIControl, withEvent: UIEvent) {
        guard let tableView = superview as? UITableView else { return }
        let indexPath: NSIndexPath = tableView.indexPath(for: self)! as NSIndexPath
        tableView.delegate?.tableView!(tableView, accessoryButtonTappedForRowWith: indexPath as IndexPath)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            bg.tintColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            bg.tintColor = UIColor.white
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            bg.tintColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            bg.tintColor = UIColor.white
        }
    }
    
}
