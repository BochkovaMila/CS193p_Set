//
//  Game.swift
//  Set
//
//  Created by Mila B on 12.11.2022.
//

import Foundation

class Game {
    
    private(set) var upperCardLimit = 24
    private(set) var standarCardCount = 12
    private(set) var cards = [Card]()
    private(set) var cardsOnScreen: [Card]
    private(set) var score = 0
    
    var gameRange: Int {
        didSet {
            if gameRange > upperCardLimit { gameRange = upperCardLimit }
            cardsOnScreen += cards.getFirst(amountOf: gameRange - cardsOnScreen.count)
        }
    }
    
    var didSelectThreeCards: Bool {
        return selectedCards.count == 3
    }
        
    private var selectedCards: [Card] {
        get {
            return cardsOnScreen.filter() { $0.isSelected }
        }
    }
    
    var matchedCardsToRemove: [Card] {
        get {
            return cardsOnScreen.filter() { $0.isMatched ?? false && !$0.isSelected }
        }
    }
    
    init() {
        cards = []
        gameRange = standarCardCount
        score = 0
        for color in Card.Color.allCases {
            for shape in Card.Shape.allCases {
                for number in Card.Number.allCases {
                    for shading in Card.Shading.allCases {
                        let card = Card(shape: shape, color: color, shading: shading, number: number)
                        cards += [card]
                    }
                }
            }
        }
        cards.shuffle()
        cardsOnScreen = cards.getFirst(amountOf: gameRange)
    }
    
    func replaceMatchingCards() {
        for index in cardsOnScreen.indices {
            if cardsOnScreen[index].isMatched ?? false {
                if !cards.isEmpty {
                    cardsOnScreen[index] = cards.removeFirst()
                } else {
                    cardsOnScreen[index].isSelected = false
                    cardsOnScreen[index].isMatched = true
                }
            } else {
                cardsOnScreen[index].isSelected = false
                cardsOnScreen[index].isMatched = nil
            }
        }
    }
    
    private func checkIfMatch() -> Bool {
        var numbers = Set<Card.Number>()
        var shapes = Set<Card.Shape>()
        var colors = Set<Card.Color>()
        var shadings = Set<Card.Shading>()
        
        for card in selectedCards {
            numbers.insert(card.number); shapes.insert(card.shape); colors.insert(card.color); shadings.insert(card.shading)
        }
        let isSet = (numbers.count == 1 || numbers.count == 3) && (shapes.count == 1 || shapes.count == 3) && (colors.count == 1 || colors.count == 3) && (shadings.count == 1 || shadings.count == 3)
        return isSet
    }
    
    func chooseCard(at index: Int) {
        if didSelectThreeCards { replaceMatchingCards() }
        
        if !(cardsOnScreen[index].isSelected) {
            cardsOnScreen[index].isSelected = true
            
            if didSelectThreeCards {
                if checkIfMatch() {
                    score += 2
                    cardsOnScreen.indices.forEach() { if cardsOnScreen[$0].isSelected { cardsOnScreen[$0].isMatched = true } }
                } else {
                    score -= 1
                    cardsOnScreen.indices.forEach() { if cardsOnScreen[$0].isSelected { cardsOnScreen[$0].isMatched = false } }
                }
            }
        } else {
            // deselect
            cardsOnScreen[index].isSelected = false
            score -= 1
        }
    }
}


extension Array where Element == Card {
    /// Returns given amount of elements from beginning of the array, and removes them.
    mutating func getFirst(amountOf: Int) -> [Element] {
        var returnCards = [Element]()
        if 0 < amountOf && amountOf <= self.count {
            for _ in 0..<amountOf {
                returnCards.append(self.removeFirst())
            }
            return returnCards
        }
        return []
    }
}
