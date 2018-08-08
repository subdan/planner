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
    @IBOutlet weak var background: UIImageView!
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
    
    weak var delegate: TaskCellCheckDelegate?
    
    func update() {
        checkButton.isSelected = task.isDone
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // shadows
        background.layer.cornerRadius = 3
        background.layer.shadowColor = #colorLiteral(red: 0.1450980392, green: 0.1490196078, blue: 0.368627451, alpha: 1).cgColor
        background.layer.shadowOffset = CGSize(width: 0, height: 4)
        background.layer.shadowRadius = 12
        background.layer.shadowOpacity = 0.1
        background.layer.masksToBounds = false
        layer.masksToBounds = false
        clipsToBounds = false
        isOpaque = false
    }
    
    @IBAction func checkTap(_ sender: Any) {
        delegate?.checkToggle(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            background.tintColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            background.tintColor = UIColor.white
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            background.tintColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
            background.tintColor = UIColor.white
        }
    }
    
}
