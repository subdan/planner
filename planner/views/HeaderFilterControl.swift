//
//  HeaderFilterControl.swift
//  planner
//
//  Created by Daniil Subbotin on 01/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit

protocol FilterDelegate: class {
    func filterDidChanged(filterValue: TaskFilterType)
}

class HeaderFilterControl: UIControl {

    @IBOutlet weak var uncheckedButton: UIButton!
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var buttonHighlighter: UIView!
    
    var filterSelected = TaskFilterType.unchecked {
        didSet {
            uncheckedButton.isSelected = filterSelected == .unchecked
            checkedButton.isSelected = filterSelected == .checked
            
            delegate?.filterDidChanged(filterValue: filterSelected)
        }
    }
    
    weak var delegate: FilterDelegate?
    
    @IBAction func uncheckedButtonTap(_ sender: Any) {
        filterSelected = .unchecked
        moveButtonHighlighter(to: uncheckedButton)
    }
    
    private func moveButtonHighlighter(to filterButton: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.buttonHighlighter.frame.origin.x = filterButton.frame.origin.x
        }, completion: nil)
    }
    
    @IBAction func checkedButtonTap(_ sender: Any) {
        filterSelected = .checked
        moveButtonHighlighter(to: checkedButton)
    }
    
}
