//
//  ViewController.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//
import UIKit
import ParseSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Style text fields
        [usernameField, passwordField].forEach { field in
            field?.backgroundColor = .systemGray4
            field?.layer.cornerRadius = 8
            field?.borderStyle = .none
            field?.textColor = .label
            
            // Add padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: field?.frame.height ?? 0))
            field?.leftView = paddingView
            field?.leftViewMode = .always
        }
        
        // Style buttons
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        signUpButton.backgroundColor = .clear
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        signUpButton.layer.cornerRadius = 8
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    @IBAction func onLoginTapped(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter username and password")
            return
        }
        
        Task {
            do {
                let user = try await User.login(username: username, password: password)
                await MainActor.run {
                    self.navigateToFeed()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Login Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func onSignUpTapped(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter username and password")
            return
        }
        
        var user = User()
        user.username = username
        user.password = password
        
        Task {
            do {
                let signedUpUser = try await user.signup()
                await MainActor.run {
                    self.navigateToFeed()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Sign Up Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToFeed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let feedViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewController")
        let navController = UINavigationController(rootViewController: feedViewController)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate {
            delegate.window?.rootViewController = navController
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
