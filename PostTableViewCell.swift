//
//  PostTableViewCell.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//
import UIKit
import ParseSwift

class PostTableViewCell: UITableViewCell {
    
    private let userLabel = UILabel()
    private let locationLabel = UILabel()
    private let postImageView = UIImageView()
    private let captionLabel = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none
        
        // Container view
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 0
        contentView.addSubview(containerView)
        
        // User label
        userLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userLabel.textColor = .white
        containerView.addSubview(userLabel)
        
        // Location label
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = .systemGray
        containerView.addSubview(locationLabel)
        
        // Post image view
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 8
        postImageView.backgroundColor = .systemGray6
        containerView.addSubview(postImageView)
        
        // Caption label
        captionLabel.font = UIFont.systemFont(ofSize: 14)
        captionLabel.textColor = .white
        captionLabel.numberOfLines = 0
        containerView.addSubview(captionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            userLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            userLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            userLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            locationLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 2),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            postImageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            postImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            postImageView.heightAnchor.constraint(equalToConstant: 350),
            
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            captionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            captionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            captionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with post: Post) {
        userLabel.text = post.author?.username ?? "Unknown User"
        
        // Format location and time
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let timeString = formatter.string(from: post.createdAt ?? Date())
        locationLabel.text = "\(post.location ?? "San Francisco, SOMA"), \(timeString) late"
        
        captionLabel.text = post.caption ?? ""
        
        // Load image using ParseSwift async/await
        if let imageFile = post.image {
            Task {
                do {
                    let fetchedFile = try await imageFile.fetch()
                    if let data = fetchedFile.data {
                        let image = UIImage(data: data)
                        
                        await MainActor.run {
                            self.postImageView.image = image
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                }
            }
        }
    }
}
