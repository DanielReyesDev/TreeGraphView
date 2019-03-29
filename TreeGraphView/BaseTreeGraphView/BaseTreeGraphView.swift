//
//  BaseTreeGraphView.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/21/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import UIKit

open class BaseTreeGraphView: UIView {
    
    public var _modelNodeToSubtreeViewMapTable:NSMutableDictionary!
    public var _nodeViewNibName:String!
    public var _cachedNodeViewNib:UINib?
    public var animatesLayout:Bool = true
    public var layoutAnimationSuppressed:Bool = false
    public var showsSubtreeFrames:Bool = false
    // Styling
    
    public var connectingLineColor:UIColor = UIColor.black {
        didSet {
            if connectingLineColor != oldValue {
                self.rootSubtreeView.recursiveSetConnectorsViewsNeedDisplay()
            }
        }
    }

    public var contentMargin:CGFloat = 20.0 {
        didSet {
            if contentMargin != oldValue {
                self.setNeedsGraphLayout()
            }
        }
    }
    public var parentChildSpacing:CGFloat = 50.0 {
        didSet {
            if parentChildSpacing != oldValue {
                self.setNeedsGraphLayout()
            }
        }
    }
    public var siblingSpacing:CGFloat = 30.0 {
        didSet {
            if siblingSpacing != oldValue {
                self.setNeedsGraphLayout()
            }
        }
    }
    public var treeGraphOrientation:TreeGraphOrientationStyle = .horizontal {
        didSet {
            if treeGraphOrientation != oldValue {
                self.rootSubtreeView.recursiveSetConnectorsViewsNeedDisplay()
            }
        }
    }
    public var treeGraphFlipped:Bool = false {
        didSet {
            if treeGraphFlipped != oldValue {
                self.rootSubtreeView.recursiveSetConnectorsViewsNeedDisplay()
            }
        }
    }
    public var connectingLineStyle:TreeGraphConnectingLineStyle = .orthogonal {
        didSet {
            if connectingLineStyle != oldValue {
                self.rootSubtreeView.recursiveSetConnectorsViewsNeedDisplay()
            }
        }
    }
    public var connectingLineWidth:CGFloat = 1.0 {
        didSet {
            if connectingLineWidth != oldValue {
                self.rootSubtreeView.recursiveSetConnectorsViewsNeedDisplay()
            }
        }
    }
    // TODO:- Double check this initial value
    public var setResizesToFillEnclosingScrollView:Bool = false {
        didSet {
            if setResizesToFillEnclosingScrollView != oldValue {
                self.updateFrameSizeForContentAndClipView()
                self.updateRootSubtreeViewPosition(for: self.rootSubtreeView.frame.size)
            }
        }
    }
    // TODO:- Double check this initial value
    public var setShowsSubtreeFrames:Bool = false {
        didSet {
            if setShowsSubtreeFrames != oldValue {
                self.rootSubtreeView.resursiveSetSubtreeBordersNeedDisplay()
            }
        }
    }
    
    // MARK:- Root SubtreeView Access
    
    public var rootSubtreeView:BaseSubtreeView {
        return self.subtreeView(for: self.modelRoot)
    }
    
    // Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        styleDefaults()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    init(modelNode newModelNode: MyTreeGraphModelNode?) {
//        assert(newModelNode != nil, "Invalid parameter not satisfying: newModelNode != nil")
//
//        super.init(frame: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 25.0))
//        // Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
//        // method, since they may wrongly expect the instance to be fully formed.
//
//        isExpanded = true
//        needsGraphLayout = true
//
//        // autoresizesSubviews defaults to YES.  We don't want autoresizing, which would interfere
//        // with the explicit layout we do, so we switch it off for SubtreeView instances.
//        autoresizesSubviews = false
//
//        modelNode = newModelNode
//        connectorsView = BaseBranchView(frame: CGRect.zero)
//    }
    
