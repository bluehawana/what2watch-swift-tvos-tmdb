import SwiftUI

struct TVView: View {
    @StateObject private var viewModel = TVViewModel()

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
                            Text("TV Series")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(AppTheme.text)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 16)

                            PosterRow(title: "Popular Series", items: viewModel.popular, horizontalPadding: horizontalPadding)
                            PosterRow(title: "Top Rated", items: viewModel.topRated, horizontalPadding: horizontalPadding)
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

#Preview {
    TVView()
}
