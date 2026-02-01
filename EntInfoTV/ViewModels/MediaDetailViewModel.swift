import Combine
import Foundation
import SwiftUI

@MainActor
final class MediaDetailViewModel: ObservableObject {
    @Published var title: String?
    @Published var tagline: String?
    @Published var overview: String?
    @Published var releaseText: String?
    @Published var genres: [Genre] = []
    @Published var cast: [CastMember] = []
    @Published var directors: [CrewMember] = []
    @Published var creators: [Creator] = []
    @Published var executiveProducers: [CrewMember] = []
    @Published var reviews: [Review] = []
    @Published var providers: WatchProviderRegion?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isInWatchlist = false

    private let service: TMDBService
    private var hasLoaded = false
    private var watchlistKey: String = ""

    @AppStorage("entinfo_watchlist") private var watchlistStorage = "[]"

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

    func toggleWatchlist(media: MediaItem) {
        watchlistKey = key(for: media)
        var set = currentWatchlist()
        if set.contains(watchlistKey) {
            set.remove(watchlistKey)
            isInWatchlist = false
        } else {
            set.insert(watchlistKey)
            isInWatchlist = true
        }
        persistWatchlist(set)
    }

    private func load(media: MediaItem) async {
        isLoading = true
        errorMessage = nil
        watchlistKey = key(for: media)
        isInWatchlist = currentWatchlist().contains(watchlistKey)

        do {
            let region = Locale.current.region?.identifier ?? "US"
            async let providerInfo = service.fetchWatchProviders(for: media, region: region)
            async let creditsResponse = service.fetchCredits(for: media)
            async let reviewItems = service.fetchReviews(for: media)

            switch media.mediaType {
            case .movie:
                let detail = try await service.fetchMovieDetail(id: media.id)
                title = detail.title
                tagline = detail.tagline
                overview = detail.overview
                releaseText = releaseYear(from: detail.releaseDate)
                genres = detail.genres
                creators = []
            case .tv:
                let detail = try await service.fetchTVDetail(id: media.id)
                title = detail.name
                tagline = detail.tagline
                overview = detail.overview
                releaseText = releaseYear(from: detail.firstAirDate)
                genres = detail.genres
                creators = detail.createdBy
            case .person:
                title = media.titleText
                overview = media.overview
                releaseText = nil
                genres = []
                creators = []
            }

            if let credits = try await creditsResponse {
                cast = Array(credits.cast.prefix(12))
                directors = credits.crew.filter { $0.job == "Director" }.prefix(4).map { $0 }
                executiveProducers = credits.crew.filter { $0.job == "Executive Producer" }.prefix(4).map { $0 }
            } else {
                cast = []
                directors = []
                executiveProducers = []
            }

            reviews = Array((try await reviewItems).prefix(3))
            providers = try await providerInfo
            hasLoaded = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    private func key(for media: MediaItem) -> String {
        "\(media.mediaType.rawValue)-\(media.id)"
    }

    private func currentWatchlist() -> Set<String> {
        guard let data = watchlistStorage.data(using: .utf8),
              let list = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(list)
    }

    private func persistWatchlist(_ set: Set<String>) {
        let list = Array(set).sorted()
        if let data = try? JSONEncoder().encode(list),
           let string = String(data: data, encoding: .utf8) {
            watchlistStorage = string
        }
    }

    private func releaseYear(from dateString: String?) -> String? {
        guard let dateString, let year = dateString.split(separator: "-").first else { return nil }
        return String(year)
    }
}
