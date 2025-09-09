//
//  UIViewExtensions.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import UIKit

extension UIView {
    
    func addExpandingSubview(_ subview: UIView) {
        addSubview(subview)
        translatesAutoresizingMaskIntoConstraints = false
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        setNeedsLayout()
    }
    
    func viewFromXib<T>() -> T where T: UIView {
        // swiftlint:disable:next force_cast
        return Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as! T
    }
    
    static func view(containingHorizontallyStackedViews views: [UIView], padding: CGFloat = 0) -> UIView {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        for (index, view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            var constraints = [NSLayoutConstraint]()
            constraints.append(view.topAnchor.constraint(equalTo: container.topAnchor))
            //view.autoPinEdge(.top, to: .top, of: container)
//            view.autoPinEdge(.bottom, to: .bottom, of: container)
            constraints.append(view.bottomAnchor.constraint(equalTo: container.bottomAnchor))
            if index == 0 {
                constraints.append(view.leadingAnchor.constraint(equalTo: container.leadingAnchor))
//                view.autoPinEdge(toSuperviewEdge: .leading)
            } else {
                constraints.append(view.leadingAnchor.constraint(equalTo: views[index-1].trailingAnchor, constant: padding))
//                view.autoPinEdge(.leading, to: .trailing, of: views[index-1], withOffset: padding)
            }
            if index == views.count-1 {
                constraints.append(view.trailingAnchor.constraint(equalTo: container.trailingAnchor))
//                view.autoPinEdge(toSuperviewEdge: .trailing)
            }
            NSLayoutConstraint.activate(constraints)
        }
        container.setNeedsLayout()
        return container
    }
}
