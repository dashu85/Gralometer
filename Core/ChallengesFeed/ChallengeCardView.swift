//
//  ChallengeCardView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftUI
import SwiftData

struct ChallengeCardView: View {
    @Bindable var challenge: SwiftDataChallenge
    
    var body: some View {
        VStack {
            ZStack {
                GroupBox("#0\(challenge.number ?? 0) - \(challenge.title ?? "N/A")") {
                    Image("standardPhoto")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 330, height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .backgroundStyle(Color.black)
                .foregroundStyle(.yellow)
                
                GroupBox {
                    VStack(alignment: .leading) {
                        Text("Winner: Thomas")
                            .bold()
                        
                        HStack {
                            Text("Teilnehmer: RB, MG, MK")
                        }
                        Spacer()
                    }
                    .frame(width: 300, height: 60)
                    .offset(x: -60)
                    .foregroundStyle(.black)
                }
                .backgroundStyle((Color(.yellow) .opacity(0.8)))
                .offset(y: 65)
            } // ZStack
        } // VStack
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 10)
        .padding(10)
    }
}


//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: SwiftDataChallenge.self, configurations: config)
//        
//        return ChallengeCardView(challenge: SwiftDataChallenge())
//            .modelContainer(container)
//    } catch {
//        return Text(error.localizedDescription)
//    }
//}
