import Combine
import Foundation

@MainActor
final class MediaDetailViewModel: ObservableObject {
    @Published var providers: WatchProviderRegion?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: TMDBService
    private var hasLoaded = false

    init(service: TMDBService = TMDBService()) {
        self.service = service
    }

    func loadIfNeeded(media: MediaItem) async {
        guard !hasLoaded else { return }
        await load(media: media)
    }

    func reload(media: MediaItem) async {
        hasLoaded = false
        await load(media: media)
    }

    private func load(media: MediaItem) async {
        isLoading = true
        errorMessage = nil

        do {
            let region = Locale.current.region?.identifier ?? "US"
            providers = try await service.fetchWatchProviders(for: media, region: region)
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
