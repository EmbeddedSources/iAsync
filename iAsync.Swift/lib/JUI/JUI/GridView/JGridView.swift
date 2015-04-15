//
//  JGridView.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 03.01.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

enum JGridOrientation {
    
    case Undefined
    case Vertical
    case Gorizontal
}

private let MinColumnCount = 2

public class JGridView: UIView {

    private var _scrollView: UIScrollView?
    public var scrollView: UIScrollView {
        
        if let result = _scrollView {
            return result
        }
        
        let result = UIScrollView(frame: self.bounds)
        _scrollView = result
        
        result.delegate = scrollViewDelegate
        addSubviewAndScale(result)
        
        return result
    }
    
    @IBOutlet public weak var delegate: JGridViewDelegate?
    
    public func reloadData() {
        
        reloadDataWithRange(activeIndexesRange())
    }
    
    public func reloadDataWithRange(range: Range<Int>) {
        
        removeElementsWithRange(range)
        updateElements()
        expandContentSize()
    }
    
    public func visibleIndexes() -> NSMutableSet {
        
        let range = visibleIndexesRange()
        let result = NSMutableSet(capacity:range.endIndex - range.startIndex)
        
        for index in range {
            result.addObject(index)
        }
        
        return result
    }
    
    public func elementByIndex(index: Int) -> UIView? {
        
        return elementViewByIndex[index]
    }

    public func rectForElementWithIndex(index: Int) -> CGRect {
    
        let col = isVerticalGrid
            ?(index % colCount)
            :index
        
        let row = isVerticalGrid
            ?index / colCount
            :0
        
        let horizontalOffset = delegate?.horizontalOffsetInGridView(self) ?? 0.0
        let vericalOffset    = delegate?.verticalOffsetInGridView(self) ?? 0.0
        
        let colWidth_  = colWidth
        let rowHeight_ = rowHeight
        
        return CGRectMake(
            CGFloat(col) * colWidth_  + horizontalOffset,
            CGFloat(row) * rowHeight_ + vericalOffset   ,
            colWidth_  - horizontalOffset,
            rowHeight_ - vericalOffset)
    }

    public func scrollToIndex(index: Int) {

        if self.colCount < MinColumnCount {
            return
        }
    
        if isVerticalGrid {
    
            self.scrollView.contentOffset = CGPointMake(
                self.scrollView.contentOffset.x,
                CGFloat(index) * self.rowHeight / CGFloat(self.colCount))
        } else {
    
            self.scrollView.contentOffset = CGPointMake(CGFloat(index) * self.colWidth, self.scrollView.contentOffset.y)
        }
    }
    
    public func dequeueReusableElementWithIdentifier(identifier: String) -> UIView? {
        
        if let reusableElements = self.reusableElementsByIdentifier[identifier] {
            
            var reusableElements_ = reusableElements
            let result = reusableElements_.removeLast()
            if reusableElements_.count > 0 {
                self.reusableElementsByIdentifier[identifier] = reusableElements_
            } else {
                self.reusableElementsByIdentifier[identifier] = nil
            }
            return result
        }
    
        return nil
    }
    
    public func removeElementWithIndex(index: Int, animated: Bool) {
        
        removeElementAtIndex(index)
        reindexElementsFromIndex(index)
        prepareNewVisibleElementAtIndex(index)
        relayoutElementsAnimated(animated)
    }
    
    lazy private var elementViewByIndex: [Int:UIView] = [:]
    
    private func activeIndexesRange() -> Range<Int> {
    
        let activeIndexes = Array(elementViewByIndex.keys)
        if elementViewByIndex.count == 0 {
            return 0..<0
        }
        
        let sortedActiveIndexes = sorted(activeIndexes)
        
        return sortedActiveIndexes[0]..<sortedActiveIndexes.last!
    }
    
    private func removeElementsWithRange(range: Range<Int>) {
        
        for index in range {
            removeElementAtIndex(index)
        }
    
        relayoutElementsAnimated(false)
    }

    private func updateElements() {
    
        let indexesToUpdate_ = indexesToUpdate().allObjects
    
        removeUnvisibleElements()
    
        for index in indexesToUpdate_ {
            updateElementAtIndex(index as Int)
        }
    }
    
    private func expandContentSize() {
    
        let numberOfElements = delegate?.numberOfElementsInGridView(self) ?? 0
        
        let rowCount_ = isVerticalGrid
            ?Int(ceil(CGFloat(numberOfElements) / CGFloat(colCount)))
            :1
        
        let colCount_ = isVerticalGrid
            ?colCount
            :numberOfElements
    
        let width  = colWidth  * CGFloat(colCount_) + (delegate?.horizontalOffsetInGridView(self) ?? 0.0)
        let height = rowHeight * CGFloat(rowCount_) + (delegate?.verticalOffsetInGridView(self) ?? 0.0)
        
        scrollView.contentSize = CGSizeMake(width, height)
    }
    
