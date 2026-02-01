import Combine
import Foundation

@MainActor
final class TVViewModel: ObservableObject {
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
            async let popularTV = service.fetchPopularTV()
            async let topTV = service.fetchTopRatedTV()

            let popularItems = try await popularTV.map { $0.asMediaItem }
            let topItems = try await topTV.map { $0.asMediaItem }

            popular = Array(popularItems.prefix(20))
            topRated = Array(topItems.prefix(20))
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
