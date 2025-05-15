//
//  HomeViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    private let repositoryService: RepositoryServiceProtocol
    
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedLanguage: String = ""
    @Published var selectedTimeSpan: String = "week"
    @Published var showingRateLimitWarning: Bool = false
    
    // 缓存控制
    @Published var useCacheForRequests: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repositoryService: RepositoryServiceProtocol = RepositoryService()) {
        self.repositoryService = repositoryService
        
        // 监听语言选择
        $selectedLanguage
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchTrendingRepositories()
                }
            }
            .store(in: &cancellables)
        
        // 监听时间范围选择
        $selectedTimeSpan
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchTrendingRepositories()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchTrendingRepositories() {
        errorMessage = nil
        isLoading = true
        showingRateLimitWarning = false
        
        // 记录请求信息
        print("📊 Fetching trending repos with language: '\(selectedLanguage)' and timeSpan: '\(selectedTimeSpan)'")
        
        repositoryService.getTrendingRepositories(
            language: selectedLanguage.isEmpty ? nil : selectedLanguage, 
            timeSpan: selectedTimeSpan,
            useCache: useCacheForRequests
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let repos):
                    self?.repositories = repos
                    print("✅ Successfully loaded \(repos.count) trending repositories")
                    
                case .failure(let error):
                    self?.repositories = []
                    
                    // 详细错误处理
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .rateLimitExceeded:
                            self?.errorMessage = "API请求次数已达上限，请稍后再试"
                            self?.showingRateLimitWarning = true
                            
                            // 自动启用缓存，以减少API调用
                            self?.useCacheForRequests = true
                            
                            // 如果有本地缓存，尝试使用缓存中的旧数据
                            if self?.repositories.isEmpty ?? true {
                                self?.retryWithCache()
                            }
                            
                        case .unauthorized:
                            self?.errorMessage = "认证失败，请重新登录"
                        case .serverError(let statusCode):
                            self?.errorMessage = "服务器错误：状态码 \(statusCode)"
                        case .decodingError:
                            self?.errorMessage = "数据解析错误，请联系开发者"
                        default:
                            self?.errorMessage = "加载失败：\(error.localizedDescription)"
                        }
                    } else {
                        self?.errorMessage = "加载失败：\(error.localizedDescription)"
                    }
                    
                    print("❌ Error loading trending repositories: \(error)")
                }
            }
        }
    }
    
    // 尝试使用缓存重新加载数据
    private func retryWithCache() {
        print("🔄 Retrying with cache...")
        
        repositoryService.getTrendingRepositories(
            language: selectedLanguage.isEmpty ? nil : selectedLanguage, 
            timeSpan: selectedTimeSpan,
            useCache: true
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repos):
                    self?.repositories = repos
                    print("📦 Loaded \(repos.count) repositories from cache")
                    
                    if !repos.isEmpty {
                        self?.errorMessage = "已达到API请求限制，显示的是缓存数据"
                    }
                    
                case .failure:
                    // 缓存也失败了，保持原来的错误信息
                    break
                }
            }
        }
    }
    
    // 刷新仓库列表（强制刷新，不使用缓存）
    func refreshRepositories() {
        // 临时禁用缓存，强制刷新数据
        let originalCacheSetting = useCacheForRequests
        useCacheForRequests = false
        
        fetchTrendingRepositories()
        
        // 刷新后恢复原来的缓存设置
        useCacheForRequests = originalCacheSetting
    }
    
    // 清除所有缓存
    func clearAllCaches() {
        repositoryService.clearCache()
    }
    
    // 切换缓存使用状态
    func toggleCacheUsage() {
        useCacheForRequests.toggle()
    }
    
    // Popular programming languages to filter by
    let languages = [
        "Swift", "Objective-C", "Kotlin", "Java", "JavaScript", "TypeScript", 
        "Python", "Go", "Rust", "C++", "C#", "Ruby", "PHP"
    ]
    
    // Time spans to filter by
    let timeSpans = [
        ("day", "Today"),
        ("week", "This week"),
        ("month", "This month"),
        ("year", "This year")
    ]
} 