    private func removeElementAtIndex(index: Int) {
        
        if let dictIndex = elementViewByIndex.indexForKey(index) {
            
            let viewAndKey = elementViewByIndex[dictIndex]
            viewAndKey.1.removeFromSuperview()
            elementViewByIndex.removeAtIndex(dictIndex)
        }
    }
    
    private func relayoutElementsAnimated(animated: Bool) {
        
        let animations = { () -> () in
            
            for (index, view) in self.elementViewByIndex {
                view.frame = self.rectForElementWithIndex(index)
            }
            
            self.updateElements()
            self.expandContentSize()
        }
        
        if animated {
            UIView.animateWithOptions(.CurveEaseIn | .BeginFromCurrentState, animations:animations)
        } else {
            animations()
        }
    }
    
    private func indexesToUpdate() -> NSSet {
        
        let elementsIndexes = NSMutableSet(array:Array(elementViewByIndex.keys))
        let result = visibleIndexes()
        result.minusSet(elementsIndexes)
        return result
    }
    
    private func unvisibleElementsIndexes() -> NSMutableSet {
        
        let result = NSMutableSet(array:Array(elementViewByIndex.keys))
        let visibleIndexes_ = visibleIndexes()
        result.minusSet(visibleIndexes_)
        return result
    }
    
    private func removeUnvisibleElements() {
        
        let unvisibleElementsIndexes_ = unvisibleElementsIndexes()
        
        for numIndex in unvisibleElementsIndexes_ {
            
            let index = numIndex as Int
            
            if let dictIndex = elementViewByIndex.indexForKey(index) {
                
                let indexWithView = elementViewByIndex[dictIndex]
                
                makeReusableElement(indexWithView.1)
                elementViewByIndex.removeAtIndex(dictIndex)
                indexWithView.1.removeFromSuperview()
            }
        }
    }
    
    private func updateElementAtIndex(index: Int, position: Int) {
        
        let view = (delegate?.gridView(self, elementAtIndex:index))!
        
        view.frame = rectForElementWithIndex(position)
        view.autoresizingMask = .None
        
        scrollView.addSubview(view)
        scrollView.sendSubviewToBack(view)
        
        elementViewByIndex[index] = view
    }
    
    private func updateElementAtIndex(index: Int) {
    
        updateElementAtIndex(index, position: index)
    }
    
    private func visibleIndexesRange() -> Range<Int> {
    
        let fromIndex = firstVisibleIndex
        let toIndex   = lastVisibleIndex
    
        return fromIndex..<toIndex
    }
    
    private var isVerticalGrid: Bool {
    
        return delegate?.verticalGridView?(self) ?? true
    }
    
    private var rowHeight: CGFloat {
        
        if isVerticalGrid {
    
            return colWidth * (delegate?.widthHeightRelationInGridView(self) ?? 0.0)
        }
        return max(1.0, self.frame.size.height - (delegate?.verticalOffsetInGridView(self) ?? 0.0))
    }
    
    private var colWidth: CGFloat {
        
        if isVerticalGrid {
    
            return (self.frame.size.width - (delegate?.horizontalOffsetInGridView(self) ?? 0.0)) / CGFloat(colCount)
        }
        return rowHeight / (self.delegate?.widthHeightRelationInGridView(self) ?? 1.0)
    }
    
    private var colCount: Int {
    
        return delegate?.numberOfElementsInRowInGridView(self) ?? 0
    }
    
    private var currentlyUsedIndex = 0
    
    private var firstVisibleIndex: Int {
    
        let fromIndex = { () -> Int in
            
            if self.isVerticalGrid {
                return Int(floor(self.scrollView.contentOffset.y / self.rowHeight) * CGFloat(self.colCount))
            }
            return Int(floor(self.scrollView.contentOffset.x / self.colWidth))
        }()
        
        let numberOfElements = delegate?.numberOfElementsInGridView(self) ?? 0
        
        self.currentlyUsedIndex = min(numberOfElements, max(0, fromIndex))
        
        return min(numberOfElements, max(0, fromIndex))
    }
    
