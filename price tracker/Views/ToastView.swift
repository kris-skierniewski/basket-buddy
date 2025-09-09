//
//  ToastView.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

class ToastView: UIView {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    
    let hideDelay = 4.0
    let animationDuration = 0.5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.textColor = .label
        label.numberOfLines = 0
        blurView.backgroundColor = .accent.withAlphaComponent(0.2)
//        backgroundColor = .white
//        borderColor = .system
//        borderWidth = 3
        
        
        alpha = 0
    }
    
    func show(withMessage message: String) {
        label.text = message
        alpha = 1
        UIView.animate(withDuration: animationDuration, delay: hideDelay) { [weak self] in
            self?.alpha = 0
        }
    }
}
