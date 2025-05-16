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
    
    // 获取底部安全区域高度
    private var bottomSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    // 底部标签栏高度（常量）
    private let tabBarHeight: CGFloat = 49
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // 创建一个包含WebView的容器，并添加底部填充
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
                
                // 底部安全区域的背景填充
                Color(.systemBackground)
                    .frame(height: bottomSafeAreaHeight + tabBarHeight)
            }
            
            if isLoading {
                // 绝对定位视图
                ZStack {
                    // 半透明背景遮罩
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.95))
                        .ignoresSafeArea()
                    
                    // 固定位置和尺寸的加载指示器容器
                    VStack(spacing: 20) {
                        // 使用固定尺寸的加载指示器
                        LoadingIndicator(size: 60)
                            .frame(width: 60, height: 60)
                        
                        Text("正在加载页面...")
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
                                Text("重新加载")
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
                    .offset(y: -40) // 向上偏移，避免被底部标签栏遮挡
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            if let error = error {
                // 使用绝对定位的错误视图
                ZStack {
                    // 半透明背景遮罩
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.95))
                        .ignoresSafeArea()
                    
                    // 固定尺寸和位置的错误提示容器
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.icloud.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .frame(width: 60, height: 60)
                        
                        Text("加载失败")
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
                                Text("重试")
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
                                Text("在浏览器中打开")
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
                    .offset(y: -40) // 向上偏移，避免被底部标签栏遮挡
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color(.systemBackground))
    }
} 
