//
//  MainHeaderView.swift
//  planner
//
//  Created by Daniil Subbotin on 30/06/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit

class MainHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        layer.shadowColor = #colorLiteral(red: 0.1450980392, green: 0.1490196078, blue: 0.368627451, alpha: 1).cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 20
        layer.shadowPath = nil
    }
}
