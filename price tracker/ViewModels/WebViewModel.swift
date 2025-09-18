//
//  WebViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 18/09/2025.
//

class WebViewModel {
    
    var htmlString: String = ""
    var baseURL: URL?
    
    var navigationTitle = "Acknowledgements"
    
  
    init() {
        guard let path = Bundle.main.path(forResource: "acknowledgements", ofType: "html"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }
        htmlString = content
        baseURL = Bundle.main.bundleURL
    }
    
}
