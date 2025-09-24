//
//  PostViewController.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//
import UIKit
import ParseSwift
import PhotosUI

class PostViewController: UIViewController {
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Post Photo"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(postTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        // Style caption text field
        captionTextField.backgroundColor = .systemGray5
        captionTextField.layer.cornerRadius = 8
        captionTextField.textColor = .label
        captionTextField.placeholder = "What's happening?"
        
        // Add padding to text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: captionTextField.frame.height))
        captionTextField.leftView = paddingView
        captionTextField.leftViewMode = .always
        
        // Style image view
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        // Style select photo button
        selectPhotoButton.backgroundColor = .systemBlue
        selectPhotoButton.setTitleColor(.white, for: .normal)
        selectPhotoButton.layer.cornerRadius = 8
        selectPhotoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func postTapped() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            showAlert(title: "Error", message: "Please select a photo")
            return
        }
        
        Task {
            do {
                // Create and save the image file first
                let imageFile = ParseFile(name: "image.jpg", data: imageData)
                let savedImageFile = try await imageFile.save()
                
                // Create the post
                var post = Post()
                post.author = User.current
                post.caption = captionTextField.text
                post.image = savedImageFile
                post.location = "San Francisco, SOMA" // Default location for demo
                
                // Save the post
                let savedPost = try await post.save()
                
                await MainActor.run {
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.selectedImage = image
                    self?.imageView.image = image
                    self?.selectPhotoButton.setTitle("Change Photo", for: .normal)
                }
            }
        }
    }
}
