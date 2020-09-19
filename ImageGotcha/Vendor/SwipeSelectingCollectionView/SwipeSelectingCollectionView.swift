//
//  SwipeSelectingCollectionView.swift
//  TileTime
//
//  Created by Shane Qi on 7/2/17.
//  Copyright © 2017 Shane Qi. All rights reserved.
//

import UIKit

public class SwipeSelectingCollectionView: UICollectionView {
    
    public var isSwipeSelectingEnable: Bool = false {
        didSet {
            panSelectingGestureRecognizer.isEnabled = isSwipeSelectingEnable
        }
    }
    private var beginIndexPath: IndexPath?
    private var selectingRange: ClosedRange<IndexPath>?
    private var selectingMode: SelectingMode = .selecting
    private var selectingIndexPaths = Set<IndexPath>()
    private var autoScrollOperationQueue = OperationQueue.main
    private var isAutoStartScroll = false
    private var autoScrollSpeed: CGFloat = 20
    private var autoScrollDirection: AutoScrollDirection?
    private enum AutoScrollDirection {
        case up, down
    }
    private enum SelectingMode {
        case selecting, deselecting
    }

    lazy private var panSelectingGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = SwipeSelectingGestureRecognizer(
            target: self,
            action: #selector(SwipeSelectingCollectionView.didPanSelectingGestureRecognizerChange(gestureRecognizer:)))
        gestureRecognizer.isEnabled = isSwipeSelectingEnable
        return gestureRecognizer
    } ()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gestureRecognizers?.append(panSelectingGestureRecognizer)
        allowsMultipleSelection = true
    }

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        gestureRecognizers?.append(panSelectingGestureRecognizer)
        allowsMultipleSelection = true
    }

    @objc private func didPanSelectingGestureRecognizerChange(gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        switch gestureRecognizer.state {
        case .began:
            self.beginIndexPath = indexPathForItem(at: point)
            if let indexPath = beginIndexPath
             , let isSelected = cellForItem(at: indexPath)?.isSelected {
                selectingMode = (isSelected ? .deselecting : .selecting)
                setSelection(!isSelected, indexPath: indexPath)
            } else {
                selectingMode = .selecting
            }
        case .changed:
            handleChangeOf(gestureRecognizer: gestureRecognizer)
        default:
            isAutoStartScroll = false
            beginIndexPath = nil
            selectingRange = nil
            selectingIndexPaths.removeAll()
        }
    }
    @objc private func startScroll() {
        guard autoScrollOperationQueue.operationCount == 0, isAutoStartScroll else { return }
        let opration = BlockOperation { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                guard let self = self, let direction = self.autoScrollDirection else { return }
                var targetY = self.contentOffset.y + (direction == .up ? -self.autoScrollSpeed : self.autoScrollSpeed)
                targetY = max(0, targetY)
                targetY = min(self.contentSize.height-self.bounds.height, targetY)
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: targetY)
            })
            self.perform(#selector(self.startScroll), with: nil, afterDelay: 0.1)
        }
        autoScrollOperationQueue.addOperation(opration)
    }

    private func handleChangeOf(gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        if point.y - self.contentOffset.y >= self.bounds.size.height - 50, autoScrollOperationQueue.operationCount == 0 {
            autoScrollDirection = .down
            isAutoStartScroll = true
            startScroll()
        } else if point.y - self.contentOffset.y <= 50, autoScrollOperationQueue.operationCount == 0 {
            autoScrollDirection = .up
            isAutoStartScroll = true
            startScroll()
        } else {
            isAutoStartScroll = false
        }
        guard var beginIndexPath = self.beginIndexPath,
            var endIndexPath = indexPathForItem(at: point) else { return }
        if endIndexPath < beginIndexPath {
            swap(&beginIndexPath, &endIndexPath)
        }
        let range = ClosedRange(uncheckedBounds: (beginIndexPath, endIndexPath))
        guard range != selectingRange else { return }
        var positiveIndexPaths: [IndexPath]!
        var negativeIndexPaths: [IndexPath]!
        if let selectingRange = selectingRange {
            if range.lowerBound == selectingRange.lowerBound {
                if range.upperBound < selectingRange.upperBound {
                    negativeIndexPaths = indexPaths(in:
                        ClosedRange(uncheckedBounds: (range.upperBound, selectingRange.upperBound)))
                    negativeIndexPaths.removeFirst()
                } else {
                    positiveIndexPaths = indexPaths(in: ClosedRange(uncheckedBounds: (selectingRange.upperBound, range.upperBound)))
                }
            } else if range.upperBound == selectingRange.upperBound {
                if range.lowerBound > selectingRange.lowerBound {
                    negativeIndexPaths = indexPaths(in:
                        ClosedRange(uncheckedBounds: (selectingRange.lowerBound, range.lowerBound)))
                    negativeIndexPaths.removeLast()
                } else {
                    positiveIndexPaths = indexPaths(in: ClosedRange(uncheckedBounds: (range.lowerBound, selectingRange.lowerBound)))
                }
            } else {
                negativeIndexPaths = indexPaths(in: selectingRange)
                positiveIndexPaths = indexPaths(in: range)
            }
        } else {
            positiveIndexPaths = indexPaths(in: range)
        }
        for indexPath in negativeIndexPaths ?? [] {
            doSelection(at: indexPath, isPositive: false)
        }
        for indexPath in positiveIndexPaths ?? [] {
            doSelection(at: indexPath, isPositive: true)
        }
        selectingRange = range
    }

    private func doSelection(at indexPath: IndexPath, isPositive: Bool) {
        // Ignore the begin index path, it's already taken care of when the gesture recognizer began.
        guard indexPath != beginIndexPath else { return }
        guard let isSelected = cellForItem(at: indexPath)?.isSelected else { return }
        let expectedSelection: Bool = {
            switch selectingMode {
            case .selecting: return isPositive
            case .deselecting: return !isPositive
            }
        } ()
        if isSelected != expectedSelection {
            if isPositive {
                selectingIndexPaths.insert(indexPath)
            }
            if selectingIndexPaths.contains(indexPath) {
                setSelection(expectedSelection, indexPath: indexPath)
                if !isPositive {
                    selectingIndexPaths.remove(indexPath)
                }
            }
        }
    }

    private func setSelection(_ selected: Bool, indexPath: IndexPath) {
        switch selected {
        case true:
            delegate?.collectionView?(self, didSelectItemAt: indexPath)
            selectItem(at: indexPath, animated: false, scrollPosition: [])
        case false:
            delegate?.collectionView?(self, didDeselectItemAt: indexPath)
            deselectItem(at: indexPath, animated: false)
        }
    }

    private func indexPaths(in range: ClosedRange<IndexPath>) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let beginSection = range.lowerBound.section
        let endSection = range.upperBound.section
        guard beginSection != endSection else {
            for row in range.lowerBound.row...range.upperBound.row {
                indexPaths.append(IndexPath(row: row, section: beginSection))
            }
            return indexPaths
        }
        for row in range.lowerBound.row..<dataSource!.collectionView(self, numberOfItemsInSection: beginSection) {
            indexPaths.append(IndexPath(row: row, section: beginSection))
        }
        for row in 0...range.upperBound.row {
            indexPaths.append(IndexPath(row: row, section: endSection))
        }

        for section in (range.lowerBound.section + 1)..<range.upperBound.section {
            for row in 0..<dataSource!.collectionView(self, numberOfItemsInSection: section) {
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        return indexPaths
    }
}
