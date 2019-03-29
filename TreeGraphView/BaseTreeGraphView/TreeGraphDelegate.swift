//
//  TreeGraphDelegate.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/23/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import Foundation

public protocol TreeGraphDelegate: class {
    func configureNodeView(nodeView:UIView, modelNode:TreeGraphModelNode)
    func didSelectNodeView(node:TreeGraphModelNode)
}
