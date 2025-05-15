//
//  RepositoryCard.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI
import Kingfisher

struct RepositoryCard: View {
    let repository: Repository
    let showOwner: Bool
    
    init(repository: Repository, showOwner: Bool = true) {
        self.repository = repository
        self.showOwner = showOwner
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if showOwner {
                    KFImage(URL(string: repository.owner.avatarUrl))
                        .placeholder {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(showOwner ? repository.fullName : repository.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let language = repository.language {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(languageColor(language))
                                .frame(width: 12, height: 12)
                            
                            Text(language)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(repository.stargazersCount)")
                            .font(.subheadline)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "tuningfork")
                            .foregroundColor(.gray)
                        Text("\(repository.forksCount)")
                            .font(.subheadline)
                    }
                }
            }
            
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    // Function to return a color based on programming language
    private func languageColor(_ language: String) -> Color {
        switch language.lowercased() {
        case "swift":
            return .orange
        case "objective-c":
            return .blue
        case "kotlin":
            return .purple
        case "java":
            return .red
        case "javascript":
            return .yellow
        case "typescript":
            return .blue
        case "python":
            return .green
        case "ruby":
            return .red
        case "go":
            return .orange
        case "rust":
            return .blue
        case "c++", "c":
            return .purple
        case "c#":
            return .red
        case "php":
            return .yellow
        default:
            return .gray
        }
    }
}

#Preview {
    RepositoryCard(repository: Repository.placeholder)
        .padding()
        .previewLayout(.sizeThatFits)
} 
