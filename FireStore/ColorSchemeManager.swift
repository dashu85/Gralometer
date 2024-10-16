//
//  ColorSchemeManager.swift
//  Gralometer
//
//  Created by Marcus Benoit on 12.10.24.
//

import Foundation
import SwiftUI

enum AppColorScheme: String, CaseIterable, Identifiable {
    case bvb
    case svw
    case bsc
    case party
    
    var id: String { self.rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .bvb: return .yellow
        case .svw: return .green
        case .bsc: return .blue
        case .party: return .yellow
        }
    }
    
    var cardViewBackground: Color {
        switch self {
        case .bvb: return .black
        case .svw: return .green
        case .bsc: return .blue
        case .party: return .yellow
        }
    }
    
    var textColor: Color {
        switch self {
        case .bvb: return .yellow
        case .svw: return .white
        case .bsc: return .white
        case .party: return .black
        }
    }
    
    var viewBackgroundGradient: [Color] {
        switch self {
        case .bvb: return [.yellow]
        case .svw: return [.white]
        case .bsc: return [.white]
        case .party: return [.red, .orange, .yellow, .green, .blue, .purple, .red, .orange, .yellow, .green, .blue, .purple]
        }
    }
    
    var description: String {
        switch self {
        case .bvb: return "BVB 09 🥳"
        case .svw: return "SVW 🐟🤮"
        case .bsc: return  "HBSC 🥴"
        case .party: return  "Party 🎉"
        }
    }
}

class ColorSchemeManager: ObservableObject, Observable {
    static let shared = ColorSchemeManager()
    init() { }
    
    @Published var selectedScheme: AppColorScheme = .bvb
}
