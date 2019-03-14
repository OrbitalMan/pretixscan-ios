//
//  DefaultsConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// ConfigStore implementation that stores configuration in memory.
public class InMemoryConfigStore: ConfigStore {
    // MARK: - Welcome Screen
    public var welcomeScreenIsConfirmed: Bool = false { didSet { debugPrint() } }

    // MARK: - API Configuration
    public var isAPIConfigured: Bool { return apiBaseURL != nil && apiToken != nil }
    public var apiBaseURL: URL? { didSet { debugPrint() } }
    public var apiToken: String? { didSet { debugPrint() } }

    // MARK: - Device
    public var deviceName: String? { didSet { debugPrint() } }
    public var organizerName: String? { didSet { debugPrint() } }
    public var deviceID: Int? { didSet { debugPrint() } }
    public var deviceUniqueSerial: String? { didSet { debugPrint() } }

    // MARK: - Debugging
    public var debug: Bool = false {
        didSet {
            if debug {
                print("InMemoryConfigStore enabled printing out all state changes to the console.")
            } else {
                print("InMemoryConfigStore disabled printing out all state changes to the console.")
            }
            debugPrint()
        }
    }

    private func debugPrint() {
        guard debug else { return }
        print(self)
    }
}

extension InMemoryConfigStore: CustomStringConvertible {
    public var description: String {
        var desc = ""
        desc.append("----------------------------------------\n")
        desc.append("InMemoryConfigStore\n")
        desc.append("----------------------------------------\n")
        desc.append("welcomeScreenIsConfirmed: \(welcomeScreenIsConfirmed)\n")
        desc.append("isAPIConfigured:          \(isAPIConfigured)\n")
        desc.append("apiBaseURL:               \(String(describing: apiBaseURL))\n")
        desc.append("apiToken:                 \(apiToken ?? "nil")\n")
        desc.append("deviceName:               \(deviceName ?? "nil")\n")
        desc.append("organizerName:            \(organizerName ?? "nil")\n")
        desc.append("deviceID:                 \(String(describing: deviceID))\n")
        desc.append("deviceUniqueSerial:       \(deviceUniqueSerial ?? "nil")\n")
        desc.append("----------------------------------------\n")

        return desc
    }
}
