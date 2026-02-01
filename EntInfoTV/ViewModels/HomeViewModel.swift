import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var heroItems: [MediaItem] = []
    @Published var topTV: [MediaItem] = []
    @Published var topMovies: [MediaItem] = []
    @Published var trendingNow: [MediaItem] = []
    @Published var highlyRecommend: [MediaItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: TMDBService
    private var hasLoaded = false

    @MainActor
    init(service: TMDBService = TMDBService()) {
        self.service = service
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func reload() async {
        hasLoaded = false
        await load()
    }

    private func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let trending = service.fetchTrending()
            async let movies = service.fetchTopRatedMovies()
            async let tv = service.fetchTopRatedTV()

            let trendingItems = try await trending
                .filter { $0.mediaType != .person }
                .map { $0.asMediaItem }
            let movieItems = try await movies.map { $0.asMediaItem }
            let tvItems = try await tv.map { $0.asMediaItem }

            heroItems = Array(trendingItems.prefix(8))
            trendingNow = Array(trendingItems.dropFirst(3).prefix(12))
            topMovies = Array(movieItems.prefix(12))
            topTV = Array(tvItems.prefix(12))

            let combined = movieItems + tvItems
            highlyRecommend = combined
                .filter { $0.voteAverage >= 7 }
                .sorted { $0.voteAverage > $1.voteAverage }
                .prefix(12)
                .map { $0 }

            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
