//
//  IssuesListView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/21.
//

import SwiftUI

struct IssuesListView: View {
    let owner: String
    let repoName: String
    
    @StateObject private var viewModel = IssuesViewModel()
    @State private var searchText = ""
    
    var filteredIssues: [Issue] {
        if searchText.isEmpty {
            return viewModel.issues
        } else {
            return viewModel.issues.filter { issue in
                issue.title.localizedCaseInsensitiveContains(searchText) ||
                (issue.body?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("搜索Issues", text: $searchText)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            ZStack {
                if viewModel.isLoading {
                    LoadingView(message: "正在加载Issues...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.loadIssues(owner: owner, repo: repoName)
                    }
                } else if viewModel.issues.isEmpty {
                    EmptyStateView(message: "该仓库没有Issues")
                } else {
                    // 内容视图
                    ZStack(alignment: .bottomTrailing) {
                        List {
                            ForEach(filteredIssues) { issue in
                                NavigationLink(destination: IssueDetailView(owner: owner, repoName: repoName, issueNumber: issue.number)) {
                                    IssueRowView(issue: issue)
                                }
                            }
                        }
                        
                        // 刷新按钮
                        Button(action: {
                            viewModel.loadIssues(owner: owner, repo: repoName)
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .bold))
                                .padding(12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .navigationTitle("Issues")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadIssues(owner: owner, repo: repoName)
        }
    }
}

struct IssueRowView: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                issueStateIcon
                
                Text("#\(issue.number)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(issue.title)
                    .font(.headline)
                    .lineLimit(2)
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                    Text(issue.user.login)
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDate(issue.createdAt))
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "message")
                        .font(.caption)
                    Text("\(issue.comments)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            // 标签显示
            if let labels = issue.labels, !labels.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(labels) { label in
                            LabelView(label: label)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    var issueStateIcon: some View {
        Image(systemName: issue.state == "open" ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
            .foregroundColor(issue.state == "open" ? .green : .purple)
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.date(from: dateString) else { return "Invalid date" }
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

struct LabelView: View {
    let label: Label
    
    var body: some View {
        Text(label.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color(hex: label.color))
            .foregroundColor(isDarkColor(hex: label.color) ? .white : .black)
            .cornerRadius(4)
    }
    
    func isDarkColor(hex: String) -> Bool {
        let color = Color(hex: hex)
        // 简单判断颜色是否为深色
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // 使用亮度公式: (0.299*R + 0.587*G + 0.114*B)
        let brightness = (red * 0.299) + (green * 0.587) + (blue * 0.114)
        
        return brightness < 0.6
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// 使用自定义的错误视图
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("加载失败")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("重试")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
} 