    func styleDefaults() {
        // External styling
        self.connectingLineColor = UIColor.black
        self.contentMargin = 20.0
        self.parentChildSpacing = 50.0
        self.siblingSpacing = 30.0
        self.animatesLayout = true
        self.resizesToFillEnclosingScrollView = true
        self.treeGraphFlipped = false
        self.treeGraphOrientation = .horizontal
        self.connectingLineStyle = .orthogonal
        self.connectingLineWidth = 1.0
        
        // Internal config
        self.layoutAnimationSuppressed = false
        self.showsSubtreeFrames = false
        self.minimumFrameSize = CGSize.init(width: 2.0 * contentMargin, height: 2.0 * contentMargin)
        self.selectedModelNodes = Set<MyTreeGraphModelNode>() //Set<MyTreeGraphModelNode>()
        self._modelNodeToSubtreeViewMapTable = NSMutableDictionary()
//        if self.inputView == nil {
//            self.inputView = UIView(frame: CGRect.zero)
//        }
    }
    
    deinit {
        self.delegate = nil
    }
    
    
    
    // MARK:- Node View Nib Caching
    
    public func cachedNodeViewNib() -> UINib? {
        return self._cachedNodeViewNib
    }
    
    public func setCachedNodeViewNib(nib:UINib?) {
        self._cachedNodeViewNib = nib
    }
    
    //MARK:- Node View Nib Specification
    
    public func setNodeViewNibName(name:String) {
        if _nodeViewNibName != name {
            self.setCachedNodeViewNib(nib: nil)
            self._nodeViewNibName = name
        }
    }
    
    // MARK:- Selection State
    
//    func setSelectedModelNodes(_ newSelectedModelNodes: Set<MyTreeGraphModelNode>) {
//        if selectedModelNodes != newSelectedModelNodes {
//            var combinedSet:NSMutableSet = selectedModelNodes.mutableCopy() as! NSMutableSet
//            combinedSet.union(newSelectedModelNodes)
//
//            var intersectionSet:NSMutableSet = selectedModelNodes.mutableCopy() as! NSMutableSet
//            intersectionSet.intersect(newSelectedModelNodes)
//
//            var differenceSet:NSMutableSet = combinedSet
//            differenceSet.minus(intersectionSet)
//
//            // Discard the old selectedModelNodes set and replace it with the new one.
//            selectedModelNodes = newSelectedModelNodes
//        }
//    }
    
    var selectedModelNodes = Set<MyTreeGraphModelNode>()
    
    func setSelectedModelNodes(_ newSelectedModelNodes: Set<MyTreeGraphModelNode>) {
        
        if selectedModelNodes != newSelectedModelNodes {
            
            let union = selectedModelNodes.union(newSelectedModelNodes)
            
            let intersection = selectedModelNodes.intersection(newSelectedModelNodes)
            
            let difference = union
            union.subtracting(intersection)
            
            selectedModelNodes = newSelectedModelNodes
        }
    }
    
    func singleSelectedModelNode() -> MyTreeGraphModelNode? {
        let selection = self.selectedModelNodes
        return (selection.count == 1) ? selection.randomElement() : nil
    }
    
    func selectionBounds() -> CGRect {
        return boundsOfModelNodes(self.selectedModelNodes)
    }

    
    // MARK:- Graph Building
    
    func newGraph(for modelNode: MyTreeGraphModelNode) -> BaseSubtreeView {
        
        var subtreeView = BaseSubtreeView(modelNode: modelNode)
        
        var nib:UINib!
        if let nodeViewNib = self.cachedNodeViewNib() {
            nib = nodeViewNib
        } else {
            if let nibname = self._nodeViewNibName {
                nib = UINib.init(nibName: nibname, bundle: Bundle.main)
                self._cachedNodeViewNib = nib
            }
        }
        
        let nibViews = nib.instantiate(withOwner: subtreeView, options: nil)
        subtreeView.addSubview(subtreeView.nodeView)
        
        // TODO:- Change this
        if let childModelNodes = modelNode.childNodes() {
            for case let node as MyTreeGraphModelNode in childModelNodes {
                let childSubtreeView = self.newGraph(for: node)
                subtreeView.insertSubview(childSubtreeView, belowSubview: subtreeView.modelNode!)
            }
        }
        return subtreeView
    }
    
    func buildGraph() {
        if let root = self.modelRoot {
            let rootSubtreeView = self.newGraph(for: root)
            self.addSubview(rootSubtreeView)
        }
    }
    
    
    // Mark:- Layout
    
