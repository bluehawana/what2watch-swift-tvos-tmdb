import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()

    private let horizontalPadding: CGFloat = 48
    private let sectionSpacing: CGFloat = 32

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
                        LazyVStack(alignment: .leading, spacing: sectionSpacing) {
                            Text("Movies")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(AppTheme.text)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 16)

                            PosterRow(title: "Popular Movies", items: viewModel.popular, horizontalPadding: horizontalPadding)
                            PosterRow(title: "Top Rated", items: viewModel.topRated, horizontalPadding: horizontalPadding)
                        }
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .task { await viewModel.loadIfNeeded() }
        }
        .brandToolbar()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MoviesView()
}
