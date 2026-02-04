# News Reader - Project Guide

## Overview
News Reader is an iOS app that fetches and displays news articles, supports
pagination, caches content locally, summarizes article content, and can read
summaries aloud using AWS Polly.

## Architecture
- MVVM with Clean Architecture style layering
- Coordinator pattern for navigation

## Key Directories
- `News Reader/Coordinators/`: App flow and navigation.
- `News Reader/Models/`: Data models and Core Data entities.
- `News Reader/Protocols/`: Core protocols for services and view models.
- `News Reader/Service/`: Networking, caching, speech, and summarization.
- `News Reader/View/`: Reusable UI views (e.g., table cells).
- `News Reader/ViewController/`: Screens and user interaction.
- `News Reader/ViewModel/`: View models for screen logic.
- `News Reader/News_Reader.xcdatamodeld/`: Core Data schema.

## Core Components
- `FeedViewController`: Displays the list of articles and handles scrolling.
- `FeedViewModel`: Orchestrates fetching, pagination, caching, and UI updates.
- `FeedCell`: Shows an article with image, summary, and text-to-speech action.
- `FeedService`: Fetches articles from the remote API.
- `CacheManager` + `CoreDataManager`: Store and retrieve cached articles.
- `WebContentExtractor`: Extracts clean article content from a URL.
- `FoundationModelSummarizer`: Summarizes content on-device with Apple Foundation Models.
- `OpenAPISummarizer`: Optional OpenAI-based summarizer using `OpenAPIKey`.
- `ContentSynthesizer`: Converts summary text to speech via AWS Polly.
- `SummaryCacheManager`: Caches summarized content.
- `AppCoordinator` / `FeedCoordinator`: Navigation flow.

## Data Flow (High Level)
1. `FeedViewController` asks `FeedViewModel` to load articles.
2. `FeedViewModel` fetches from `FeedService`; falls back to cached data.
3. Article content is extracted and summarized (Apple Foundation Models by default, OpenAI optional), then cached.
4. UI updates with new items; images load via SDWebImage.
5. TTS uses `ContentSynthesizer` with AWS Polly when the user taps the speaker.

## Setup Notes
- `config.plist` is required with keys:
  - `OpenAPIKey`
  - `NewsAPIKey`
  - `AWSPoolID`
- Uses CocoaPods (see `Podfile`).
