//
//  FeedCell.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import UIKit
import SDWebImage

class FeedCell: UITableViewCell {
    
    private var articleURL : String? = nil
    private var contentSynthesizer = ContentSynthesizer()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.white
        }
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
        }
        return label
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let speakerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "speaker.3.fill"), for: .normal) // Use SF Symbols for better styling
        button.tintColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.systemGray : UIColor(red: 0.63, green: 0.84, blue: 0.80, alpha: 1.0)
        }
        button.layer.cornerRadius = 15 // Make the button circular
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(playSynthesis), for: .touchUpInside)
        return button
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.systemGroupedBackground
        }
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(speakerButton)  // Add speaker button below the image

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            // Thumbnail Image View
            thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            thumbnailImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),

            // Speaker Button below the image
            speakerButton.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            speakerButton.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            speakerButton.widthAnchor.constraint(equalToConstant: 30),
            speakerButton.heightAnchor.constraint(equalToConstant: 30),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: thumbnailImageView.rightAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leftAnchor.constraint(equalTo: thumbnailImageView.rightAnchor, constant: 12),
            descriptionLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with feedItem: FeedItem) {
        articleURL = feedItem.link
        titleLabel.text = feedItem.title
        descriptionLabel.text = feedItem.description
        if let imageUrl = feedItem.imageUrl, let url = URL(string: imageUrl) {
            thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "PlaceholderImage"))
        } else {
            thumbnailImageView.image = UIImage(named: "PlaceholderImage")
        }
        speakerButton.addTarget(self, action: #selector(playSynthesis), for: .touchUpInside)
    }
    
    @objc private func playSynthesis() {
            guard let articleURL = articleURL else { return }

            contentSynthesizer.synthesizeContent(from: articleURL) { result in
                switch result {
                case .success:
                    print("Speech synthesis started successfully.")
                case .failure(let error):
                    print("Error in content synthesis: \(error.localizedDescription)")
                }
            }
    }
}

