//
//  Card.swift
//  Set
//
//  Created by Mila B on 12.11.2022.
//

import Foundation

struct Card: Equatable, CustomStringConvertible {
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
        
    var description: String {
        return ("\(number) \(color) \(shading) \(shape) ")
    }
    
    private var identifier: Int
    private static var identifierCount = 0
    
    var color: Color
    var shape: Shape
    var number: Number
    var shading: Shading
    var isMatched: Bool?
    var isSelected = false
    
    static func getUniqueIdentifier() -> Int {
        identifierCount += 1
        return identifierCount
    }
    
    init(shape: Shape, color: Color, shading: Shading, number: Number) {
        self.shape = shape
        self.color = color
        self.shading = shading
        self.number = number
        identifier = Card.getUniqueIdentifier()
    }
}

extension Card {
    enum Shape: CaseIterable {
        case triangle
        case round
        case square
    }
    
    enum Shading: CaseIterable {
        case filled
        case striped
        case outlined
    }
    
    enum Color: CaseIterable {
        case red
        case blue
        case green
    }
    
    enum Number: Int, CaseIterable {
        case one = 1
        case two
        case three
    }
}

