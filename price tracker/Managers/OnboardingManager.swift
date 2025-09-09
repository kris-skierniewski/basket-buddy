//
//  OnboardingManager.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

private enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let onboardingVersion = "onboardingVersion"
}

protocol OnboardingManagerProtocol {
    var hasCompletedOnboarding: Bool { get }
    var needsOnboarding: Bool { get }
    func markOnboardingCompleted()
    func shouldShowOnboarding(for version: Int) -> Bool
}

class OnboardingManager: OnboardingManagerProtocol {
    var hasCompletedOnboarding: Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
    
    var needsOnboarding: Bool {
        return !hasCompletedOnboarding || shouldShowOnboarding(for: currentOnboardingVersion)
    }
    
    static let shared = OnboardingManager()
    
    private let userDefaults: UserDefaults
    private let currentOnboardingVersion: Int
    
    private init(userDefaults: UserDefaults = .standard, currentOnboardingVersion: Int = 1) {
        self.userDefaults = userDefaults
        self.currentOnboardingVersion = currentOnboardingVersion
    }
    
    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        userDefaults.set(currentOnboardingVersion, forKey: UserDefaultsKeys.onboardingVersion)
    }
    
    func shouldShowOnboarding(for version: Int) -> Bool {
        let savedVersion = userDefaults.integer(forKey: UserDefaultsKeys.onboardingVersion)
        return version > savedVersion
    }
}
