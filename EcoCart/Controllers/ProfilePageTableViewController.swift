import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfilePageTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UIButton!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    private var profileListener: ListenerRegistration?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDarkMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profileListener?.remove()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        self.navigationItem.hidesBackButton = true
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 156/255, green: 230/255, blue: 157/255, alpha: 1.0)
        self.tabBarController?.tabBar.standardAppearance = appearance
        self.tabBarController?.tabBar.tintColor = .black
    }
    
    private func setupDarkMode() {
        ThemeManager.shared.applyTheme()
        if let savedState = UserDefaults.standard.value(forKey: "darkModeState") as? Bool {
            darkModeSwitch.isOn = savedState
        } else {
            darkModeSwitch.isOn = ThemeManager.shared.isDarkMode
        }
    }
    
    // MARK: - Profile Management
    
    func updateProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        profileListener?.remove()
        profileListener = Firestore.firestore().collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            self.updateProfile(with: data)
        }
    }
    
    func updateProfile(with data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let imageData = data["profileImage"] as? Data {
                self.profileImageView.image = UIImage(data: imageData)
            }
            
            if let firstName = data["firstName"] as? String,
               let lastName = data["lastName"] as? String {
                let name = firstName + " " + lastName
                self.profileName.setTitle(name, for: .normal)
            }
            
            if let email = data["email"] as? String {
                self.profileEmail.text = email
            }
        }
    }
    
    // MARK: - Actions
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "user_uid_key")
            
            let storyboard = UIStoryboard(name: "LogInPage", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "login") as? LogInTableViewController {
                let navigationController = UINavigationController(rootViewController: loginVC)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
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
        alert.textFields![0].text = self.profileName.titleLabel?.text
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields?[0].text,
                  !newName.isEmpty,
                  let uid = Auth.auth().currentUser?.uid else { return }
            
            Firestore.firestore().collection("users").document(uid).updateData([
                "name": newName
            ]) { error in
                if let error = error {
                    print("Error updating name: \(error.localizedDescription)")
                    return
                }
                self.profileName.setTitle(newName, for: .normal)
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
            message: "Are you sure you want to change your photo?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self?.present(imagePicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeState")
        ThemeManager.shared.isDarkMode = sender.isOn
        ThemeManager.shared.applyTheme()
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            print("No image selected")
            return
        }
        
        DispatchQueue.main.async {
            self.profileImageView.image = selectedImage
        }
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).updateData([
            "profileImage": imageData
        ]) { error in
            if let error = error {
                print("Error updating profile image in Firestore: \(error.localizedDescription)")
                return
            }
            print("Profile image updated successfully in Firestore.")
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.reuseIdentifier == "myOrdersCell" {
                navigateToStoryboard(named: "MyOrders", withIdentifier: "MyOrdersViewController")
            } else if cell.reuseIdentifier == "storeManagementCell" {
                navigateToStoryboard(named: "Profile", withIdentifier: "StoreManagementViewController")
            }
        }
    }
    
    private func navigateToStoryboard(named: String, withIdentifier storyboardID: String) {
        let storyboard = UIStoryboard(name: named, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
