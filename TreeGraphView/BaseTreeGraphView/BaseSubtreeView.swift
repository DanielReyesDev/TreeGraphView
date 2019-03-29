//
//  BaseSubtreeView.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/21/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import UIKit



public class BaseSubtreeView: UIView {
    
    var modelNode: MyTreeGraphModelNode!
//    var nodeView: UIView!
    @IBOutlet var nodeView: CustomTreeNode!
    //private(set) weak var enclosingTreeGraph: BaseTreeGraphView?
    weak var enclosingTreeGraph: BaseTreeGraphView? {
        get {
            var ancestor: UIView? = superview
            while (ancestor != nil) {
                if (ancestor is BaseTreeGraphView) {
                    return ancestor as? BaseTreeGraphView
                }
                ancestor = ancestor?.superview
            }
            return nil
        }
    }
    var nodeIsSelected:Bool {
        get {
            //return self.enclosingTreeGraph!.selectedModelNodes.contains(self.modelNode)
            return self.enclosingTreeGraph!.selectedModelNodes.contains(self.modelNode) ?? false
        }
        set {}
    }
    var needsGraphLayout = false
    var isExpanded = false
    private var connectorsView: BaseBranchView?
    
    private var isLeaf:Bool {
        //return self.modelNode.childModelNodes.count == 0
        return self.modelNode.childNodes()?.count == 0
    }
    
    var subtreeBorderWidth:CGFloat = 2.0
    var subtreeBorderColor:CGColor = UIColor.black.cgColor
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(modelNode newModelNode: MyTreeGraphModelNode) {
        //super.init(frame: .zero)
        super.init(frame: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 25.0))
        // Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
        // method, since they may wrongly expect the instance to be fully formed.
        
        isExpanded = true
        needsGraphLayout = true
        
        // autoresizesSubviews defaults to YES.  We don't want autoresizing, which would interfere
        // with the explicit layout we do, so we switch it off for SubtreeView instances.
        autoresizesSubviews = false
        
