//
//  FeedViewController'.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }
    
    private func setupUI() {
        title = "BeReal."
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .black
        
        // Add profile button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.2"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        // Add logout button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // Add post button
        let postButton = UIButton(type: .system)
        postButton.backgroundColor = .systemBlue
        postButton.setTitle("Post a Photo", for: .normal)
        postButton.setTitleColor(.white, for: .normal)
        postButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        postButton.layer.cornerRadius = 25
        postButton.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        postButton.center.x = view.center.x
        postButton.frame.origin.y = view.safeAreaInsets.top + 70
        postButton.addTarget(self, action: #selector(postPhotoTapped), for: .touchUpInside)
        
        view.addSubview(postButton)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup refresh control
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Register custom cell
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
    }
    
    @objc private func profileTapped() {
        // Placeholder for profile functionality
        let alert = UIAlertController(title: "Profile", message: "Profile feature coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func logoutTapped() {
        Task {
            do {
                try await User.logout()
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let delegate = windowScene.delegate as? SceneDelegate {
                        delegate.window?.rootViewController = loginViewController
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Logout Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func postPhotoTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController")
        let navController = UINavigationController(rootViewController: postViewController)
        present(navController, animated: true)
    }
    
    @objc private func refreshPosts() {
        loadPosts()
    }
    
    private func loadPosts() {
        Task {
            do {
                let query = Post.query()
                    .include("author")
                    .order([.descending("createdAt")])
                    .limit(20)
                
                let posts = try await query.find()
                
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.posts = posts
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500 // Fixed height for posts
    }
}
