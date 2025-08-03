//
//  Injected.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//

import Foundation

@propertyWrapper
final class Injected<T> {
    private let keyPath: KeyPath<DependenciesContainer, T>
    var wrappedValue: T {
        DependenciesContainer.shared[keyPath: keyPath]
    }
    
    init(_ keyPath: KeyPath<DependenciesContainer, T>) {
        self.keyPath = keyPath
    }
}