        modelNode = newModelNode
        connectorsView = BaseBranchView(frame: CGRect.zero)
        if (connectorsView != nil) {
            connectorsView!.autoresizesSubviews = true
            // if we dont redraw lines, they get out of place
            connectorsView!.contentMode = .redraw
            connectorsView!.isOpaque = true
            
            addSubview(connectorsView!)
        }
    }
    
    
    func setExpanded(flag: Bool) {
        if self.isExpanded != flag {
            // Remember this SubtreeView's new state.
            self.isExpanded = flag
            
            // Notify the TreeGraph we need layout.
            enclosingTreeGraph?.setNeedsGraphLayout()
            
            // Expand or collapse subtrees recursively.
            for subview in subviews {
                if (subview is BaseSubtreeView) {
                    (subview as? BaseSubtreeView)?.isExpanded = isExpanded
                }
            }
        }
    }
    
    
    
    func layoutGraphIfNeeded() -> CGSize {
        // Return early if layout not needed
        if !needsGraphLayout {
            return frame.size
        }
        
        // Do the layout
        var selfTargetSize: CGSize
        if isExpanded {
            selfTargetSize = layoutExpandedGraph()
        } else {
            selfTargetSize = layoutCollapsedGraph()
        }
        
        // Mark as having completed layout.
        needsGraphLayout = false
        
        // Return our new size.
        return selfTargetSize
    }


    
    func layoutExpandedGraph() -> CGSize {
        var selfTargetSize: CGSize
        
        let treeGraph: BaseTreeGraphView? = enclosingTreeGraph
        
        let parentChildSpacing = treeGraph!.parentChildSpacing
        let siblingSpacing = treeGraph!.siblingSpacing
        let treeOrientation: TreeGraphOrientationStyle? = treeGraph?.treeGraphOrientation
        
        // Size this SubtreeView's nodeView to fit its content.  Our tree layout model assumes the assessment
        // of a node's natural size is a function of intrinsic properties of the node, and isn't influenced
        // by any other nodes or layout in the tree.
        
        let rootNodeViewSize: CGSize = sizeNodeViewToFitContent()
        
        // Recurse to lay out each of our child SubtreeViews (and their non-collapsed descendants in turn).
        // Knowing the sizes of our child SubtreeViews will tell us what size this SubtreeView needs to be
        // to contain them (and our nodeView and connectorsView).
        
        let subviews = self.subviews
        let count: Int = subviews.count
        var index: Int
        var subtreeViewCount: Int = 0
        var maxWidth: CGFloat = 0.0
        var maxHeight: CGFloat = 0.0
        var nextSubtreeViewOrigin = CGPoint.zero
        
        if (treeOrientation == .horizontal) || (treeOrientation == .horizontalFlipped) {
            nextSubtreeViewOrigin = CGPoint(x: rootNodeViewSize.width + parentChildSpacing, y: 0.0)
        } else {
            nextSubtreeViewOrigin = CGPoint(x: 0.0, y: rootNodeViewSize.height + parentChildSpacing)
        }
        
        index = count - 1
        while index >= 0 {
            let subview: UIView? = subviews[index]
            
            if (subview is BaseSubtreeView) {
                subtreeViewCount += 1
                
                // Unhide the view if needed.
                subview?.isHidden = false
                
                // Recursively layout the subtree, and obtain the SubtreeView's resultant size.
                let subtreeViewSize: CGSize? = (subview as? BaseSubtreeView)?.layoutGraphIfNeeded()
                
                // Position the SubtreeView.
                // [(animateLayout ? [subview animator] : subview) setFrameOrigin:nextSubtreeViewOrigin];
                
                if (treeOrientation == .horizontal) || (treeOrientation == .horizontalFlipped) {
                    // Since SubtreeView is unflipped, lay out our child SubtreeViews going upward from our
                    subview!.frame = CGRect(x: nextSubtreeViewOrigin.x,
                                           y: nextSubtreeViewOrigin.y,
                                           width: subtreeViewSize!.width,
                                           height: subtreeViewSize!.height)
                    
                    // Advance nextSubtreeViewOrigin for the next SubtreeView.
                    nextSubtreeViewOrigin.y += subtreeViewSize!.height + siblingSpacing
                    
                    // Keep track of the widest SubtreeView width we encounter.
                    if maxWidth < subtreeViewSize!.width {
                        maxWidth = subtreeViewSize!.width
                    }
                } else {
                    // TODO: Lay out our child SubtreeViews going from our left edge, last to first. SWITCH ME
                    subview!.frame = CGRect(x: nextSubtreeViewOrigin.x,
                                           y: nextSubtreeViewOrigin.y,
                                           width: subtreeViewSize!.width,
                                           height: subtreeViewSize!.height)
                    
                    // Advance nextSubtreeViewOrigin for the next SubtreeView.
                    nextSubtreeViewOrigin.x += subtreeViewSize!.width + siblingSpacing
                    
                    // Keep track of the widest SubtreeView width we encounter.
                    if maxHeight < subtreeViewSize!.height {
                        maxHeight = subtreeViewSize!.height
                    }

                }
            }
        }
        // Calculate the total height of all our SubtreeViews, including the vertical spacing between them.
        // We have N child SubtreeViews, but only (N-1) gaps between them, so subtract 1 increment of
        // siblingSpacing that was added by the loop above.
        
        var totalHeight: CGFloat = 0.0
        var totalWidth: CGFloat = 0.0
        
        if (treeOrientation == .horizontal) || (treeOrientation == .horizontalFlipped) {
            totalHeight = nextSubtreeViewOrigin.y
            if subtreeViewCount > 0 {
                totalHeight -= siblingSpacing
            }
        } else {
            totalWidth = nextSubtreeViewOrigin.x
            if subtreeViewCount > 0 {
                totalWidth -= siblingSpacing
            }
        }
        
        if subtreeViewCount > 0 {
            if treeOrientation == .horizontal || treeOrientation == .horizontalFlipped {
                selfTargetSize = CGSize(width: rootNodeViewSize.width + parentChildSpacing + maxWidth, height: max(totalHeight, rootNodeViewSize.height))
            } else {
                selfTargetSize = CGSize(width: max(totalWidth, rootNodeViewSize.width), height: rootNodeViewSize.height + parentChildSpacing + maxHeight)
            }
            
            // Resize to our new width and height.
            // [(animateLayout ? [self animator] : self) setFrameSize:selfTargetSize];
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: selfTargetSize.width, height: selfTargetSize.height)
            
            var nodeViewOrigin = CGPoint.zero
            if (treeOrientation == .horizontal) || (treeOrientation == .horizontalFlipped) {
                // Position our nodeView vertically centered along the left edge of our new bounds.
                nodeViewOrigin = CGPoint(x: 0.0, y: 0.5 * (selfTargetSize.height - rootNodeViewSize.height))
            } else {
                // Position our nodeView horizontally centered along the top edge of our new bounds.
                nodeViewOrigin = CGPoint(x: 0.5 * (selfTargetSize.width - rootNodeViewSize.width), y: 0.0)
            }
            
            // Pixel-align its position to keep its rendering crisp.
            var windowPoint: CGPoint = convert(nodeViewOrigin, to: nil)
            windowPoint.x = CGFloat(round(Double(windowPoint.x)))
            windowPoint.y = CGFloat(round(Double(windowPoint.y)))
            nodeViewOrigin = convert(windowPoint, from: nil)
            
            nodeView.frame = CGRect(x: nodeViewOrigin.x, y: nodeViewOrigin.y, width: nodeView.frame.size.width, height: nodeView.frame.size.height)
            
            // Position, show our connectorsView and button.
            
            // TODO: Can shrink height a bit on top and bottom ends, since the connecting lines
            // meet at the nodes' vertical centers
            
            // NOTE: It may be better to stretch the content if a collapse animation is added?
            // Be sure to test.  Given the size, and how they just contain the lines,  it seems
            // best to just redraw these things.
            
            // [_connectorsView setContentMode:UIViewContentModeScaleToFill ];
            
            if (treeOrientation == .horizontal) || (treeOrientation == .horizontalFlipped) {
                connectorsView!.frame = CGRect(x: rootNodeViewSize.width, y: 0.0, width: parentChildSpacing, height: selfTargetSize.height)
            } else {
                connectorsView!.frame = CGRect(x: 0.0, y: rootNodeViewSize.height, width: selfTargetSize.width, height: parentChildSpacing)
            }
            
            // NOTE: Enable this line if a collapse animation is added (line below not used)
            // [_connectorsView setContentMode:UIViewContentModeRedraw];
            
            connectorsView!.isHidden = false

        } else {
            // No SubtreeViews; this is a leaf node.
            // Size self to exactly wrap nodeView, hide connectorsView, and hide the button.
            
            selfTargetSize = rootNodeViewSize
            
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: selfTargetSize.width, height: selfTargetSize.height)
            
            nodeView.frame = CGRect(x: 0.0, y: 0.0, width: nodeView.frame.size.width, height: nodeView.frame.size.height)
            
            connectorsView!.isHidden = true
        }
        return selfTargetSize
    }
    
    public func layoutCollapsedGraph() -> CGSize {
        
        // This node is collapsed. Everything will be collapsed behind the leafNode
        let selfTargetSize: CGSize = sizeNodeViewToFitContent()
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: selfTargetSize.width, height: selfTargetSize.height)
        
        for subview in subviews {
            if (subview is BaseSubtreeView) {
                
                (subview as? BaseSubtreeView)?.layoutGraphIfNeeded()
                
                subview.frame = CGRect(x: 0.0, y: 0.0, width: subview.frame.size.width, height: subview.frame.size.height)
                
                subview.isHidden = true
            } else if subview == connectorsView {
                
                // NOTE: It may be better to stretch the content if a collapse animation is added?
                // Be sure to test.  Given the size, and how they just contain the lines,  it seems
                // best to just redraw these things.
                
                // [_connectorsView setContentMode:UIViewContentModeScaleToFill ];
                
                var treeOrientation: TreeGraphOrientationStyle = enclosingTreeGraph!.treeGraphOrientation
                if (treeOrientation == .horizontal) || (treeOrientation == .horizontal) {
                    connectorsView!.frame = CGRect(x: 0.0, y: 0.5 * selfTargetSize.height, width: 0.0, height: 0.0)
                } else {
                    connectorsView!.frame = CGRect(x: 0.5 * selfTargetSize.width, y: 0.0, width: 0.0, height: 0.0)
                }
                
                subview.isHidden = true
            } else if subview == nodeView {
                subview.frame = CGRect.init(x: 0, y: 0, width: selfTargetSize.width, height: selfTargetSize.height)
            }
            
            
        }
        
        return selfTargetSize
        
    }
    
    
    func recursiveSetNeedsGraphLayout() {
        self.needsGraphLayout = true
        for subview in subviews {
            if (subview is BaseSubtreeView) {
                (subview as? BaseSubtreeView)?.recursiveSetNeedsGraphLayout()
            }
        }
    }
    
    
    func flipTreeGraph() {
        var myWidth: CGFloat = frame.size.width
        var myHeight: CGFloat = frame.size.height
        var treeGraph: BaseTreeGraphView? = enclosingTreeGraph
        var treeOrientation: TreeGraphOrientationStyle? = treeGraph?.treeGraphOrientation
        for subview in subviews as? [UIView] ?? [] {
            var subviewCenter: CGPoint = subview.center
            var newCenter = CGPoint.zero
            var offset: CGFloat = 0.0
            if treeOrientation == .horizontalFlipped {
                offset = subviewCenter.x
                newCenter = CGPoint(x: myWidth - offset, y: subviewCenter.y)
            } else {
                offset = subviewCenter.y
                newCenter = CGPoint(x: subviewCenter.x, y: myHeight - offset)
            }
            subview.center = newCenter
            if (subview is BaseSubtreeView) {
                (subview as? BaseSubtreeView)?.flipTreeGraph()
            }
        }
    }
    
    func sizeNodeViewToFitContent() -> CGSize {
        return (self.nodeView).frame.size
    }
    
   
    
    func recursiveSetConnectorsViewsNeedDisplay() {
        connectorsView!.setNeedsDisplay()
        // Recurse for descendant SubtreeViews.
        for subview in subviews as? [UIView] ?? [] {
            if (subview is BaseSubtreeView) {
                (subview as? BaseSubtreeView)?.recursiveSetConnectorsViewsNeedDisplay()
            }
        }

    }
    
    func resursiveSetSubtreeBordersNeedDisplay() {
        self.updateSubtreeBorder()
        
        // Recurse for descendant SubtreeViews.
        for subview in subviews as? [UIView] ?? [] {
            if (subview is BaseSubtreeView) {
                (subview as? BaseSubtreeView)?.updateSubtreeBorder()
            }
        }

    }
    
    func updateSubtreeBorder() {
        
        // // Disable implicit animations during these layer property changes, to make them take effect immediately.
        // BOOL actionsWereDisabled = [CATransaction disableActions];
        // [CATransaction setDisableActions:YES];
        
        // If the enclosing TreeGraph has its "showsSubtreeFrames" debug feature enabled,
        // configure the backing layer to draw its border programmatically.  This is much more efficient
        // than allocating a backing store for each SubtreeView's backing layer, only to stroke a simple
        // rectangle into that backing store.
        
        
        var treeGraph: BaseTreeGraphView? = enclosingTreeGraph
        
        if treeGraph?.showsSubtreeFrames != nil {
            self.layer.borderWidth = subtreeBorderWidth
            self.layer.borderColor = subtreeBorderColor
        } else {
            self.layer.borderWidth = 0.0
        }
        
        // // Disable implicit animations during these layer property changes
        // [CATransaction setDisableActions:actionsWereDisabled];

    }
    
    func modelNode(at p: CGPoint) -> MyTreeGraphModelNode? {
        // Check for intersection with our subviews, enumerating them in reverse order to get
        // front-to-back ordering.  We could use UIView's -hitTest: method here, but we don't
        // want to bother hit-testing deeper than the nodeView level.
        
        var count: Int = subviews.count
        var index: Int = 0
        
        index = count - 1
        while index >= 0 {
            var subview = subviews[index] as? UIView
            
            //        CGRect subviewBounds = [subview bounds];
            var subviewPoint: CGPoint? = subview?.convert(p, from: self)
            //
            //          if (CGPointInRect(subviewPoint, subviewBounds)) {
            
            if subview?.point(inside: subviewPoint ?? CGPoint.zero, with: nil) ?? false {
                
                if subview == nodeView {
                    return modelNode
                } else if (subview is BaseSubtreeView) {
                    return (subview as? BaseSubtreeView)?.modelNode(at: subviewPoint!)
                } else {
                    // Ignore subview. It's probably a BranchView.
                }
            }
            index -= 1
        }
        
        // We didn't find a hit.
        return nil
    }
    
    func modelNodeClosestTo(y: CGFloat) -> MyTreeGraphModelNode? {
        // Do a simple linear search of our subviews, ignoring non-SubtreeViews.  If performance was ever
        // an issue for this code, we could take advantage of knowing the layout order of the nodes to do
        // a sort of binary search.
        
        var subtreeViewWithClosestNodeView: BaseSubtreeView? = nil
        var closestNodeViewDistance: CGFloat = CGFloat(MAXFLOAT)
        
        for subview in subviews as? [UIView] ?? [] {
            if (subview is BaseSubtreeView) {
                var childNodeView: UIView? = (subview as? BaseSubtreeView)?.nodeView
                if childNodeView != nil {
                    var rect = convert(childNodeView?.bounds ?? CGRect.zero, from: childNodeView)
                    var nodeViewDistance = CGFloat(fabs(y - rect.midY))
                    if nodeViewDistance < closestNodeViewDistance {
                        closestNodeViewDistance = nodeViewDistance
                        subtreeViewWithClosestNodeView = subview as? BaseSubtreeView
                    }
                }
            }
        }
        
        return subtreeViewWithClosestNodeView?.modelNode
    }
    
    func modelNodeClosestTo(x: CGFloat) -> MyTreeGraphModelNode? {
        // Do a simple linear search of our subviews, ignoring non-SubtreeViews.  If performance was ever
        // an issue for this code, we could take advantage of knowing the layout order of the nodes to do
        // a sort of binary search.
        
        var subtreeViewWithClosestNodeView: BaseSubtreeView? = nil
        var closestNodeViewDistance: CGFloat = CGFloat(MAXFLOAT)
        
        for subview in subviews as? [UIView] ?? [] {
            if (subview is BaseSubtreeView) {
                var childNodeView: UIView? = (subview as? BaseSubtreeView)?.nodeView
                if childNodeView != nil {
                    var rect = convert(childNodeView?.bounds ?? CGRect.zero, from: childNodeView)
                    var nodeViewDistance = CGFloat(fabs(x - rect.midX))
                    if nodeViewDistance < closestNodeViewDistance {
                        closestNodeViewDistance = nodeViewDistance
                        subtreeViewWithClosestNodeView = subview as? BaseSubtreeView
                    }
                }
            }
        }
        
        return subtreeViewWithClosestNodeView?.modelNode

        return nil
    }
    
    
    
    @IBAction func toggleExpansion(_ sender: Any) {
        UIView.beginAnimations("TreeNodeExpansion", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(.easeOut)
        self.isExpanded = !self.isExpanded
        enclosingTreeGraph!.layoutGraphIfNeeded()
        if modelNode != nil {
            let visibleSet = Set<MyTreeGraphModelNode>(arrayLiteral: self.modelNode)
            self.enclosingTreeGraph?.scrollModelNodesToVisible(visibleSet, animated: false)
        }
        UIView.commitAnimations()
    }
    
    
    // This is not an NSObject class
//    func description() -> String? {
//        return "SubtreeView<\(modelNode.description() ?? "")>"
//    }
//    func nodeSummary() -> String? {
//        return "f=\(NSCoder.string(for: nodeView.frame)) \(modelNode.description() ?? "")"
//    }

//    func treeSummary(withDepth depth: Int) -> String? {
//        let subviewsEnumerator = subviews.enumerated()
//        var subview: UIView?
//        var description = ""
//        var i: Int
//        for i in 0..<depth {
//            description += "  "
//        }
//        description += "\(nodeSummary())\n"
//        while subview = subviewsEnumerator.nextObject() as? UIView {
//            if (subview is PSBaseSubtreeView) {
//                description += (subview as? PSBaseSubtreeView)?.treeSummary(withDepth: depth + 1) ?? ""
//            }
//        }
//        return description
//    }
}
