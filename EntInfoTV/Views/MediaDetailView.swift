import SwiftUI

struct MediaDetailView: View {
    let media: MediaItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(media: media)

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

private struct PlaceholderView: View {
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            AppTheme.surfaceSecondary
            Image(systemName: "film")
                .font(.system(size: iconSize))
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}
