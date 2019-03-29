//
//  BaseTreeGraphView+Enums.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/21/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import Foundation

public enum TreeGraphConnectingLineStyle: Int {
    case direct = 0
    case orthogonal = 1
}

public enum TreeGraphOrientationStyle: Int {
    case horizontal = 0
    case vertical = 1
    case horizontalFlipped = 2
    case verticalFlipped = 3
}
