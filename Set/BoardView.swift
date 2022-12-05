//
//  BoardView.swift
//  Set
//
//  Created by Mila B on 01.12.2022.
//

import UIKit

class BoardView: UIView {

    var cardViews = [CardView]() 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSetCards()
    }
    
    var centerOfTheDeck = CGPoint.zero
    
    func resetCards() {
        cardViews.forEach { $0.alpha = 0 }
        layoutSetCards()
    }
    
    private func layoutSetCards() {
        var grid = Grid(layout: .aspectRatio(Constant.cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        for i in 0..<grid.cellCount {
            if let frame = grid[i] {
                let cellPadding = Constant.cellPaddingToBoundsWidth * frame.width
                let cardFrame = CGRect(x: frame.origin.x, y: frame.origin.y,
                                       width: frame.width - cellPadding,
                                       height: frame.height - cellPadding)
                let cardView = cardViews[i]
                // animation here later
            }
        }
    }
    
}

extension BoardView {
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let cellPaddingToBoundsWidth: CGFloat  = 1/20
    }
}
