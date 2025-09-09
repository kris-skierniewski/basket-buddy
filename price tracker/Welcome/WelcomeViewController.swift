//
//  WelcomeViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 07/10/2024.
//

import UIKit
import SafariServices

class WelcomeViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var continueButtonShadowView: UIView!
    
    @IBOutlet private weak var termsAndConditionsLabel: TTTAttributedLabel!
    
    private var autoScrollTimer: Timer?
    
    private var viewModel: WelcomeViewModel
    
    private var currentIndex: Int {
        if scrollView.bounds.width == 0 {
            return 0
        }
        return Int(scrollView.bounds.minX/scrollView.bounds.width)
    }
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupTermsLabel()
        
        continueButtonShadowView.layer.shadowColor = UIColor.black.cgColor
        continueButtonShadowView.layer.shadowOpacity = 0.4
        continueButtonShadowView.layer.shadowRadius = 2
        continueButtonShadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopTimer()

        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func willEnterForeground() {
        startTimer()
    }
    @objc private func didEnterBackground() {
        stopTimer()
    }
    
    private func setupScrollView() {
        
        let carouselItemViews = viewModel.carouselItems.map({ [weak self] in
            let view = CarouselItemView().viewFromXib() as! CarouselItemView
            view.updateForModel($0, parentScrollView: self?.scrollView)
            return view
        })
        scrollView.addExpandingSubview(UIView.view(containingHorizontallyStackedViews: carouselItemViews))
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.carouselItems.count
    }
    
    private func setupTermsLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let defaultAttributes: [NSAttributedString.Key: Any] =
        [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.label
            //.paragraphStyle: paragraphStyle
        ]
        
        let textString = "By using the app, you agree to our Terms and Conditions and acknowledge that our Privacy Policy applies to you."
        let attributedString = NSMutableAttributedString(string: textString, attributes: defaultAttributes)
        
        let termsRange = (textString as NSString).range(of: "Terms and Conditions")
        let privacyPolicyRange = (textString as NSString).range(of: "Privacy Policy")
        
        
        
        let linkAttributes: [NSAttributedString.Key: Any] =
        [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor(named: "AccentColor")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(named: "AccentColor")!
            //.paragraphStyle: paragraphStyle
        ]
        
        let selectedLinkAttributes: [NSAttributedString.Key: Any] =
        [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor(named: "AccentColor")!.withAlphaComponent(0.5),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(named: "AccentColor")!.withAlphaComponent(0.5)
            //.paragraphStyle: paragraphStyle
        ]
        
        //attributedString.addAttribute(.link, value: , range: termsRange)
        
        //attributedString.addAttribute(.link, value: , range: privacyPolicyRange)
        
        termsAndConditionsLabel.attributedText = attributedString
        termsAndConditionsLabel.linkAttributes = linkAttributes
        termsAndConditionsLabel.activeLinkAttributes = selectedLinkAttributes
        termsAndConditionsLabel.inactiveLinkAttributes = selectedLinkAttributes
        
        
        let termsUrl = URL(string:"https://medium.com/@k.skierniewski/terms-and-conditions-for-basket-buddy-ios-app-d6f2e9e1ab84")!
        
        termsAndConditionsLabel.addLink(to: termsUrl, with: termsRange)
        
        let privacyUrl = URL(string: "https://medium.com/@k.skierniewski/privacy-policy-for-basket-buddy-ios-app-0441a856555b")!
        termsAndConditionsLabel.addLink(to: privacyUrl, with: privacyPolicyRange)
        
        termsAndConditionsLabel.delegate = self
    }
    
    private func setPage(_ pageIndex: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(pageIndex), y: 0), animated: true)
        pageControl.currentPage = pageIndex
    }
    
    private func startTimer() {
        stopTimer()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            if let index = self?.currentIndex {
                if let pages = self?.pageControl.numberOfPages, index >= pages-1 { self?.setPage(0)
                } else {
                    self?.setPage(index+1)
                }
            }
        }
    }
    
    private func stopTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func restartTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in 
            self?.startTimer()
        }
    }
    
    @IBAction private func pageControlChanged() {
        stopTimer()
        setPage(pageControl.currentPage)
        restartTimer()
    }
    
    @IBAction private func continueTapped() {
        viewModel.continueTapped()
    }
    
}

extension WelcomeViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        viewModel.linkSelected(url)
    }
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentIndex != pageControl.currentPage { setPage(currentIndex) }
        restartTimer()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { restartTimer() }
    }
}
