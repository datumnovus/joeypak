//
//  HighlightedButtonNode.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class HighlightedButtonNode: ASButtonNode {
    private let defaultBackgroundColor = UIColor.joeyPakGray
    private let selectedBackgroundColor = UIColor.joeyPakGreen
    override init() {
        super.init()
        backgroundColor = defaultBackgroundColor
        
        addTarget(self, action: #selector(pressed), forControlEvents:[ASControlNodeEvent.touchDown, ASControlNodeEvent.touchDragInside])
        addTarget(self, action: #selector(released), forControlEvents:[ASControlNodeEvent.touchUpInside, ASControlNodeEvent.touchUpOutside, ASControlNodeEvent.touchDragOutside, ASControlNodeEvent.touchCancel])
    }
    override func didLoad() {
        super.didLoad()
        layer.cornerRadius = 6
    }
    
    //MARK: Actions
    @objc private func pressed() {
        backgroundColor = selectedBackgroundColor
    }
    @objc private func released() {
        backgroundColor = defaultBackgroundColor
    }
}
