//
//  ExtensionBinding.swift
//  Gralometer
//
//  Created by Marcus Benoit on 13.07.24.
//

import Foundation
import SwiftUI
import SwiftData

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
