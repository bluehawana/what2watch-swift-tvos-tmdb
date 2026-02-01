import SwiftUI

struct MediaDetailView: View {
    let media: MediaItem
    @StateObject private var viewModel = MediaDetailViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(media: media, tagline: viewModel.tagline, releaseText: viewModel.releaseText)

                actionRow

                if !viewModel.genres.isEmpty {
                    GenreRow(genres: viewModel.genres)
                        .padding(.horizontal, 48)
                }

                if !viewModel.cast.isEmpty {
                    CastRow(cast: viewModel.cast)
                }

                if !viewModel.directors.isEmpty {
                    PeopleList(title: "Directors", people: viewModel.directors.map { $0.name })
                        .padding(.horizontal, 48)
                }

                if !viewModel.creators.isEmpty {
                    PeopleList(title: "Creators", people: viewModel.creators.map { $0.name })
                        .padding(.horizontal, 48)
                } else if !viewModel.executiveProducers.isEmpty {
                    PeopleList(title: "Executive Producers", people: viewModel.executiveProducers.map { $0.name })
                        .padding(.horizontal, 48)
                }

                watchProvidersSection

                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                    Text(overviewText)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 48)

                if !viewModel.reviews.isEmpty {
                    ReviewsSection(reviews: viewModel.reviews)
                        .padding(.horizontal, 48)
                }

                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .top)
        .task { await viewModel.loadIfNeeded(media: media) }
    }

    private var overviewText: String {
        let detailOverview = viewModel.overview ?? media.overview
        return detailOverview.isEmpty ? "No overview available." : detailOverview
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            Button(viewModel.isInWatchlist ? "Added to List" : "Add to List") {
                viewModel.toggleWatchlist(media: media)
            }
            .buttonStyle(.borderedProminent)

            if let quickProviders = quickProviderLinks, !quickProviders.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(quickProviders) { provider in
                            Button {
                                if let url = URL(string: provider.url) {
                                    openURL(url)
                                }
                            } label: {
                                QuickProviderCard(provider: provider)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .focusSection()
            }
        }
        .padding(.horizontal, 48)
    }

    private var quickProviderLinks: [QuickProvider]? {
        guard let providers = viewModel.providers else { return nil }
        var all: [WatchProvider] = []
        if let flatrate = providers.flatrate { all.append(contentsOf: flatrate) }
        if let ads = providers.ads { all.append(contentsOf: ads) }
        if let free = providers.free { all.append(contentsOf: free) }
        if let rent = providers.rent { all.append(contentsOf: rent) }
        if let buy = providers.buy { all.append(contentsOf: buy) }

        let preferred = QuickProviderCatalog.shared.matchingProviders(from: all)
        return Array(preferred.prefix(6))
    }

    @ViewBuilder
    private var watchProvidersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Where to Watch")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .padding(.horizontal, 48)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.horizontal, 48)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    Task { await viewModel.reload(media: media) }
                }
                .frame(maxWidth: .infinity, minHeight: 160)
            } else if let providers = viewModel.providers {
                ProviderSection(title: "Included with Subscription", providers: providers.flatrate ?? [])
                ProviderSection(title: "Free with Ads", providers: providers.ads ?? [])
                ProviderSection(title: "Free", providers: providers.free ?? [])
                ProviderSection(title: "Rent", providers: providers.rent ?? [])
                ProviderSection(title: "Buy", providers: providers.buy ?? [])

                if let link = providers.link, let url = URL(string: link) {
                    Button("Open Watch Options") {
                        openURL(url)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 48)
                    .padding(.top, 8)
                }
            } else {
                Text("No streaming providers available for your region.")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 48)
            }
        }
    }
}

private struct HeaderView: View {
    let media: MediaItem
    let tagline: String?
    let releaseText: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImageView(url: TMDBService.shared.imageURL(path: media.backdropPath ?? media.posterPath, large: true))
                .frame(height: 420)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    AppTheme.background.opacity(0.65),
                    AppTheme.background,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 420)

            HStack(alignment: .bottom, spacing: 24) {
                RemoteImageView(url: TMDBService.shared.imageURL(path: media.posterPath))
                    .frame(width: 180, height: 270)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 12) {
                    Text(media.titleText)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppTheme.text)
                        .lineLimit(2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text([media.mediaTypeLabel, releaseText].compactMap { $0 }.joined(separator: " • "))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        if let tagline, !tagline.isEmpty {
                            Text(tagline)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.text)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.accent)
                        Text(String(format: "%.1f", media.voteAverage))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 24)
        }
    }
}

private struct RemoteImageView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: 40)
                    @unknown default:
                        PlaceholderView(iconSize: 40)
                    }
                }
            } else {
                PlaceholderView(iconSize: 40)
            }
        }
        .background(AppTheme.surfaceSecondary)
    }
}

private struct GenreRow: View {
    let genres: [Genre]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(genres) { genre in
                    Text(genre.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.surfaceSecondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                }
            }
        }
        .focusSection()
        .scrollIndicators(.hidden)
    }
}

private struct CastRow: View {
    let cast: [CastMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .padding(.horizontal, 48)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(cast) { member in
                        CastCard(member: member)
                    }
                }
                .padding(.horizontal, 48)
            }
            .focusSection()
            .scrollIndicators(.hidden)
        }
    }
}

