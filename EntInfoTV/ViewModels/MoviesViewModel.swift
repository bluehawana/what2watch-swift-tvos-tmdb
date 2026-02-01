import Combine
import Foundation

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var popular: [MediaItem] = []
    @Published var topRated: [MediaItem] = []
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
            async let popularMovies = service.fetchPopularMovies()
            async let topMovies = service.fetchTopRatedMovies()

            let popularItems = try await popularMovies.map { $0.asMediaItem }
            let topItems = try await topMovies.map { $0.asMediaItem }

            popular = Array(popularItems.prefix(20))
            topRated = Array(topItems.prefix(20))
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
