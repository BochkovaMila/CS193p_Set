//
//  FlyawayBehavior.swift
//  Set
//
//  Created by Mila B on 05.12.2022.
//

import UIKit

class FlyawayBehavior: UIDynamicBehavior {

    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1.3
        behavior.resistance = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2*CGFloat.pi).arc4random
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            push.magnitude = referenceBounds.width * 4/375
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            push.angle = (CGFloat.pi/2).arc4random
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -1 * push.angle
            case let (x, y) where x > center.x:
                push.angle = y < center.y ? CGFloat.pi-push.angle: CGFloat.pi+push.angle
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
        }
        
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    var snapPoint = CGPoint()
    private func snap(_ item: UIDynamicItem) {
        let snap = UISnapBehavior(item: item, snapTo: snapPoint)
        addChildBehavior(snap)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.collisionBehavior.removeItem(item)
            self.snap(item)
        }
        push(item)
    }
    
    func remove(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(_ animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * CGFloat(drand48())
    }
}
