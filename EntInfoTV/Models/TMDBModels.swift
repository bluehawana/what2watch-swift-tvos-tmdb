import Foundation

enum MediaType: String, Decodable {
    case movie
    case tv
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

struct TrendingItem: Decodable {
    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?
    let backdropPath: String?
    let overview: String
    let voteAverage: Double
    let mediaType: MediaType
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
        mediaType == .movie ? "Movie" : "TV Series"
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
            overview: overview,
            voteAverage: voteAverage,
            mediaType: mediaType
        )
    }
}
