//
//  Game.swift
//  Set
//
//  Created by Mila B on 12.11.2022.
//

import Foundation

class Game {
    
    private(set) var cards = [Card]()
    private(set) var cardsOnScreen = [Card]()
    private(set) var selectedCards = [Card]()
    private(set) var matchedCards = [Card]()
    private(set) var setOfCards = [Card]()
    private(set) var score = 0
    
    private(set) var firstPlayerScore = 0
    private(set) var secondPlayerScore = 0
    private(set) var currentPlayer: Player?
    
    var didSelectThreeCardsThatMatch: Bool? {
        get {
            if selectedCards.count != 3 {
                return nil
            }
            return checkIfMatch(with: selectedCards)
        }
    }
    
    init() {
        cards = []
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
        for _ in 0..<24 {
            cardsOnScreen.append(cards.remove(at: cards.count.arc4random))
        }
    }
    
    func setTurn(for player: Player) {
        currentPlayer = player
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.currentPlayer = nil
            if let matched = self.didSelectThreeCardsThatMatch, matched{
            } else {
                self.selectedCards.removeAll()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFinishTurn"), object: nil)
        }
    }
    
    func replaceMatchingCards() {
        if cards.isEmpty {
            for card in selectedCards {
                cardsOnScreen.remove(at: cardsOnScreen.firstIndex(of: card)!)
                matchedCards.append(card)
            }
        } else {
            cardsOnScreen = cardsOnScreen.map {
                if selectedCards.contains($0) {
                    matchedCards.append($0)
                    return cards.remove(at: cards.count.arc4random)
                } else {
                    return $0
                }
            }
        }
    }
    
    private func checkIfMatch(with cards: [Card]) -> Bool {
        var numbers = Set<Card.Number>()
        var shapes = Set<Card.Shape>()
        var colors = Set<Card.Color>()
        var shadings = Set<Card.Shading>()
        
        for card in cards {
            numbers.insert(card.number); shapes.insert(card.shape); colors.insert(card.color); shadings.insert(card.shading)
        }
        let isSet = (numbers.count == 1 || numbers.count == 3) && (shapes.count == 1 || shapes.count == 3) && (colors.count == 1 || colors.count == 3) && (shadings.count == 1 || shadings.count == 3)
        return isSet
    }
    
    private func decreaseScore(by number: Int) {
        if let player = currentPlayer {
            switch player {
            case .first:
                firstPlayerScore -= number
            case .second:
                secondPlayerScore -= number
            }
        }
    }
    
    func chooseCard(at index: Int) {
        if let matched = didSelectThreeCardsThatMatch, matched {
            replaceMatchingCards()
            selectedCards.removeAll()
        }
        
        if !(selectedCards.contains(cardsOnScreen[index])) {
            selectedCards.append(cardsOnScreen[index])
            
            if let match = didSelectThreeCardsThatMatch {
                if match {
                    if let player = currentPlayer {
                        switch player {
                        case .first:
                            firstPlayerScore += 5
                        case .second:
                            secondPlayerScore += 5
                        }
                    }
                } else {
                    decreaseScore(by: 2)
                }
            }
        } else {
            // deselect
            selectedCards.remove(at: selectedCards.firstIndex(of: cardsOnScreen[index])!)
            decreaseScore(by: 1)
        }
    }
    
    func shuffleCards() {
        for index in cardsOnScreen.indices {
            let randomIndex = Int(arc4random_uniform(UInt32(cardsOnScreen.count)))
            cardsOnScreen.swapAt(randomIndex, index)
        }
    }
    
    func cheat() {
        if setInCardsOnScreenDoesExist() {
            selectedCards.removeAll()
            setOfCards.forEach { selectedCards.append($0) }
        }
    }
    
    func dealThreeCards() {
        if let match = didSelectThreeCardsThatMatch, match {
            replaceMatchingCards()
            selectedCards.removeAll()
        } else {
            if setInCardsOnScreenDoesExist() {
                decreaseScore(by: 1)
            }
            for _ in 0..<3 { cardsOnScreen.append(cards.remove(at: cards.count.arc4random)) }
        }
    }
    
    private func setInCardsOnScreenDoesExist() -> Bool {
        for i in 0..<cardsOnScreen.count {
            for j in i+1..<cardsOnScreen.count {
                for k in j+1..<cardsOnScreen.count {
                    if checkIfMatch(with: [cardsOnScreen[i], cardsOnScreen[j], cardsOnScreen[k]]) {
                        setOfCards.removeAll()
                        setOfCards += [cardsOnScreen[i], cardsOnScreen[j], cardsOnScreen[k]]
                        return true
                    }
                }
            }
        }
        return false
    }
}

extension Game {
    enum Player {
        case first, second
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform((UInt32(self))))
        } else if self < 0 {
            return -Int(arc4random_uniform((UInt32(abs(self)))))
        } else {
            return 0
        }
    }
}
