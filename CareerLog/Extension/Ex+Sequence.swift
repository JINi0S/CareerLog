//
//  Ex+Sequence.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/28/25.
//

extension Sequence {
    func parallelMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            var results = Array<T?>(repeating: nil, count: self.underestimatedCount)
            for (index, element) in self.enumerated() {
                group.addTask {
                    let result = try await transform(element)
                    return (index, result)
                }
            }
            for try await (index, value) in group {
                results[index] = value
            }
            return results.compactMap { $0 }
        }
    }
}
