//
//  Debouncer.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//

import Foundation

class Debouncer {
    private let delay: TimeInterval
    private var timer: Timer?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func run(action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

final class DebouncerMap<ID: Hashable> {
    private let delay: TimeInterval
    private var debouncers: [ID: Debouncer] = [:]

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func run(id: ID, action: @escaping () -> Void) {
        if debouncers[id] == nil {
            debouncers[id] = Debouncer(delay: delay)
        }

        debouncers[id]?.run { [weak self] in
            action()
            self?.debouncers[id] = nil  // 사용 후 제거
        }
    }

    func cancel(id: ID) {
        debouncers[id]?.cancel()
        debouncers[id] = nil
    }

    func cancelAll() {
        debouncers.values.forEach { $0.cancel() }
        debouncers.removeAll()
    }
}
