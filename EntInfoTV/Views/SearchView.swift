import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private let horizontalPadding: CGFloat = 48

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Search")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(AppTheme.text)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, 16)

                        searchBar
                            .padding(.horizontal, horizontalPadding)

                        if viewModel.isLoading {
                            LoadingStateView()
                                .frame(maxWidth: .infinity, minHeight: 240)
                        } else if let errorMessage = viewModel.errorMessage {
                            ErrorStateView(message: errorMessage) {
                                Task { await viewModel.search(query: query) }
                            }
                            .frame(maxWidth: .infinity, minHeight: 240)
                        } else if viewModel.results.isEmpty {
                            Text("Search for movies or TV shows")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, horizontalPadding)
                        } else {
                            SearchResultsGrid(items: viewModel.results)
                                .padding(.horizontal, horizontalPadding)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)

            TextField("Search movies and TV", text: $query)
                .textFieldStyle(.plain)
                .foregroundColor(AppTheme.text)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.search(query: query) }
                }

            Button("Search") {
                Task { await viewModel.search(query: query) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(AppTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SearchResultsGrid: View {
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
    SearchView()
}
