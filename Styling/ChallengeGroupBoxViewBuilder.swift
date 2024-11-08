//
//  ChallengeGroupBoxViewBuilder.swift
//  Gralometer
//
//  Created by Marcus Benoit on 01.11.24.
//

import SwiftUI

struct ChallengeGroupBoxViewBuilder: View {
    
    let challengeDocumentId: String
    @State private var challenge: Challenge? = nil
    
    // only load the content when it is needed!
    var body: some View {
        ZStack {
            if let challenge {
                ChallengeGroupBoxView(challenge: challenge)
            }
        }
        .task {
            self.challenge = try? await ChallengeManager.shared.getChallenge(challengeId: challengeDocumentId)
        }
    }
}

#Preview {
    let colorSchemeManager = ColorSchemeManager()
    
    ChallengeGroupBoxViewBuilder(challengeDocumentId: "0AEXDq2usqU6iuJYI7WC")
        .environment(colorSchemeManager)
}