    private var lastVisibleIndex: Int {
        
        let toIndex = { () -> Int in
            if self.isVerticalGrid {
    
                let vericalOffset = self.delegate?.verticalOffsetInGridView(self) ?? 0.0
                let bottomScrollOffset = self.scrollView.contentOffset.y - vericalOffset + self.frame.size.height
                return Int(ceil((bottomScrollOffset) / self.rowHeight) * CGFloat(self.colCount))
            }
    
            let horizontalOffset  = self.delegate?.horizontalOffsetInGridView(self) ?? 0.0
            let rightScrollOffset = self.scrollView.contentOffset.x - horizontalOffset + self.frame.size.width
            return Int(ceil(rightScrollOffset / self.colWidth))
        }()
    
        let numberOfElements = delegate?.numberOfElementsInGridView(self) ?? 0
        return min(numberOfElements, max(0, toIndex))
    }
    
    lazy private var reusableElementsByIdentifier: [String:[UIView]] = [:]
    
    private func makeReusableElement(view: UIView) {
        
        if let index = self.reusableElementsByIdentifier.indexForKey(view.jffGridViewReuseIdentifier()) {
           
            let reusableElements = self.reusableElementsByIdentifier[index]
            var allElements = reusableElements.1
            allElements.append(view)
            self.reusableElementsByIdentifier[reusableElements.0] = allElements
        } else {
            
            self.reusableElementsByIdentifier[view.jffGridViewReuseIdentifier()] = [view]
        }
    }
    
    private func reindexElementsFromIndex(var index: Int) {
        
        var view = elementViewByIndex[++index]
        while view != nil {
    
            let newIndex = index - 1
    
            elementViewByIndex[newIndex] = view
            elementViewByIndex.removeValueForKey(index)
    
            delegate?.gridView?(self, didMoveElement:view!, toIndex:index - 1)
    
            view = elementViewByIndex[++index]
        }
    }
    
    private func prepareNewVisibleElementAtIndex(actIndex: Int) {
        
        let lastVisibleIndex_ = lastVisibleIndex - 1
        let view = elementViewByIndex[lastVisibleIndex_]
        let elementView = view
        if elementView == nil
            && lastVisibleIndex < (delegate?.numberOfElementsInGridView(self) ?? 0)
            && actIndex <= lastVisibleIndex
        {
            updateElementAtIndex(lastVisibleIndex_, position:lastVisibleIndex_ + 1)
        }
    }

    private var forceRelayout = false
    public override func setNeedsLayout() {

        forceRelayout = true
        super.setNeedsLayout()
    }
    
    private var previousFrame = CGRectZero
    public override func layoutSubviews() {
    
        if forceRelayout || !CGRectEqualToRect(frame, previousFrame) {
            reloadScrollView()
            relayoutElements()
        }
        
        previousFrame = self.frame
        forceRelayout = false
    }
    
    private var prevOrientation: JGridOrientation = .Undefined
    private func reloadScrollView() {

        if self.colCount < 2 {/// Temp solution to avoid core during Teasers View Init
            return
        }
    
        if isVerticalGrid && prevOrientation != .Vertical {
    
            scrollView.contentOffset = CGPointMake(
                scrollView.contentOffset.x,
                CGFloat(currentlyUsedIndex) * rowHeight / CGFloat(colCount))
    
            prevOrientation = .Vertical
        } else if !isVerticalGrid && prevOrientation != .Gorizontal {
    
            scrollView.contentOffset = CGPointMake(
                CGFloat(currentlyUsedIndex) * colWidth,
                scrollView.contentOffset.y)
            prevOrientation = .Gorizontal
        }
    }
    
    private func relayoutElements() {
        
        relayoutElementsAnimated(false)
    }
    
    private class ScrollViewDelegate : NSObject, UIScrollViewDelegate {
        
        private unowned let gridView: JGridView
        init(gridView: JGridView) {
            
            self.gridView = gridView
            
            super.init()
            
            gridView.scrollView.delegate = self
        }
        
        func scrollViewDidScroll(scrollView: UIScrollView) {
            
            gridView.updateElements()
        }
    }
    
    private var _scrollViewDelegate: ScrollViewDelegate?
    private var scrollViewDelegate: ScrollViewDelegate {
        get {
            if let result = _scrollViewDelegate {
                return result
            }
            
            let result = ScrollViewDelegate(gridView: self)
            _scrollViewDelegate = result
            return result
        }
    }
    
    deinit {
        scrollView.delegate = nil
    }
}

private extension UIView {

    class func jffGridViewReuseIdentifier() -> String {
        return NSStringFromClass(UIView.self)
    }
    
    func jffGridViewReuseIdentifier() -> String {
        return UIView.jffGridViewReuseIdentifier()
    }
}
