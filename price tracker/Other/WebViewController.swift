//
//  WebViewController.swift
//  price tracker
//
//  Created by Kris Skierniewski on 18/09/2025.
//
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    private var viewModel: WebViewModel
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        navigationItem.title = viewModel.navigationTitle
        if let baseURL = viewModel.baseURL {
            webView.loadHTMLString(viewModel.htmlString, baseURL: baseURL)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Allow the initial load
        if navigationAction.navigationType == .other {
            decisionHandler(.allow)
            return
        }
        
        // For link clicks, open in Safari
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}
