//
//  WebView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/20.
//

import SwiftUI
@preconcurrency import WebKit
import Combine

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        configuration.applicationNameForUserAgent = "GitHubiOSApp/1.0"
        
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.systemBackground
        
        let websiteDataStore = WKWebsiteDataStore.default()
        websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.addValue("GitHubiOSApp/1.0", forHTTPHeaderField: "User-Agent")
        
        if context.coordinator.currentURL != url.absoluteString {
            context.coordinator.loadURL(webView: webView, request: request)
            context.coordinator.currentURL = url.absoluteString
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var currentURL: String = ""
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func loadURL(webView: WKWebView, request: URLRequest) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.error = nil
            }
            webView.load(request)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.error = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleError(error)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        private func handleError(_ error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.error = error
            }
        }
    }
}

struct WebViewPage: View {
    let url: URL
    let title: String
    
    @State private var isLoading = true
    @State private var error: Error? = nil
    @State private var showRetryButton = false
    
    // Get the bottom safe area height
    private var bottomSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    // Bottom tab bar height (constant)
    private let tabBarHeight: CGFloat = 49
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Create a container with WebView and add bottom padding
            VStack(spacing: 0) {
                WebView(url: url, isLoading: $isLoading, error: $error)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if self.isLoading {
                                withAnimation {
                                    self.showRetryButton = true
                                }
                            }
                        }
                    }
                
                // Background fill for bottom safe area
                Color(.systemBackground)
                    .frame(height: bottomSafeAreaHeight + tabBarHeight)
            }
            
            if isLoading {
                // Absolutely positioned view
                ZStack {
                    // Semi-transparent background mask
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.95))
                        .ignoresSafeArea()
                    
                    // Loading indicator container with fixed position and size
                    VStack(spacing: 20) {
                        // Use fixed size loading indicator
                        LoadingIndicator(size: 60)
                            .frame(width: 60, height: 60)
                        
                        Text("Loading page...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: true, vertical: true)
                        
                        if showRetryButton {
                            Button(action: {
                                DispatchQueue.main.async {
                                    self.error = nil
                                    self.isLoading = true
                                    self.showRetryButton = false
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.isLoading = true
                                    self.error = nil
                                }
                            }) {
                                Text("Reload")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    )
                    .offset(y: -40) // Offset upward to avoid being covered by bottom tab bar
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            if let error = error {
                // Error view with absolute positioning
                ZStack {
                    // Semi-transparent background mask
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.95))
                        .ignoresSafeArea()
                    
                    // Error message container with fixed size and position
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.icloud.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .frame(width: 60, height: 60)
                        
                        Text("Loading Failed")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: true, vertical: true)
                        
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .lineLimit(4)
                        
                        Button(action: {
                            DispatchQueue.main.async {
                                self.error = nil
                                self.isLoading = true
                                self.showRetryButton = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.top, 5)
                        
                        Button(action: {
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                Text("Open in Browser")
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.top, 5)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    )
                    .frame(maxWidth: 350)
                    .offset(y: -40) // Offset upward to avoid being covered by bottom tab bar
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color(.systemBackground))
    }
} 
