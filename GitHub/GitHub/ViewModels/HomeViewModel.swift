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
    
    // Cache control
    @Published var useCacheForRequests: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repositoryService: RepositoryServiceProtocol = RepositoryService()) {
        self.repositoryService = repositoryService
        
        // Monitor language selection
        $selectedLanguage
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchTrendingRepositories()
                }
            }
            .store(in: &cancellables)
        
        // Monitor time span selection
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
        
        // Log request information
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
                    
                    // Detailed error handling
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .rateLimitExceeded:
                            self?.errorMessage = "API rate limit exceeded, please try again later"
                            self?.showingRateLimitWarning = true
                            
                            // Automatically enable cache to reduce API calls
                            self?.useCacheForRequests = true
                            
                            // If local cache exists, try to use cached data
                            if self?.repositories.isEmpty ?? true {
                                self?.retryWithCache()
                            }
                            
                        case .unauthorized:
                            self?.errorMessage = "Authentication failed, please log in again"
                        case .serverError(let statusCode):
                            self?.errorMessage = "Server error: Status code \(statusCode)"
                        case .decodingError:
                            self?.errorMessage = "Data parsing error, please contact the developer"
                        default:
                            self?.errorMessage = "Loading failed: \(error.localizedDescription)"
                        }
                    } else {
                        self?.errorMessage = "Loading failed: \(error.localizedDescription)"
                    }
                    
                    print("❌ Error loading trending repositories: \(error)")
                }
            }
        }
    }
    
    // Try to reload data using cache
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
                        self?.errorMessage = "API rate limit reached, showing cached data"
                    }
                    
                case .failure:
                    // Cache also failed, keep the original error message
                    break
                }
            }
        }
    }
    
    // Refresh repository list (force refresh, don't use cache)
    func refreshRepositories() {
        // Temporarily disable cache, force data refresh
        let originalCacheSetting = useCacheForRequests
        useCacheForRequests = false
        
        fetchTrendingRepositories()
        
        // Restore original cache setting after refresh
        useCacheForRequests = originalCacheSetting
    }
    
    // Clear all caches
    func clearAllCaches() {
        repositoryService.clearCache()
    }
    
    // Toggle cache usage state
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
