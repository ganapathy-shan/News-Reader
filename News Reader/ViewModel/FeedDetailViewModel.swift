//
//  FeedDetailViewModel.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import SDWebImage

class FeedDetailViewModel {
    private let feedItem: FeedItem

    init(feedItem: FeedItem) {
        self.feedItem = feedItem
    }

    // Expose relevant properties of `FeedItem` for the view
    var title: String {
        return feedItem.title
    }

    var description: String? {
        return feedItem.description
    }

    var imageUrl: String? {
        return feedItem.imageUrl
    }

    var publishedDate: String {
        return feedItem.publishDate
    }

    var source: String? {
        return feedItem.source
    }

    var articleUrl: URL? {
        return URL(string: feedItem.link)
    }

    var categories: [String]? {
        return feedItem.categories
    }

    // Function to load and cache the image
    func loadImage(into imageView: UIImageView) {
        guard let imageUrlString = imageUrl, let url = URL(string: imageUrlString) else {
            imageView.image = nil
            return
        }
        
        // Use SDWebImage to download and cache image to both memory and disk
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: nil)
    }
}

