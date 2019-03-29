//
//  CustomLeafView.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/23/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import UIKit

class CustomTreeNode: BaseLeafView {
    
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
