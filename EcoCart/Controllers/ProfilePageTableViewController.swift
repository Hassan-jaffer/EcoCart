//
//  ProfilePageTableViewController.swift
//  WeSide
//
//  Created by Yousif Isa Shamtoot on 31/03/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfilePageTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var profileName: UIButton!
    @IBOutlet weak var profileEmil: UILabel!
    
    private var profileListener: ListenerRegistration?
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "user_uid_key")
            performSegue(withIdentifier: "backToHome", sender: nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    @IBAction func profileNameEdit(_ sender: Any) {
        let alert = UIAlertController(
            title: "Username Change",
            message: "Enter your new username",
            preferredStyle: .alert
        )
        alert.addTextField()
        alert.textFields![0].text = self.profileName.titleLabel!.text
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields![0].text,
                  !newName.isEmpty,
                  let uid = User.uid else { return }
            
            // Update name in Firestore
            Database.Users.getUserReference(for: uid) { userRef in
                guard let userRef = userRef else { return }
                userRef.updateData([
                    "name": newName
                ]) { error in
                    if let error = error {
                        print("Error updating name: \(error.localizedDescription)")
                        return
                    }
                    self.profileName.setTitle(newName, for: .normal)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Are you sure you want to log out?",
            message: "",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.signOut()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func profileImageEdit(_ sender: Any) {
        let alert = UIAlertController(
            title: "Profile Photo Change",
            message: "Are you sure you want change your photo?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true // Set to true to enable editing
            self?.present(imagePicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        // Access the selected image (edited or original)
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            print("No image selected")
            return
        }
        
        // Update the ProfileImageView with the selected image
        DispatchQueue.main.async {
            self.ProfileImageView.image = selectedImage
        }
        
        // Save the image and update the profile in the database
        if let imageUuid = Database.Storage.saveImage(image: selectedImage) {
            guard let uid = User.uid else { return }
            
            Database.Users.getUserReference(for: uid) { [weak self] userRef in
                guard let userRef = userRef else { return }
                userRef.updateData([
                    "image": imageUuid
                ]) { error in
                    if let error = error {
                        print("Error updating profile image in database: \(error.localizedDescription)")
                        return
                    }
                    print("Profile image updated successfully in database.")
                }
            }
        } else {
            print("Failed to save image to database.")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profileListener?.remove()
    }
    
    private func setupUI() {
        ProfileImageView.clipsToBounds = false
        ProfileImageView.layer.masksToBounds = true
        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.height / 2
        self.navigationItem.hidesBackButton = true
        
        // Reset tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 156/255, green: 230/255, blue: 157/255, alpha: 1.0)
        self.tabBarController?.tabBar.standardAppearance = appearance
        
        self.tabBarController?.tabBar.tintColor = .black
        
    }
    
    func updateProfile() {
        guard let uid = User.uid else { return }
        
        // Remove any existing listener
        profileListener?.remove()
        
        // Set up new listener
        profileListener = Database.Users.observeUser(user: uid) { [weak self] profile in
            guard let self = self, let profile = profile else { return }
            self.updateProfile(profile: profile)
        }
    }
    
    func updateProfile(profile: Profile) {
        print("Updating profile with: \(profile)")
        DispatchQueue.main.async {
            Database.Storage.loadImage(view: self.ProfileImageView, uuid: profile.image)
            self.profileName.setTitle(profile.name, for: .normal)
            self.profileEmil.text = profile.email
        }
    }

}
