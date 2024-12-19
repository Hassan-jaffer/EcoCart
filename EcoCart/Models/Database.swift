import UIKit
import FirebaseFirestore
import FirebaseStorage

typealias ProfileCompletionHandler = (_ loadedPost: Profile?) -> Void

class Database {
    
    // Firestore reference
    static let db = Firestore.firestore()
    
    // Storage reference with custom URL
    static let StorageRef = FirebaseStorage.Storage.storage(url: "gs://ecocart-b76ad.appspot.com").reference()
    
    class Users {
        static let usersCollection = db.collection("users")
        static let serviceProvidersCollection = db.collection("serviceProviders")
        
        static var currentUser: DocumentReference? {
            guard let uid = User.uid else { return nil }
            return usersCollection.document(uid)
        }
        
        // Subscription access for users
        static subscript(uuid: String) -> DocumentReference {
            return Database.Users.usersCollection.document(uuid)
        }
        
        // Observe user changes with Firestore snapshot listener
        @discardableResult
        static func observeUser(user: String,
                              completionHandler: @escaping ProfileCompletionHandler = {(_) -> Void in ()}) -> ListenerRegistration {
            
            let listener = Database.Users[user].addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    completionHandler(nil)
                    return
                }
                
                guard let data = document.data() else {
                    completionHandler(nil)
                    return
                }
                
                let loadedProfile = Profile.loadProfile(dictionary: data)
                completionHandler(loadedProfile)
            }
            
            return listener
        }
        
        // Check user type and get reference
        static func getUserReference(for uid: String, completion: @escaping (DocumentReference?) -> Void) {
            // Check regular users first
            let userRef = usersCollection.document(uid)
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    completion(userRef)
                } else {
                    // Check service providers
                    let providerRef = serviceProvidersCollection.document(uid)
                    providerRef.getDocument { document, error in
                        if let document = document, document.exists {
                            completion(providerRef)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    class Storage {
        // Save image to Firebase Storage
        static func saveImage(image: UIImage) -> String? {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
            
            let imageUuid = UUID().uuidString
            let imageRef = StorageRef.child("images/\(imageUuid).jpg")
            
            let semaphore = DispatchSemaphore(value: 0)
            var success = false
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                defer { semaphore.signal() }
                
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    success = false
                } else {
                    success = true
                }
            }
            
            // Wait for upload to complete
            _ = semaphore.wait(timeout: .now() + 30)
            return success ? imageUuid : nil
        }
        
        // Load image from Firebase Storage
        static func loadImage(view: UIImageView, uuid: String) {
            let imageRef = StorageRef.child("images/\(uuid).jpg")
            
            imageRef.getData(maxSize: 104857666) { data, error in
                if let error = error {
                    print("Failed to download image: \(error.localizedDescription)")
                    return
                }
                
                if let imageData = data {
                    DispatchQueue.main.async {
                        view.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        // Get download URL for image
        static func getImageURL(uuid: String, completion: @escaping (URL?) -> Void) {
            let imageRef = StorageRef.child("images/\(uuid).jpg")
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url)
                }
            }
        }
    }
    
    // Prevent initialization
    private init() { }
}

// Extension to handle Listener cleanup
extension ListenerRegistration {
    func remove() {
        self.remove()
    }
}
