import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var results: [MediaItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: TMDBService

    @MainActor
    init(service: TMDBService = TMDBService()) {
        self.service = service
    }

    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let items = try await service.searchMulti(query: trimmed)
                .filter { $0.mediaType != .person }
                .map { $0.asMediaItem }
            results = items
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