private struct CastCard: View {
    let member: CastMember
    @State private var isFocused = false

    var body: some View {
        VStack(spacing: 8) {
            PersonImage(url: TMDBService.shared.profileImageURL(path: member.profilePath))
                .frame(width: 120, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isFocused ? AppTheme.primary : Color.clear, lineWidth: 3)
                )

            Text(member.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .lineLimit(1)

            if let role = member.character, !role.isEmpty {
                Text(role)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 140)
        .scaleEffect(isFocused ? 1.06 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .focusable(true) { focused in
            isFocused = focused
        }
    }
}

private struct PersonImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: 24, iconName: "person.fill")
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: 24, iconName: "person.fill")
                    @unknown default:
                        PlaceholderView(iconSize: 24, iconName: "person.fill")
                    }
                }
            } else {
                PlaceholderView(iconSize: 24, iconName: "person.fill")
            }
        }
        .background(AppTheme.surfaceSecondary)
        .clipped()
    }
}

private struct PeopleList: View {
    let title: String
    let people: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.text)
            Text(people.joined(separator: " · "))
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

private struct ReviewsSection: View {
    let reviews: [Review]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppTheme.text)

            ForEach(reviews) { review in
                ReviewCard(review: review)
            }
        }
    }
}

private struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.text)
                Spacer()
                if let rating = review.authorDetails?.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.accent)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                    }
                }
            }

            Text(review.content)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(4)
        }
        .padding(16)
        .background(AppTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct QuickProvider: Identifiable, Hashable {
    let id: Int
    let name: String
    let logoPath: String?
    let url: String
}

private struct QuickProviderCatalog {
    static let shared = QuickProviderCatalog()

    private let mapping: [(key: String, url: String)] = [
        ("netflix", "https://www.netflix.com"),
        ("apple tv", "https://tv.apple.com"),
        ("apple tv+", "https://tv.apple.com"),
        ("prime video", "https://www.primevideo.com"),
        ("amazon prime video", "https://www.primevideo.com"),
        ("hbo max", "https://www.max.com"),
        ("max", "https://www.max.com"),
        ("disney plus", "https://www.disneyplus.com"),
        ("hulu", "https://www.hulu.com"),
        ("paramount plus", "https://www.paramountplus.com"),
        ("peacock", "https://www.peacocktv.com"),
        ("starz", "https://www.starz.com"),
        ("showtime", "https://www.paramountplus.com/showtime/"),
        ("tubi", "https://tubitv.com"),
        ("pluto tv", "https://pluto.tv"),
        ("crunchyroll", "https://www.crunchyroll.com"),
    ]

    func matchingProviders(from providers: [WatchProvider]) -> [QuickProvider] {
        var results: [QuickProvider] = []
        var used = Set<Int>()

        for provider in providers {
            if used.contains(provider.providerId) { continue }
            let lower = provider.providerName.lowercased()
            if let match = mapping.first(where: { lower.contains($0.key) }) {
                used.insert(provider.providerId)
                results.append(QuickProvider(
                    id: provider.providerId,
                    name: provider.providerName,
                    logoPath: provider.logoPath,
                    url: match.url
                ))
            }
        }

        return results
    }
}

private struct QuickProviderCard: View {
    let provider: QuickProvider
    @State private var isFocused = false

    var body: some View {
        HStack(spacing: 8) {
            ProviderLogo(url: TMDBService.shared.providerLogoURL(path: provider.logoPath))
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(provider.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.surfaceSecondary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isFocused ? AppTheme.primary : AppTheme.border, lineWidth: isFocused ? 2 : 1)
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .focusable(true) { focused in
            isFocused = focused
        }
    }
}

private struct ProviderSection: View {
    let title: String
    let providers: [WatchProvider]

    var body: some View {
        let sorted = providers.sorted { ($0.displayPriority ?? 999) < ($1.displayPriority ?? 999) }
        if !sorted.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.text)
                    .padding(.horizontal, 48)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                        ForEach(sorted) { provider in
                            ProviderCard(provider: provider)
                        }
                    }
                    .padding(.horizontal, 48)
                }
                .focusSection()
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct ProviderCard: View {
    let provider: WatchProvider
    @State private var isFocused = false

    var body: some View {
        VStack(spacing: 8) {
            ProviderLogo(url: TMDBService.shared.providerLogoURL(path: provider.logoPath))
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isFocused ? AppTheme.primary : Color.clear, lineWidth: 3)
                )

            Text(provider.providerName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.text)
                .lineLimit(1)
                .frame(width: 96)
        }
        .scaleEffect(isFocused ? 1.08 : 1.0)
        .shadow(color: .black.opacity(isFocused ? 0.5 : 0.2), radius: isFocused ? 10 : 4, x: 0, y: 4)
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .focusable(true) { focused in
            isFocused = focused
        }
    }
}

private struct ProviderLogo: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: 24, iconName: "play.rectangle")
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: 24, iconName: "play.rectangle")
                    @unknown default:
                        PlaceholderView(iconSize: 24, iconName: "play.rectangle")
                    }
                }
            } else {
                PlaceholderView(iconSize: 24, iconName: "play.rectangle")
            }
        }
        .background(AppTheme.surfaceSecondary)
        .clipped()
    }
}
