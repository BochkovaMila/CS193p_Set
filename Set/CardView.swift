//
//  CardView.swift
//  Set
//
//  Created by Mila B on 26.11.2022.
//

import UIKit


class CardView: UIView {
    var count: Int = 1
    var color: UIColor = #colorLiteral(red: 0.07843137255, green: 0.6078431373, blue: 0.2666666667, alpha: 1)
    var shape: Card.Shape = Card.Shape.diamond
    var shading: Card.Shading = Card.Shading.solid
    
    var isSelected = false
    var isMatched: Bool?
    var isFaceup = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    private weak var behavior: FlyawayBehavior?
    
    convenience init(_ behavior: FlyawayBehavior) {
        self.init(frame: CGRect.zero)
        self.behavior = behavior
        alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        isOpaque = false
    }
    
    func configureState() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = patternLineWidth*2
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        if isSelected {
            layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1).cgColor
            if let matched = isMatched {
                if matched {
                    layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1).cgColor
                } else {
                    layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
                }
            }
        } else {
            layer.borderWidth = 0
        }
    }
    
    func copyCard() -> CardView {
        let copy = CardView()
        copy.color = color
        copy.count = count
        copy.shape = shape
        copy.shading = shading
        copy.isFaceup = true
        copy.bounds = bounds
        copy.frame = frame
        copy.alpha = 1
        return copy
    }
    
    func animateDeal(from deckCenter: CGPoint, delay: TimeInterval) {
        let currentCenter = center
        center = deckCenter
        alpha = 1
        isFaceup = false
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: delay, options: [], animations: {
            self.center = currentCenter
        }, completion: { position in
            UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
                self.isFaceup = true
            })
        })
    }
    
    private func drawBackOfTheCard() {
        let backImage = UIImage(named: "stanford_logo")
        backImage?.draw(in: bounds)
    }
    
    private func drawRoundCorner(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        roundedRect.addClip()
        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
        roundedRect.fill()
    }
    
    private func drawDiamond() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX, y: bounds.midY - patternHeight/2))
        path.addLine(to: CGPoint(x: bounds.midX + patternWidth/2, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY + patternHeight/2))
        path.addLine(to: CGPoint(x: bounds.midX - patternWidth/2, y: bounds.midY))
        path.close()
        drawPattern(with: path)
    }
    
    private func drawOval() {
        let path = UIBezierPath(ovalIn: CGRect(origin: patternOrgin, size: CGSize(width: patternWidth, height: patternHeight)))
        drawPattern(with: path)
    }
    
    private func drawSquiggle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.midX - patternWidth/2, y: bounds.midY), radius: bounds.height/2, startAngle: CGFloat.pi/4, endAngle: 7*CGFloat.pi/4, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.midX - patternWidth/2, y: bounds.midY))
        path.addQuadCurve(to: CGPoint(x: bounds.midX + patternWidth/2, y: bounds.midY), controlPoint: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.midX + patternWidth/2, y: bounds.midY), radius: bounds.height/2, startAngle: 5*CGFloat.pi/4, endAngle: 3*CGFloat.pi/4, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.midX + patternWidth/2, y: bounds.midY))
        path.addQuadCurve(to: CGPoint(x: bounds.midX - patternWidth/2, y: bounds.midY), controlPoint: CGPoint(x: bounds.minX, y: bounds.minY))
        drawPattern(with: path)
    }
    
    private func drawPattern(with path: UIBezierPath) {
        path.lineWidth = patternLineWidth
        color.setStroke()
        color.setFill()
        
        if shading == .striped {
            UIGraphicsGetCurrentContext()?.saveGState()
            path.addClip()
            
            // Draw stripe
            for offset in stride(from: CGFloat(0), to: patternWidth, by: SizeRatio.stripInterval) {
                path.move(to: patternOrgin.offsetBy(dx: CGFloat(offset), dy: 0))
                path.addLine(to: patternOrgin.offsetBy(dx: CGFloat(offset), dy: patternHeight))
            }
        }
        
        if count == 1 {
            shading == .solid ? path.fill() : path.stroke()
        }
        
        if count == 2 {
            if shading == .striped {
                UIGraphicsGetCurrentContext()?.restoreGState()
                UIGraphicsGetCurrentContext()?.saveGState()
            }
            path.apply(CGAffineTransform(translationX: 0, y: patternHeight*0.5 + patternMargin))
            if shading == .striped {
                path.addClip()
            }
            shading == .solid ? path.fill() : path.stroke()
            
            if shading == .striped {
                UIGraphicsGetCurrentContext()?.restoreGState()
            }
            path.apply(CGAffineTransform(translationX: 0, y: -2 * (patternHeight*0.5 + patternMargin)))
            if shading == .striped {
                path.addClip()
            }
            shading == .solid ? path.fill() : path.stroke()
        }
        
        if count == 3 {
            if shading == .striped {
                UIGraphicsGetCurrentContext()?.restoreGState()
                UIGraphicsGetCurrentContext()?.saveGState()
            }
            path.apply(CGAffineTransform(translationX: 0, y: patternHeight + patternMargin))
            if shading == .striped {
                path.addClip()
            }
            shading == .solid ? path.fill() : path.stroke()
            
            if shading == .striped {
                UIGraphicsGetCurrentContext()?.restoreGState()
            }
            path.apply(CGAffineTransform(translationX: 0, y: -2 * (patternHeight + patternMargin)))
            if shading == .striped {
                path.addClip()
            }
            shading == .solid ? path.fill() : path.stroke()
        }
    }
    
    private func drawShape() {
        switch shape {
        case .diamond:
            drawDiamond()
        case .oval:
            drawOval()
        case .squiggle:
            drawSquiggle()
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawRoundCorner(rect)
        isFaceup ? drawShape() : drawBackOfTheCard()
    }

}

extension CardView {
    private struct SizeRatio {
        static let patternMarginToBoundsHeight: CGFloat = 0.07
        static let patternHeightToBoundsHeight: CGFloat = 0.22
        static let patternWidthToBoundsWidth: CGFloat = 0.8
        static let patternLineWidthToBoundsWidth: CGFloat = 0.01
        static let stripInterval: CGFloat = 5
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }

    private var patternHeight: CGFloat {
        return bounds.height * SizeRatio.patternHeightToBoundsHeight
    }

    private var patternWidth: CGFloat {
        return bounds.width * SizeRatio.patternWidthToBoundsWidth
    }

    private var patternMargin: CGFloat {
        return bounds.size.height * SizeRatio.patternMarginToBoundsHeight
    }

    private var patternOrgin: CGPoint {
        return CGPoint(x: bounds.midX - patternWidth/2, y: bounds.midY - patternHeight/2)
    }

    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }

    private var patternLineWidth: CGFloat {
        return bounds.width * SizeRatio.patternLineWidthToBoundsWidth
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
