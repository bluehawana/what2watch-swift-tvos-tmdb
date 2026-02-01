import Foundation

enum MediaType: String, Decodable {
    case movie
    case tv
    case person
}

struct ApiResponse<T: Decodable>: Decodable {
    let results: [T]
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String
    let voteAverage: Double
}

struct TVShow: Decodable {
    let id: Int
    let name: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String
    let voteAverage: Double
}

struct Genre: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
}

struct Creator: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let profilePath: String?
}

struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let overview: String
    let tagline: String?
    let releaseDate: String?
    let voteAverage: Double
    let genres: [Genre]
}

struct TVDetail: Decodable {
    let id: Int
    let name: String
    let overview: String
    let tagline: String?
    let firstAirDate: String?
    let voteAverage: Double
    let genres: [Genre]
    let createdBy: [Creator]
}

struct CreditsResponse: Decodable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
}

struct CrewMember: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let job: String?
    let profilePath: String?
}

struct ReviewsResponse: Decodable {
    let id: Int
    let results: [Review]
}

struct Review: Decodable, Hashable, Identifiable {
    let id: String
    let author: String
    let content: String
    let authorDetails: AuthorDetails?
}

struct AuthorDetails: Decodable, Hashable {
    let rating: Double?
    let avatarPath: String?
    let name: String?
    let username: String?
}

struct TrendingItem: Decodable {
    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?
    let backdropPath: String?
    let overview: String?
    let voteAverage: Double?
    let mediaType: MediaType
}

struct WatchProviderResponse: Decodable {
    let id: Int
    let results: [String: WatchProviderRegion]?
}

struct WatchProviderRegion: Decodable, Hashable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
    let free: [WatchProvider]?
    let ads: [WatchProvider]?
}

struct WatchProvider: Decodable, Identifiable, Hashable {
    let displayPriority: Int?
    let logoPath: String?
    let providerId: Int
    let providerName: String

    var id: Int { providerId }
}

struct MediaItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String
    let voteAverage: Double
    let mediaType: MediaType

    var titleText: String {
        title.isEmpty ? "Untitled" : title
    }

    var mediaTypeLabel: String {
        switch mediaType {
        case .movie:
            return "Movie"
        case .tv:
            return "TV Series"
        case .person:
            return "Person"
        }
    }
}

extension Movie {
    var asMediaItem: MediaItem {
        MediaItem(
            id: id,
            title: title,
            posterPath: posterPath,
            backdropPath: backdropPath,
            overview: overview,
            voteAverage: voteAverage,
            mediaType: .movie
        )
    }
}

extension TVShow {
    var asMediaItem: MediaItem {
        MediaItem(
            id: id,
            title: name,
            posterPath: posterPath,
            backdropPath: backdropPath,
            overview: overview,
            voteAverage: voteAverage,
            mediaType: .tv
        )
    }
}

extension TrendingItem {
    var asMediaItem: MediaItem {
        MediaItem(
            id: id,
            title: title ?? name ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            overview: overview ?? "",
            voteAverage: voteAverage ?? 0,
            mediaType: mediaType
        )
    }
}