    func updateFrameSizeForContentAndClipView() {
        var newFrameSize: CGSize
        let newMinimumFrameSize: CGSize = minimumFrameSize
        
        // TODO: Additional checks to ensure we are in a UIScrollView
        let enclosingScrollView = superview as? UIScrollView
        
        
        if resizesToFillEnclosingScrollView && enclosingScrollView != nil {
            
            // This TreeGraph is a child of a UIScrollView: Size it to always fill the content area (at minimum).
            
            let contentViewBounds: CGRect? = enclosingScrollView?.bounds
            
            let width = max(newMinimumFrameSize.width, contentViewBounds!.size.width)
            let height = max(newMinimumFrameSize.height, contentViewBounds!.size.height)
            
            newFrameSize = CGSize.init(width: width, height: height)
            
            enclosingScrollView?.contentSize = newFrameSize
        } else {
            newFrameSize = newMinimumFrameSize
        }
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newFrameSize.width, height: newFrameSize.height)
        
    }
    
    
    func updateRootSubtreeViewPosition(for rootSubtreeViewSize: CGSize) {
        // Position the rootSubtreeView within the TreeGraph.
        let rootSubtreeView: BaseSubtreeView? = self.rootSubtreeView
        
        // BOOL animateLayout = [self animatesLayout] && ![self layoutAnimationSuppressed];
        var newOrigin: CGPoint
        if resizesToFillEnclosingScrollView {
            let bounds: CGRect = self.bounds
            
            if (treeGraphOrientation == .horizontal) || (treeGraphOrientation == .horizontalFlipped) {
                newOrigin = CGPoint(x: contentMargin, y: 0.5 * (bounds.size.height - rootSubtreeViewSize.height))
            } else {
                newOrigin = CGPoint(x: 0.5 * (bounds.size.width - rootSubtreeViewSize.width), y: contentMargin)
            }
        } else {
            newOrigin = CGPoint(x: contentMargin, y: contentMargin)
        }
        
        rootSubtreeView!.frame = CGRect(x: newOrigin.x, y: newOrigin.y, width: rootSubtreeView!.frame.size.width, height: rootSubtreeView!.frame.size.height)
    }
    
    func parentClipViewDidResize(object:Any) {
        let enclosingScrollView = self.superview as! UIScrollView
        self.updateFrameSizeForContentAndClipView()
        self.updateRootSubtreeViewPosition(for: self.rootSubtreeView.frame.size)
        self.scrollSelectedModelNodesToVisibleAnimated(false)
    }
    
    
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutGraphIfNeeded()
    }
    
    func layoutGraphIfNeeded() -> CGSize {
        let rootSubtreeView: BaseSubtreeView? = self.rootSubtreeView
        if needsGraphLayout && modelRoot != nil {
            
            // Do recursive graph layout, starting at our rootSubtreeView.
            let rootSubtreeViewSize: CGSize? = rootSubtreeView?.layoutGraphIfNeeded()
            
            // Compute self's new minimumFrameSize.  Make sure it's pixel-integral.
            let margin = contentMargin
            let width = (rootSubtreeViewSize?.width ?? 0.0) + 2.0 * margin
            let height = (rootSubtreeViewSize?.height ?? 0.0) + 2.0 * margin
            let minimumBoundsSize = CGSize(width: width, height: height)
            
            minimumFrameSize = minimumBoundsSize
            
            // Set the TreeGraph's frame size.
            updateFrameSizeForContentAndClipView()
            
            // Position the TreeGraph's root SubtreeView.
            updateRootSubtreeViewPosition(for: rootSubtreeViewSize!)
            
            if (treeGraphOrientation == .horizontalFlipped) || (treeGraphOrientation == .verticalFlipped) {
                rootSubtreeView?.flipTreeGraph()
            }
            return rootSubtreeViewSize!
        } else {
            return rootSubtreeView != nil ? rootSubtreeView!.frame.size : CGSize.zero ?? CGSize.zero
        }
        
    }
    
    
    public var needsGraphLayout: Bool {
        get {
            return self.rootSubtreeView.needsGraphLayout
        }
        set{}
    }
    
    func setNeedsGraphLayout() {
        self.rootSubtreeView.recursiveSetNeedsGraphLayout()
    }
    
    func collapseRoot() {
        self.rootSubtreeView.setExpanded(flag: false)
    }
    
    func expandRoot() {
        self.rootSubtreeView.setExpanded(flag: true)
    }
    
    // IBAction
    func toggleExpansionOfSelectedModelNodes(sender: Any) {
        for node in self.selectedModelNodes {
            let subtreeView = self.subtreeView(for: node)
            subtreeView.toggleExpansion(sender)
        }
    }
    
    
    // MARK:- Scrolling
    
    func boundsOfModelNodes(_ nodes: Set<MyTreeGraphModelNode>) -> CGRect {
        var boundingBox = CGRect.zero
        var firstNodeFound = false
        
        for node in nodes {
            let subtreeView = self.subtreeView(for: node)
            if subtreeView.isHidden == false {
                let nodeView = subtreeView.nodeView
                let rect = self.convert(nodeView!.bounds, from: nodeView)
                if !firstNodeFound {
                    boundingBox = rect
                    firstNodeFound = true
                } else {
                    boundingBox = boundingBox.union(rect)
                }
            }
        }
        return boundingBox
    }
    
    
    func scrollModelNodesToVisible(_ modelNodes: Set<MyTreeGraphModelNode>, animated: Bool) {
        var targetRect: CGRect = boundsOfModelNodes(modelNodes)
        if !targetRect.isEmpty {
            let padding = contentMargin
            
            let parentScroll = superview as? UIScrollView
            
            if parentScroll != nil && (parentScroll is UIScrollView) {
                targetRect = targetRect.insetBy(dx: -padding, dy: -padding)
                parentScroll?.scrollRectToVisible(targetRect, animated: animated)
            }
        }
    }
    
    func scrollSelectedModelNodesToVisibleAnimated(_ animated:Bool) {
        self.scrollModelNodesToVisible(self.selectedModelNodes, animated: animated)
    }
    
    
    // Mark:- DataSource
    
    func setModelRoot(newModelRoot: MyTreeGraphModelNode) {
        if modelRoot != newModelRoot {
            let rootSubtreeView = self.rootSubtreeView
            rootSubtreeView.removeFromSuperview()
            _modelNodeToSubtreeViewMapTable.removeAllObjects()
            
            modelRoot = newModelRoot
            
            self.buildGraph()
            self.setNeedsDisplay()
            self.rootSubtreeView.resursiveSetSubtreeBordersNeedDisplay()
            self.layoutGraphIfNeeded()
            
            if (modelRoot != nil) {
                self.selectedModelNodes = Set<MyTreeGraphModelNode>.init(arrayLiteral: modelRoot)
                
                self.scrollSelectedModelNodesToVisibleAnimated(false)
            }
        }
    }
    
    
    // MARK:- Node Hit-Testing
    func modelNode(at p: CGPoint) -> MyTreeGraphModelNode? {
        let rootSubtreeView = self.rootSubtreeView
        let subviewPoint = self.convert(p, to: rootSubtreeView)
        let hitModelNode = self.rootSubtreeView.modelNode(at: subviewPoint)
        
        self.delegate?.didSelectNodeView(node: hitModelNode!)
        
        return hitModelNode
    }
    
    // MARK:- Input and navigation
    
    // Make TreeGraphs able to -canBecomeFirstResponder, so they can receive key events.
    open override func becomeFirstResponder() -> Bool {
        return true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let viewPoint = touch?.location(in: self) else {return}
        
        if let hitModelNode = self.modelNode(at: viewPoint) {
            self.selectedModelNodes = Set<MyTreeGraphModelNode>.init(arrayLiteral: hitModelNode)
        } else {
            self.selectedModelNodes = Set<MyTreeGraphModelNode>()
        }
        
        self.becomeFirstResponder()
    }
    
    func sibling(of modelNode:MyTreeGraphModelNode, at relativeIndex:Int) -> MyTreeGraphModelNode? {
        
        if modelNode == self.modelRoot {
            return nil
        }
        
        let parent = modelNode.parent()
        if let siblings = parent?.childNodes() {
            var index = 0
            for (i,sib) in siblings.enumerated() {
                if sib == modelNode {
                    index = i
                    break
                }
            }
            index += relativeIndex
            if index >= 0 && index < siblings.count {
                return siblings[index]
            }
        }
        
        return nil
    }
    
    func moveToSibling(by relativeIndex:Int) {
        if let modelNode = self.singleSelectedModelNode() {
            let sibling = self.sibling(of: modelNode, at: relativeIndex)!
            self.selectedModelNodes.insert(sibling)
        } else if self.selectedModelNodes.count == 0 {
//            self.selectedModelNodes = self.modelRoot ? Set<MyTreeGraphModelNode>(arrayLiteral: self.modelRoot) : nil
            self.selectedModelNodes = Set<MyTreeGraphModelNode>(arrayLiteral: self.modelRoot)
        }
        
        self.scrollSelectedModelNodesToVisibleAnimated(true)
    }
    
    // IBAction
    func moveToParent(sender:Any) {
        if let modelNode = self.singleSelectedModelNode() {
            if modelNode != self.modelRoot {
                if let parent = modelNode.parent() {
                    self.selectedModelNodes = Set(arrayLiteral: parent)
                    
                }
            }
        } else if self.selectedModelNodes.count == 0 {
            self.selectedModelNodes = Set.init(arrayLiteral: self.modelRoot)
        }
        // Scroll new selection to visible.
        self.scrollSelectedModelNodesToVisibleAnimated(true)
    }
    
    // IBAction
    func moveToNearestChild(sender: Any) {
        if let modelNode = self.singleSelectedModelNode() {
            let subtreeView = self.subtreeView(for: modelNode)
            if subtreeView.isExpanded {
                let nodeView = subtreeView.nodeView
                let nodeViewFrame = nodeView?.frame
                
                var nearestChild: MyTreeGraphModelNode
                
                if self.treeGraphOrientation == .horizontal || self.treeGraphOrientation == .horizontalFlipped {
                    nearestChild = subtreeView.modelNodeClosestTo(y: nodeViewFrame!.midY)!
                } else {
                    nearestChild = subtreeView.modelNodeClosestTo(x: nodeViewFrame!.midX)!
                }
                
                self.selectedModelNodes = Set(arrayLiteral: nearestChild)
            }
        } else if self.selectedModelNodes.count == 0 {
            self.selectedModelNodes = Set(arrayLiteral: self.modelRoot)
        }
        
        self.scrollSelectedModelNodesToVisibleAnimated(true)
    }
    
    
    func moveUp( sender:Any ) {
        if self.treeGraphOrientation == .horizontal || self.treeGraphOrientation == .horizontalFlipped {
            self.moveToSibling(by: 1)
        }
    }
    
    func moveDown( sender:Any ) {
        if self.treeGraphOrientation == .horizontal || self.treeGraphOrientation == .horizontalFlipped {
            self.moveToSibling(by: -1)
        }
    }
    
    func moveLeft( sender:Any ) {
        if self.treeGraphOrientation == .horizontal || self.treeGraphOrientation == .horizontalFlipped {
            self.moveToParent(sender: sender)
        }
    }
    
    
    func moveRight( sender:Any ) {
        if self.treeGraphOrientation == .horizontal || self.treeGraphOrientation == .horizontalFlipped {
            self.moveToNearestChild(sender: sender)
        }
    }
    
    
    
    
    
    
    
    
    // MARK:- ModelNode -> SubtreeView Relationship Management
    
    func subtreeViewForModelNode(node: MyTreeGraphModelNode) -> BaseSubtreeView? {
        return _modelNodeToSubtreeViewMapTable?[node] as? BaseSubtreeView
    }
    
    
    func setSubtreeView(_ subtreeView: BaseSubtreeView, for modelNode: MyTreeGraphModelNode) {
        _modelNodeToSubtreeViewMapTable[modelNode] = subtreeView
    }
    
    // MARK:- Model Tree Navigation
    
    public var modelRoot: MyTreeGraphModelNode!
    
    public var minimumFrameSize:CGSize!
    public var resizesToFillEnclosingScrollView:Bool!

    
    
    public weak var delegate:TreeGraphDelegate?

    
    
    
    public func subtreeView(for modelNode:MyTreeGraphModelNode) -> BaseSubtreeView {
        return _modelNodeToSubtreeViewMapTable[modelNode]! as! BaseSubtreeView
    }
    
    func recursiveSetNeedsGraphLayout() {
        self.needsGraphLayout = true
        for subview in subviews {
            if (subview is BaseSubtreeView) {
                (subview as? BaseSubtreeView)?.recursiveSetNeedsGraphLayout()
            }
        }
    }

    
}
