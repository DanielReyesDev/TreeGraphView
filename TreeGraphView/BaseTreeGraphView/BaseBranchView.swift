//
//  BaseBranchView.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/21/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//


import UIKit


public class BaseBranchView: UIView {
    
    var enclosingTreeGraph: BaseTreeGraphView? {
        return _enclosingTreeGraph()
    }
    private func _enclosingTreeGraph() -> BaseTreeGraphView? {
        var ancestor: UIView? = superview
        while ancestor != nil {
            if (ancestor is BaseTreeGraphView) {
                return ancestor as? BaseTreeGraphView
            }
            ancestor = ancestor?.superview
        }
        return nil
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func directConnectionsPath() -> UIBezierPath? {
        let bounds: CGRect = self.bounds
        var rootPoint = CGPoint.zero
        let treeDirection: TreeGraphOrientationStyle = enclosingTreeGraph!.treeGraphOrientation
        if (treeDirection == .horizontal) || (treeDirection == .horizontalFlipped) {
            rootPoint = CGPoint(x: bounds.minX, y: bounds.midY)
        } else {
            rootPoint = CGPoint(x: bounds.midX, y: bounds.minY)
        }
        
        // Create a single bezier path that we'll use to stroke all the lines.
        let path = UIBezierPath()
        
        // Add a stroke from rootPoint to each child SubtreeView of our containing SubtreeView.
        var subtreeView: UIView? = superview
        if (subtreeView is BaseSubtreeView) {
            
            for subview in subtreeView?.subviews ?? [] {
                if (subview is BaseSubtreeView) {
                    var subviewBounds: CGRect = subview.bounds
                    var targetPoint = CGPoint.zero
                    
                    if (treeDirection == .horizontal) || (treeDirection == .horizontalFlipped) {
                        targetPoint = convert(CGPoint(x: subviewBounds.minX, y: subviewBounds.midY), from: subview)
                    } else {
                        targetPoint = convert(CGPoint(x: subviewBounds.midX, y: subviewBounds.minY), from: subview)
                    }
                    
                    path.move(to: rootPoint)
                    path.addLine(to: targetPoint)
                }
            }
        }
        
        return path
    }
    
    func orthogonalConnectionsPath() -> UIBezierPath? {
        let bounds: CGRect = self.bounds
        let treeDirection: TreeGraphOrientationStyle = enclosingTreeGraph!.treeGraphOrientation
        var rootPoint = CGPoint.zero
        if treeDirection == .horizontal {
            rootPoint = CGPoint(x: bounds.minX, y: bounds.midY)
        } else if treeDirection == .horizontalFlipped {
            rootPoint = CGPoint(x: bounds.maxX, y: bounds.midY)
        } else if treeDirection == .verticalFlipped {
            rootPoint = CGPoint(x: bounds.midX, y: bounds.maxY)
        } else {
            rootPoint = CGPoint(x: bounds.midX, y: bounds.minY)
        }
        let rootIntersection = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath()
        var minY = rootPoint.y
        var maxY = rootPoint.y
        var minX = rootPoint.x
        var maxX = rootPoint.x
        
        let subtreeView: UIView? = superview
        var subtreeViewCount: Int = 0
        if (subtreeView is BaseSubtreeView) {
            for subview in subtreeView!.subviews {
                if (subview is BaseSubtreeView) {
                    subtreeViewCount += 1
                    let subviewBounds: CGRect = subview.bounds
                    var targetPoint = CGPoint.zero
                    if (treeDirection == .horizontal) || (treeDirection == .horizontalFlipped) {
                        targetPoint = convert(CGPoint(x: subviewBounds.minX, y: subviewBounds.midY), from: subview)
                    } else {
                        targetPoint = convert(CGPoint(x: subviewBounds.midX, y: subviewBounds.minY), from: subview)
                    }
                    if (treeDirection == .horizontal) || (treeDirection == .horizontalFlipped) {
                        path.move(to: CGPoint(x: rootIntersection.x, y: targetPoint.y))
                        if minY > targetPoint.y {
                            minY = targetPoint.y
                        }
                        if maxY < targetPoint.y {
                            maxY = targetPoint.y
                        }
                    } else {
                        path.move(to: CGPoint(x: targetPoint.x, y: rootIntersection.y))
                        
                        if minX > targetPoint.x {
                            minX = targetPoint.x
                        }
                        if maxX < targetPoint.x {
                            maxX = targetPoint.x
                        }
                    }
                    path.addLine(to: targetPoint)
                }
            }
        }
    
        if subtreeViewCount != 0 {
            // Add a stroke from rootPoint to where we'll put the vertical connecting line.
            path.move(to: rootPoint)
            path.addLine(to: rootIntersection)
            
            if (treeDirection == .horizontal) || (treeDirection == .horizontalFlipped) {
                // Add a stroke for the vertical connecting line.
                path.move(to: CGPoint(x: rootIntersection.x, y: minY))
                path.addLine(to: CGPoint(x: rootIntersection.x, y: maxY))
            } else {
                // Add a stroke for the vertical connecting line.
                path.move(to: CGPoint(x: minX, y: rootIntersection.y))
                path.addLine(to: CGPoint(x: maxX, y: rootIntersection.y))
            }
        }
        
        // Return the path.
        return path
    }
    
    
    
    override public func draw(_ dirtyRect: CGRect) {
        var path: UIBezierPath? = nil
        switch enclosingTreeGraph!.connectingLineStyle {
        case .orthogonal:
            path = orthogonalConnectionsPath()
        case .direct:
            fallthrough
        default:
            path = directConnectionsPath()
        }
        let treeGraph: BaseTreeGraphView? = enclosingTreeGraph
        if isOpaque {
            treeGraph?.backgroundColor?.set()
            UIRectFill(dirtyRect)
        }
        treeGraph?.connectingLineColor.set()
        path?.lineWidth = treeGraph?.connectingLineWidth ?? 0.0
        path?.stroke()
    }

    
    
}


