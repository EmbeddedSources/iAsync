//
//  JGridViewDelegate.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 03.01.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import UIKit

@objc public protocol JGridViewDelegate {

    func numberOfElementsInGridView(gridView: JGridView) -> Int
    
    func numberOfElementsInRowInGridView(gridView: JGridView) -> Int
    
    func gridView(gridView: JGridView, elementAtIndex index: Int) -> UIView
    
    func widthHeightRelationInGridView(gridView: JGridView) -> CGFloat
    
    func horizontalOffsetInGridView(gridView: JGridView) -> CGFloat
    
    func verticalOffsetInGridView(gridView: JGridView) -> CGFloat
    
    optional func gridView(gridView: JGridView, removeElementAtIndex index: Int) -> ()
    
    optional func gridView(gridView: JGridView, didMoveElement view: UIView, toIndex index: Int) -> ()
    
    optional func verticalGridView(gridView: JGridView) -> Bool
}
