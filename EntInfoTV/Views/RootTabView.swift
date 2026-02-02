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
        .overlay(alignment: .topLeading) {
            BrandWordmark()
                .padding(.leading, 56)
                .padding(.top, 12)
                .allowsHitTesting(false)
        }
    }
}
#Preview {
    RootTabView()
}
