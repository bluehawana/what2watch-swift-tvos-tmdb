import SwiftUI

struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
            Text("Loading content...")
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Unable to load content")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(AppTheme.text)
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 640)
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

struct PlaceholderView: View {
    let iconSize: CGFloat
    let iconName: String

    init(iconSize: CGFloat, iconName: String = "film") {
        self.iconSize = iconSize
        self.iconName = iconName
    }

    var body: some View {
        ZStack {
            AppTheme.surfaceSecondary
            Image(systemName: iconName)
                .font(.system(size: iconSize))
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}

struct PosterImage: View {
    let url: URL?
    let iconSize: CGFloat

    init(url: URL?, iconSize: CGFloat = 32) {
        self.url = url
        self.iconSize = iconSize
    }

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: iconSize)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: iconSize)
                    @unknown default:
                        PlaceholderView(iconSize: iconSize)
                    }
                }
            } else {
                PlaceholderView(iconSize: iconSize)
            }
        }
        .background(AppTheme.surfaceSecondary)
        .clipped()
    }
}

struct PosterCard: View {
    let media: MediaItem
    @State private var isFocused = false

    private let cardWidth: CGFloat = 180
    private let cardHeight: CGFloat = 270

    var body: some View {
        NavigationLink {
            MediaDetailView(media: media)
        } label: {
            PosterImage(url: TMDBService.shared.imageURL(path: media.posterPath))
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isFocused ? AppTheme.primary : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isFocused ? 1.08 : 1.0)
                .shadow(color: .black.opacity(isFocused ? 0.6 : 0.3), radius: isFocused ? 16 : 8, x: 0, y: 6)
                .animation(.easeOut(duration: 0.2), value: isFocused)
        }
        .buttonStyle(.plain)
        .focusable(true) { focused in
            isFocused = focused
        }
    }
}

struct PosterRow: View {
    let title: String
    let items: [MediaItem]
    let horizontalPadding: CGFloat

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, horizontalPadding)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 20) {
                        ForEach(items) { item in
                            PosterCard(media: item)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .focusSection()
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct BrandWordmark: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.primary)
                Text("EI")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            .frame(width: 26, height: 22)

            Text("EntInfo")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.surfaceSecondary.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .accessibilityLabel("EntInfo")
    }
}

private struct BrandToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandWordmark()
            }
        }
    }
}

extension View {
    func brandToolbar() -> some View {
        modifier(BrandToolbarModifier())
    }
}
