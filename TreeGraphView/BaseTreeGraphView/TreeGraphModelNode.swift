//
//  TreeGraphModelNode.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/22/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import UIKit


//public protocol TreeGraphModelNode: NSObject {
//    var childModelNodes:[Any] {get set}
//}

/// The model nodes used with a TreeGraph are required to conform to the this protocol,
/// which enables the TreeGraph to navigate the model tree to find related nodes.
//protocol PSTreeGraphModelNode: NSObjectProtocol {
//    /// @return The model node's parent node, or nil if it doesn't have a parent node.
//    func parent() -> PSTreeGraphModelNode?
//    /// @return The model node's child nodes.
//    ///
//    /// @note If the node has no children, this should return an empty array
//    /// ([NSArray array]), not nil.
//    func childModelNodes() -> [Any]?
//}


public protocol TreeGraphModelNode: class {
    func childNodes() -> [MyTreeGraphModelNode]?
    func parent() -> MyTreeGraphModelNode?
}

open class MyTreeGraphModelNode: UIView, TreeGraphModelNode {
    
    public var id: Int
    
    public init(id:Int) {
        self.id = id
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    public var hashValue: Int {
//        get {
//            return id.hashValue << 15
//        }
//    }
    
    public static func == (lhs: MyTreeGraphModelNode, rhs: MyTreeGraphModelNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    open func childNodes() -> [MyTreeGraphModelNode]? {
        return nil
    }
    
    open func parent() -> MyTreeGraphModelNode? {
        return nil
    }
}


public class TestClass {
    init() {
        
    }
    
    public func testSets() {
        let set = Set<MyTreeGraphModelNode>()
        
    }
}



//public class TreeGraphModelNode:UIView {
//
//    public var childModelNodes:[Any]!
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

