//
//  TaskCellCheckDelegate.swift
//  planner
//
//  Created by Daniil Subbotin on 08/08/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import UIKit

protocol TaskCellCheckDelegate: class {
    func checkToggle(cell: UITableViewCell)
}
