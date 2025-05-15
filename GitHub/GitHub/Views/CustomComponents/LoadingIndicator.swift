//
//  LoadingIndicator.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct LoadingIndicator: View {
    let color: Color
    let size: CGFloat
    
    @State private var isAnimating = false
    
    init(color: Color = .accentColor, size: CGFloat = 50) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: size / 10)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(color, style: StrokeStyle(lineWidth: size / 10, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
        }
    }
}

struct LoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LoadingIndicator()
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingIndicator()
        LoadingIndicator(color: .red, size: 30)
        LoadingView()
    }
} 