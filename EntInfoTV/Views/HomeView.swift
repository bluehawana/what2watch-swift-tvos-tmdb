import Combine
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    private let horizontalPadding: CGFloat = 48
    private let sectionSpacing: CGFloat = 32

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                AppTheme.background
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingStateView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage) {
                        Task { await viewModel.reload() }
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: sectionSpacing) {
                            if !viewModel.heroItems.isEmpty {
                                HeroCarousel(items: viewModel.heroItems)
                            }

                            PosterRow(title: "Top TV", items: viewModel.topTV, horizontalPadding: horizontalPadding)
                            PosterRow(title: "Highly Recommend", items: viewModel.highlyRecommend, horizontalPadding: horizontalPadding)
                            PosterRow(title: "Trending Now", items: viewModel.trendingNow, horizontalPadding: horizontalPadding)
                            PosterRow(title: "Top Movies", items: viewModel.topMovies, horizontalPadding: horizontalPadding)
                        }
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }

                AppTitleView()
                    .padding(.leading, horizontalPadding)
                    .padding(.top, 24)
            }
            .navigationBarHidden(true)
            .task { await viewModel.loadIfNeeded() }
        }
        .preferredColorScheme(.dark)
    }
}

private struct AppTitleView: View {
    var body: some View {
        Text("EntInfo")
            .font(.system(size: 34, weight: .heavy))
            .foregroundColor(AppTheme.primary)
            .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
    }
}

private struct LoadingStateView: View {
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

private struct ErrorStateView: View {
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

private struct HeroCarousel: View {
    let items: [MediaItem]

    @State private var selection = 0
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        let heroHeight = UIScreen.main.bounds.height * 0.65

        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink {
                        MediaDetailView(media: item)
                    } label: {
                        HeroSlide(item: item, index: index + 1)
                    }
                    .buttonStyle(.plain)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: heroHeight)
            .clipped()

            HStack(spacing: 6) {
                ForEach(items.indices, id: \ .self) { index in
                    Capsule()
                        .fill(index == selection ? Color.white : Color.white.opacity(0.35))
                        .frame(width: index == selection ? 18 : 6, height: 6)
                }
            }
            .padding(.bottom, 48)
        }
        .onReceive(timer) { _ in
            guard items.count > 1 else { return }
            selection = (selection + 1) % items.count
        }
    }
}

private struct HeroSlide: View {
    let item: MediaItem
    let index: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeroImage(url: TMDBService.shared.imageURL(path: item.backdropPath ?? item.posterPath, large: true))

            LinearGradient(
                colors: [
                    .clear,
                    AppTheme.background.opacity(0.4),
                    AppTheme.background.opacity(0.85),
                    AppTheme.background,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 12) {
                Text(item.titleText)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(AppTheme.text)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Text(item.mediaTypeLabel)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 4, height: 4)
                    Text("Trending #\(index)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("Included with Premium")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.leading, 48)
            .padding(.bottom, 32)
        }
    }
}

private struct HeroImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: 60)
                    @unknown default:
                        PlaceholderView(iconSize: 60)
                    }
                }
            } else {
                PlaceholderView(iconSize: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.surfaceSecondary)
        .clipped()
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

private struct PosterRow: View {
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
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct PosterCard: View {
    let media: MediaItem
    @State private var isFocused = false

    private let cardWidth: CGFloat = 180
    private let cardHeight: CGFloat = 270

    var body: some View {
        NavigationLink {
            MediaDetailView(media: media)
        } label: {
            ZStack {
                PosterImage(url: TMDBService.shared.imageURL(path: media.posterPath))
            }
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

private struct PosterImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        PlaceholderView(iconSize: 32)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        PlaceholderView(iconSize: 32)
                    @unknown default:
                        PlaceholderView(iconSize: 32)
                    }
                }
            } else {
                PlaceholderView(iconSize: 32)
            }
        }
        .background(AppTheme.surfaceSecondary)
        .clipped()
    }
}

#Preview {
    HomeView()
}
