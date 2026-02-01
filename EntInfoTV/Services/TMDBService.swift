import Foundation

enum TMDBError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingFailed
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing TMDB API key. Set TMDB_API_KEY in EntInfoTV/.env, the scheme environment, or Info.plist."
        case .invalidURL:
            return "Invalid TMDB URL."
        case .invalidResponse:
            return "Unexpected response from TMDB."
        case .httpError(let statusCode):
            return "TMDB request failed with status code \(statusCode)."
        case .decodingFailed:
            return "Failed to decode TMDB response."
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

enum TMDBConfig {
    static var apiKey: String? {
        if let key = ProcessInfo.processInfo.environment["TMDB_API_KEY"], !key.isEmpty {
            return key
        }
        if let key = envFileValue(for: "TMDB_API_KEY"), !key.isEmpty {
            return key
        }
        if let key = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    private static func envFileValue(for key: String) -> String? {
        guard let url = Bundle.main.url(forResource: ".env", withExtension: nil) else {
            return nil
        }
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        for rawLine in contents.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty || line.hasPrefix("#") { continue }
            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            let name = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            if name != key { continue }
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            return value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        }
        return nil
    }
}

final class TMDBService {
    static let shared = TMDBService()

    static let imageBase = "https://image.tmdb.org/t/p/w342"
    static let imageBaseLarge = "https://image.tmdb.org/t/p/w780"

    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchTrending() async throws -> [TrendingItem] {
        let response: ApiResponse<TrendingItem> = try await request("/trending/all/day")
        return response.results
    }

    func fetchTopRatedMovies() async throws -> [Movie] {
        let response: ApiResponse<Movie> = try await request("/movie/top_rated", queryItems: [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ])
        return response.results
    }

    func fetchTopRatedTV() async throws -> [TVShow] {
        let response: ApiResponse<TVShow> = try await request("/tv/top_rated", queryItems: [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ])
        return response.results
    }

    func imageURL(path: String?, large: Bool = false) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let base = large ? Self.imageBaseLarge : Self.imageBase
        return URL(string: base + path)
    }

    private func request<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        guard let apiKey = TMDBConfig.apiKey else {
            throw TMDBError.missingAPIKey
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw TMDBError.invalidURL
        }

        var items = queryItems
        let isV4Token = apiKey.contains(".")
        if !isV4Token {
            items.append(URLQueryItem(name: "api_key", value: apiKey))
        }
        components.queryItems = items

        guard let url = components.url else {
            throw TMDBError.invalidURL
        }

        do {
            var request = URLRequest(url: url)
            if isV4Token {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw TMDBError.httpError(httpResponse.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw TMDBError.decodingFailed
            }
        } catch {
            throw TMDBError.network(error)
        }
    }
}
