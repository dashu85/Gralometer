//
//  ChallengeDetailViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 21.04.25.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class ChallengeDetailViewModel: ObservableObject {
    @Published var colorSchemeManager: ColorSchemeManager
    private let challenge: Challenge
        
    // Published properties that the view will observe
    @Published var title: String
    @Published var number: Int
    @Published var formattedDate: String
    @Published var type: String
    @Published var category: String
    @Published var place: String
    @Published var numberOfParticipants: Int
    @Published var description: String
    @Published var winner: String = "Marcus B" // TODO: Change name automatically
    @Published var challenger: String = "Robert B" // TODO: Change name automatically
    
    @Published var selectedItems = [PhotosPickerItem]()
    @Published var selectedImages = [Image]()
    
    private let fixedColumn = [
        GridItem(.fixed(100)),
        GridItem(.fixed(100)),
        GridItem(.fixed(100))
    ]
    
    // MARK: - Format handling
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
        
    // MARK: - Init Section
    init(challenge: Challenge) {
        self.challenge = challenge
        
        // Initialize published properties
        self.title = challenge.title ?? "Untitled Challenge"
        self.number = challenge.number ?? 1909
        self.formattedDate = challenge.date != nil ? dateFormatter.string(from: challenge.date!) : "No date"
        self.type = challenge.type ?? "Sport"
        self.category = challenge.category ?? "Sport"
        self.place = challenge.place ?? "No location"
        self.numberOfParticipants = challenge.numberOfParticipants ?? 2
        self.description = challenge.challengeDescription ?? "No description available."
        self.colorSchemeManager = .init()
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(challenge.number ?? 1909)")
                    .font(.headline)
                    .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
                
                Spacer()
                
                Text(challenge.date != nil ? dateFormatter.string(from: challenge.date!) : "No date")
                    .font(.subheadline)
                    .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
            }
            
            Text(challenge.title ?? "Untitled Challenge")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
            
            HStack {
                categoryBadge(text: challenge.type ?? "Sport")
                categoryBadge(text: challenge.category ?? "Sport")
                Spacer()
            }
        }
    }
    
    // MARK: - Image Section
    var imageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("standardPhoto")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
            
            Text(challenge.place ?? "No location")
                .font(.caption)
                .padding(8)
                .background(Material.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(12)
        }
    }
    
    // MARK: - Info Section
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Challenge Information")
            
            HStack {
                infoItem(icon: "number.circle.fill", title: "ID", value: "\(challenge.number ?? 1)")
                Spacer()
                infoItem(icon: "person.2.fill", title: "Participants", value: "\(challenge.numberOfParticipants ?? 2)")
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Description Section
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Description")
            
            Text(challenge.challengeDescription ?? "No description available.")
                .font(.body)
                .foregroundColor(colorSchemeManager.selectedScheme.textColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorSchemeManager.selectedScheme.cardViewBackground)
                )
        }
    }
    
    // MARK: - Participants Section
    var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Participants")
            
            // Winner Box
            participantBox(
                title: "Winner",
                name: "Marcus B",
                iconName: "trophy.fill",
                iconColor: .yellow
            )
            
            // Other Participants
            participantBox(
                title: "Challenger",
                name: "Robert B",
                iconName: "person.fill",
                iconColor: colorSchemeManager.selectedScheme.backgroundColor
            )
        }
    }
    
    // MARK: - Photos Section
    var photosSection: some View {
        // show Images of challenge
        LazyVGrid(columns: fixedColumn, spacing: 20) {
            ForEach(0..<selectedImages.count, id: \.self) { i in
                self.selectedImages[i]
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
        }
    }
    
    
    // MARK: - Helper Views
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
            .padding(.top, 8)
    }
    
    func categoryBadge(text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(colorSchemeManager.selectedScheme.cardViewBackground.opacity(0.2))
            )
            .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
    }
    
    func infoItem(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(colorSchemeManager.selectedScheme.backgroundColor)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(colorSchemeManager.selectedScheme.textColor)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(colorSchemeManager.selectedScheme.textColor)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorSchemeManager.selectedScheme.cardViewBackground)
        )
    }
    
    func participantBox(title: String, name: String, iconName: String, iconColor: Color) -> some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
                
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(colorSchemeManager.selectedScheme.textColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(colorSchemeManager.selectedScheme.cardViewBackground)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorSchemeManager.selectedScheme.cardViewBackground)
        )
    }
}

