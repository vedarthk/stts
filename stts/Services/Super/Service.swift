//
//  Service.swift
//  stts
//
//  Created by inket on 28/7/16.
//  Copyright © 2016 inket. All rights reserved.
//

import Cocoa

enum ServiceStatus {
    case undetermined
    case good
    case minor
    case major
}

class Service {
    var name: String { return "Undefined" }
    var status: ServiceStatus = .undetermined {
        didSet {
            if oldValue == .undetermined || status == .undetermined || oldValue == status {
                self.shouldNotify = false
            } else {
                self.shouldNotify = true
            }
        }
    }
    var message: String = "Loading…"
    var url: URL { return URL(string: "")! }
    var shouldNotify = false

    static func all() -> [Service] {
        let allServices = [
            GitHub.self,
            TravisCI.self,
            Heroku.self,
            CircleCI.self,
            NewRelic.self,
            AmazonWebServices.self,
            NPM.self,
            RubyGems.self,
            Pusher.self,
            Reddit.self,
            BitBucket.self,
            CloudFlare.self,
            Sentry.self,
            EngineYard.self,
            DigitalOcean.self
        ] as [Service.Type]

        return allServices.map { $0.init() }
    }

    required init() {}

    func updateStatus(callback: @escaping (Service) -> ()) {}

    func _fail(_ error: Error?) {
        self.status = .undetermined
        self.message = error?.localizedDescription ?? "Unexpected error"
    }

    func _fail(_ message: String) {
        self.status = .undetermined
        self.message = message
    }

    func notifyIfNecessary() {
        guard shouldNotify else { return }

        self.shouldNotify = false

        let notification = NSUserNotification()
        let possessiveS = name.hasSuffix("s") ? "'" : "'s"
        notification.title = "\(name)\(possessiveS) status has changed"
        notification.informativeText = message

        NSUserNotificationCenter.default.deliver(notification)
    }
}

extension Service: Equatable {
    public static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Service: Comparable {
    static func < (lhs: Service, rhs: Service) -> Bool {
        let sameStatus = lhs.status == rhs.status
        let differentStatus = lhs.status != .good && rhs.status == .good
        return ((lhs.name < rhs.name) && sameStatus) || differentStatus
    }
}
