//
//  KButton.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import UIKit

class KButton: UIButton {
    
    private var originalBackgroundColor: UIColor?
    
    override var isEnabled: Bool {
        didSet {
            updateAppearanceForState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        originalBackgroundColor = backgroundColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(addHitState), for: .touchDown)
        addTarget(self, action: #selector(addHitState), for: .touchDragEnter)
        addTarget(self, action: #selector(removeHitState), for: .touchUpInside)
        addTarget(self, action: #selector(removeHitState), for: .touchDragExit)
        addTarget(self, action: #selector(removeHitState), for: .touchCancel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addTarget(self, action: #selector(addHitState), for: .touchDown)
        addTarget(self, action: #selector(addHitState), for: .touchDragEnter)
        addTarget(self, action: #selector(removeHitState), for: .touchUpInside)
        addTarget(self, action: #selector(removeHitState), for: .touchDragExit)
        addTarget(self, action: #selector(removeHitState), for: .touchCancel)
    }
    
    @objc func addHitState() {
        let newTransform = transform.scaledBy(x: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.transform = newTransform
        }
    }
    
    @objc func removeHitState() {
        let newTransform = CGAffineTransform(a: transform.a < 0 ? -1 : 1,
                                             b: transform.b,
                                             c: transform.c,
                                             d: 1,
                                             tx: transform.tx,
                                             ty: transform.ty)
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.transform = newTransform
        }
    }
    
    private func updateAppearanceForState() {
        if let originalBackgroundColor = originalBackgroundColor {
            if isEnabled  {
                backgroundColor = originalBackgroundColor
            } else {
                backgroundColor = .systemGray4
            }
        }
    }
    
}
