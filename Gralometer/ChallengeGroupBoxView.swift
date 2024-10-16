//
//  ChallengeGroupBoxView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 10.10.24.
//

import SwiftUI

struct ChallengeGroupBoxView: View {
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    let challenge: Challenge
    
    var body: some View {
        VStack {
            ZStack {
                GroupBox("#0\(String(challenge.number ?? 1909)) - \(challenge.title ?? "Ooopsie")") {
                    GeometryReader { geometry in
                        ZStack {
                            Image("standardPhoto")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .position(x: geometry.size.width / 2, y: 100)
                            
                            GroupBox("Winner: Name-Placeholder") {
                                    Text("Teilnehmer: *Placeholder*, *Placeholder*")
                            }
                            .foregroundStyle(.black)
                            .backgroundStyle(colorSchemeManager.selectedScheme.backgroundColor.opacity(0.8))
                            .frame(maxWidth: geometry.size.width * 0.96, maxHeight: 60)
                            .position(x: geometry.size.width / 2, y: 155)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 260, maxHeight: 260)
                .backgroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
                .foregroundStyle(colorSchemeManager.selectedScheme.textColor)
            } // ZStack
        } // VStack
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 10)
        .padding(10)
    } // body
}


#Preview {
    let colorSchemeManager = ColorSchemeManager()
    
    ChallengeGroupBoxView(challenge: Challenge(id: "One", title: "Titel", number: 1909, date: Date(), place: "Berlin", challengeDescription: "black", type: "Sport", category: "Sport", numberOfParticipants: 2))
        .environmentObject(colorSchemeManager)
}
