//
//  ViewController.swift
//  Set
//
//  Created by Mila B on 12.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
        
    @IBOutlet weak var deal3MoreCardsButton: UIButton!
    
    private lazy var game = Game()
    private let defaultBorderWidth: CGFloat = 0.5
    private let defaultBorderColor = UIColor.darkGray.cgColor
    private let selectedBorderWidth: CGFloat = 3
    private var selectedBorderColor = UIColor.blue.cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDeckView()
        updateViewFromModel()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            initializeDeckView()
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        game = Game()
        initializeDeckView()
        updateViewFromModel()
    }    
    
    @IBAction func deal3MoreCardsPressed(_ sender: UIButton) {
        if game.didSelectThreeCards {
            game.replaceMatchingCards()
            initializeDeckView()
        } else {
            game.gameRange += 3
        }
        updateViewFromModel()
    }
    
    private func initializeDeckView() {
        cardButtons.forEach() { $0.setAttributedTitle(nil, for: .normal); $0.layer.borderWidth = 0; $0.alpha = 0.2; $0.layer.cornerRadius = 6; $0.isEnabled = false }
    }
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        deal3MoreCardsButton.isEnabled = game.didSelectThreeCards || (game.gameRange < 24 && game.cards.count > 2)
        
        for index in 0..<game.gameRange {
            let button = cardButtons[index]
            let card = game.cardsOnScreen[index]
            
            if game.matchedCardsToRemove.contains(card) {
                continue
            }
            
            button.isEnabled = true
            button.alpha = 1
            button.setAttributedTitle(attributedString(for: card), for: .normal)
            
            if let match = card.isMatched {
                selectedBorderColor = match ? #colorLiteral(red: 0, green: 1, blue: 0.08472456465, alpha: 1).cgColor : #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
            } else {
                selectedBorderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor
            }
            
            if card.isSelected {
                button.layer.borderWidth = selectedBorderWidth
                button.layer.borderColor = selectedBorderColor
            } else {
                button.layer.borderWidth = defaultBorderWidth
                button.layer.borderColor = defaultBorderColor
            }
        }
    }
    
    private func attributedString(for card: Card) -> NSAttributedString {
        var attributes = [NSAttributedString.Key : Any]()
        var cardColor = UIColor()
        var cardString = ""
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(25)
        
        attributes = [NSAttributedString.Key.font: font]
        
        switch card.shape {
        case .round: cardString = "●"
        case .square: cardString = "■"
        case .triangle: cardString = "▲"
        }
        
        switch card.color {
        case .red: cardColor = .red
        case .blue: cardColor = .blue
        case .green: cardColor = .green
        }
        
        switch card.shading {
        case .outlined:
            attributes[.strokeWidth] = 12
            fallthrough
        case .filled:
            attributes[.foregroundColor] = cardColor
        case .striped:
            attributes[.foregroundColor] = cardColor.withAlphaComponent(0.3)
        }
        
        // Number of characters
        cardString = String(repeating: cardString, count: card.number.rawValue)
        return NSAttributedString(string: cardString, attributes: attributes)
    }

}

