import Combine
import Foundation

@MainActor
final class TrendingViewModel: ObservableObject {
    @Published var trending: [MediaItem] = []
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
            let items = try await service.fetchTrending()
                .filter { $0.mediaType != .person }
                .map { $0.asMediaItem }
            trending = Array(items.prefix(24))
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
