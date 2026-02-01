import SwiftUI

struct TrendingView: View {
    @StateObject private var viewModel = TrendingViewModel()

    private let horizontalPadding: CGFloat = 48

    var body: some View {
        NavigationStack {
            ZStack {
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
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Global Trending")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(AppTheme.text)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 16)

                            if !viewModel.trending.isEmpty {
                                PosterRow(title: "Trending Now", items: Array(viewModel.trending.prefix(12)), horizontalPadding: horizontalPadding)

                                TrendingGrid(items: viewModel.trending)
                                    .padding(.horizontal, horizontalPadding)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .task { await viewModel.loadIfNeeded() }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TrendingGrid: View {
    let items: [MediaItem]

    private let columns = [GridItem(.adaptive(minimum: 180), spacing: 24)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 28) {
            ForEach(items) { item in
                PosterCard(media: item)
            }
        }
    }
}

#Preview {
    TrendingView()
}
