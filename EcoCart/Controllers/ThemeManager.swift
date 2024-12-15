import UIKit

class ThemeManager {
    
    static let shared = ThemeManager() // Singleton instance
    
    // Property to store the dark mode preference
    var isDarkMode: Bool {
        get {
            // Get the dark mode preference from UserDefaults (persistent storage)
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }
        set {
            // Save the dark mode preference to UserDefaults
            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
        }
    }
    
    private init() { }
    
    // Method to apply the current theme (dark or light mode) globally
    func applyTheme() {
        // Check if dark mode is enabled
        if isDarkMode {
            // Set dark mode
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            // Set light mode
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
    }
}
