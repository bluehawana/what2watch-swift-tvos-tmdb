import SwiftUI

struct MediaDetailView: View {
    let media: MediaItem
    @StateObject private var viewModel = MediaDetailViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(media: media)

                watchProvidersSection

                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                    Text(media.overview.isEmpty ? "No overview available." : media.overview)
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 48)

                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .top)
        .task { await viewModel.loadIfNeeded(media: media) }
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

                    Text(media.mediaTypeLabel)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

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
