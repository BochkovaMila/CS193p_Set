//
//  ViewController.swift
//  Set
//
//  Created by Mila B on 12.11.2022.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    private lazy var game = Game()
    private let defaultBorderWidth: CGFloat = 0.5
    private let defaultBorderColor = UIColor.darkGray.cgColor
    private let selectedBorderWidth: CGFloat = 3
    private var selectedBorderColor = UIColor.blue.cgColor
    
    @IBOutlet weak var firstPlayerButton: UIButton!
    @IBOutlet weak var firstPlayerScore: UILabel!
    @IBOutlet weak var secondPlayerButton: UIButton!
    @IBOutlet weak var secondPlayerScore: UILabel!
    
    @IBOutlet weak var dealCardsButton: UIButton!
    
    @IBOutlet weak var boardView: BoardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealCards))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    
    @objc func dealCards() {
        if !game.cardsOnScreen.isEmpty {
            game.dealThreeCards()
            updateViewFromModel()
        }
    }
    
    @objc func shuffle(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffleCards()
            updateViewFromModel()
        default:
            break
        }
    }
    
    @objc func chooseCard(_ sender: UITapGestureRecognizer) {
        if let cardView = sender.view as? CardView, let cardIndex = boardView.cardViews.firstIndex(of: cardView) {
            game.chooseCard(at: cardIndex)
            updateViewFromModel()
        } else {
            print("Error when tapping on card")
        }
    }
    
    private lazy var animator : UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: boardView)
        animator.delegate = self
        return animator
    }()
    
    private lazy var behavior: FlyawayBehavior = {
        let behavior = FlyawayBehavior(animator)
        return behavior
    }()
    
    private var centerOfTheDeck: CGPoint {
        let center = dealCardsButton.center
        let centerOfBoardView = view.convert(center, to: boardView)
        boardView.centerOfTheDeck = centerOfBoardView
        return centerOfBoardView
    }
    
    private var discardPileCenter: CGPoint {
        return centerOfTheDeck
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        behavior.snapPoint = discardPileCenter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        secondPlayerScore.transform = CGAffineTransformMakeRotation(CGFloat.pi)
        secondPlayerButton.transform = CGAffineTransformMakeRotation(CGFloat.pi)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewFromModel), name: NSNotification.Name(rawValue: "didFinishTurn"), object: nil)
    }
    
    @IBAction func firstPlayerFoundSet(_ sender: UIButton) {
        game.setTurn(for: .first)
        updateViewFromModel()
    }
    
    @IBAction func secondPlayerFoundSet(_ sender: UIButton) {
        game.setTurn(for: .second)
        updateViewFromModel()
    }
    
    @IBAction func dealCardsButtonPressed(_ sender: UIButton) {
        dealCards()
    }
    
    @objc func updateViewFromModel() {
        for index in game.cardsOnScreen.indices {
            let card = game.cardsOnScreen[index]

            if index >= boardView.cardViews.count {
                // create cards
                let cardView = createCardView()
                updateCardView(cardView, for: card)
                boardView.cardViews.append(cardView)
                boardView.addSubview(cardView)
            } else {
                // replace cards
                let cardView = boardView.cardViews[index]
                updateCardView(cardView, for: card)
                configureCardViewState(cardView, card)
            }
            
            // remove from boardView
            for _ in game.cardsOnScreen.count..<boardView.cardViews.count {
                boardView.cardViews.removeLast().removeFromSuperview()
            }
            
            // Deal Cards Animation
            var numberOfCardsDealt = 0
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                for cardView in self.boardView.cardViews {
                    if (cardView.alpha == 0) {
                        cardView.animateDeal(from: self.centerOfTheDeck, delay: TimeInterval(numberOfCardsDealt) * 0.25)
                        numberOfCardsDealt += 1
                    }
                }
            }
            
            // replace or remove matching cards
            if let matched = game.didSelectThreeCardsThatMatch, matched {
                if game.cards.isEmpty {
                    game.dealThreeCards()
                    for index in game.cardsOnScreen.indices {
                        let card = game.cardsOnScreen[index]
                        let cardView = boardView.cardViews[index]
                        cardView.alpha = 1
                        updateCardView(cardView, for: card)
                        configureCardViewState(cardView, card)
                    }
                    for _ in game.cardsOnScreen.count..<boardView.cardViews.count {
                        boardView.cardViews.removeLast().removeFromSuperview()
                    }
                } else {
                    dealCards()
                }
            }
            
            // update labels
            firstPlayerScore.text =  "\(game.firstPlayerScore):\(game.secondPlayerScore)"
            secondPlayerScore.text = "\(game.secondPlayerScore):\(game.firstPlayerScore)"
            
            if let _ = game.currentPlayer {
                firstPlayerButton.isEnabled = false
                secondPlayerButton.isEnabled = false
            } else {
                firstPlayerButton.isEnabled = true
                secondPlayerButton.isEnabled = true
            }
            
            if game.cards.isEmpty {
                dealCardsButton.isEnabled = false
            } else {
                dealCardsButton.isEnabled = true
            }
        }
    }
    
    private var tmpCards = [CardView]()
    private func configureCardViewState(_ cardView: CardView, _ card: Card) {
        if game.selectedCards.contains(card) {
            cardView.isSelected = true
            cardView.isMatched = game.didSelectThreeCardsThatMatch
            if let matched = game.didSelectThreeCardsThatMatch, matched {
                let tmpCard = cardView.copyCard()
                tmpCards.append(tmpCard)
                boardView.addSubview(tmpCard)
                behavior.addItem(tmpCard)
                cardView.alpha = 0
            }
        } else {
            cardView.isSelected = false
            cardView.isMatched = nil
        }
        cardView.configureState()
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        tmpCards.forEach { (tmpCard) in
            UIView.transition(with: tmpCard, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
                tmpCard.isFaceup = false
            }, completion: { (isComplete) in
                self.behavior.remove(tmpCard)
                tmpCard.removeFromSuperview()
            })
        }
    }
    
    private func createCardView() -> CardView {
        let cardView = CardView(behavior)
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCard))
        cardView.addGestureRecognizer(tap)
        return cardView
    }
    
    private func updateCardView(_ cardView: CardView, for card: Card) {
        let count = card.number.rawValue
        let color: UIColor
        let shape: Card.Shape
        let shading: Card.Shading
        switch card.color {
        case .green:
            color = #colorLiteral(red: 0.07843137255, green: 0.6078431373, blue: 0.2666666667, alpha: 1)
        case .red:
            color = #colorLiteral(red: 0.8196078431, green: 0.1411764706, blue: 0.1960784314, alpha: 1)
        case .blue:
            color = #colorLiteral(red: 0.1764705882, green: 0.1137254902, blue: 0.3960784314, alpha: 1)
        }
        switch card.shape {
        case .diamond:
            shape = .diamond
        case .oval:
            shape = .oval
        case .squiggle:
            shape = .squiggle
        }
        switch card.shading {
        case .outlined:
            shading = .outlined
        case .solid:
            shading = .solid
        case .striped:
            shading = .striped
        }
        
        if cardView.count != count {
            cardView.count = count
        }
        if cardView.color != color {
            cardView.color = color
        }
        if cardView.shape != shape {
            cardView.shape = shape
        }
        if cardView.shading != shading {
            cardView.shading = shading
        }
        
        if let _ = game.currentPlayer {
            cardView.isUserInteractionEnabled = true
        } else {
            cardView.isUserInteractionEnabled = false
        }
    }
    
}

