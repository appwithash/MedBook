//
//  UserDefaultManager.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import Combine

class UserDefaultManager {
    
    private var userDefaults: UserDefaults
    
    static let shared = UserDefaultManager()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var countryName : String {
        get {
            return userDefaults.string(forKey: UserDefaultsKey.countryName.rawValue) ?? TitleStrings.select_country.localized
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKey.countryName.rawValue)
        }
    }
    
    var isLoggedIn : Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsKey.isLoggedIn.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKey.isLoggedIn.rawValue)
        }
    }
    
    var currentEmail : String?{
        get {
            return userDefaults.string(forKey: UserDefaultsKey.currentUser.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKey.currentUser.rawValue)
        }
    }
}


@propertyWrapper
final class ObservableUserDefault<T>: NSObject {
    private let key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T, Never>

    var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key) as! T
        }
        set {
            userDefaults.setValue(newValue, forKey: key)
        }
    }
    
    var projectedValue: AnyPublisher<T, Never> {
        return subject.eraseToAnyPublisher()
    }

    init(wrappedValue defaultValue: T, _ key: UserDefaultsKey, userDefaults: UserDefaults = .standard) {
        self.key = key.rawValue
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(defaultValue)
        super.init()
        userDefaults.register(defaults: [key.rawValue: defaultValue])
        userDefaults.addObserver(self, forKeyPath: key.rawValue, options: .new, context: &observerContext)
        subject.value = wrappedValue
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            subject.value = wrappedValue
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    deinit {
        userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}

class UserDefault<T> {
    let key: UserDefaultsKey
    let defaultValue: T
    let userDefaults: UserDefaults

    init(key: UserDefaultsKey, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key.rawValue)
        }
    }
}
