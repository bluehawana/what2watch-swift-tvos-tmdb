import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            MoviesView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }

            TVView()
                .tabItem {
                    Label("Series", systemImage: "tv")
                }

            TrendingView()
                .tabItem {
                    Label("Global", systemImage: "globe")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .tint(AppTheme.primary)
    }
}
#Preview {
    RootTabView()
}
