# EntInfoTV

A tvOS app that surfaces trending movies and series across the streaming landscape, inspired by the browse experience of Apple TV+ and Prime Video but not limited to any single channel.

## Why this app

Finding something to watch usually means hopping across multiple services, scrolling endlessly, and still not knowing what is actually trending. EntInfoTV fixes that by putting the TMDB trend signal front and center, so you can discover what the world is watching without being locked into one provider.

## How it helps you kill your weekend time

- Cuts decision fatigue by curating top picks, trending titles, and high‑rated recommendations.
- Gives you a fast, couch‑friendly experience on Apple TV.
- Shows where a title can be watched so you can jump in quickly and actually enjoy your weekend.

## Features

- Home, Movies, Series, Global, and Search tabs
- Apple TV‑style hero carousel and poster rows
- Detail pages with overview, rating, and watch providers
- TMDB‑powered trends and discovery

## Setup

1) Add your TMDB token to a local env file (not committed):

```
TMDB_API_KEY=YOUR_TMDB_V4_TOKEN
```

2) Build and run on tvOS simulator (26.1):

```
xcodebuild build -project EntInfoTV.xcodeproj -scheme EntInfoTV -destination 'platform=tvOS Simulator,OS=26.1,name=Apple TV'
```

Or open `EntInfoTV.xcodeproj` in Xcode and run the tvOS simulator.

## Credentials and safety

- `.env` is gitignored and must not be committed.
- Never push API keys or tokens to git.

## Notes

- Watch‑provider links come from TMDB’s watch‑providers endpoint.
- This product uses the TMDB API but is not endorsed or certified by TMDB.
