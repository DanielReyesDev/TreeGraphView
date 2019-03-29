//
//  BaseLeafView.swift
//  TreeGraphView
//
//  Created by Daniel Reyes Sánchez on 3/22/19.
//  Copyright © 2019 Robert Bosch. All rights reserved.
//

import UIKit
import QuartzCore

class BaseLeafView: UIView {
    
    var borderColor:UIColor! {
        didSet {
            if borderColor != oldValue {
                self.updateLayerAppearanceToMatchContainerView()
            }
        }
    }
    
    var borderWidth:CGFloat! {
        didSet {
            if borderWidth != oldValue {
                self.updateLayerAppearanceToMatchContainerView()
            }
        }
    }
    
    var cornerRadius:CGFloat! {
        didSet {
            if cornerRadius != oldValue {
                self.updateLayerAppearanceToMatchContainerView()
            }
        }
    }
    
    var fillColor:UIColor! {
        didSet {
            if fillColor != oldValue {
                self.updateLayerAppearanceToMatchContainerView()
            }
        }
    }
    
    var selectionColor:UIColor! {
        didSet {
            if selectionColor != oldValue {
                self.updateLayerAppearanceToMatchContainerView()
            }
        }
    }
    
    var isShowingSelected:Bool = false
    
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupDefaultStyle()
        updateLayerAppearanceToMatchContainerView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupDefaultStyle() {
        self.cornerRadius = 8.0
        self.borderWidth = 0
        self.isShowingSelected = false
        self.fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        self.selectionColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)

    }
    
    func updateLayerAppearanceToMatchContainerView() {
        let scaleFactor: CGFloat = 1.0
        let layer: CALayer? = self.layer
        layer?.borderWidth = borderWidth * scaleFactor
        if borderWidth > 0.0 {
            layer?.borderColor = borderColor.cgColor
        }
        layer?.cornerRadius = cornerRadius * scaleFactor
        if isShowingSelected {
            layer?.backgroundColor = selectionColor.cgColor
        } else {
            layer?.backgroundColor = fillColor.cgColor
        }
    }

    
    
}
