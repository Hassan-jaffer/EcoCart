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
            setTheme(for: .dark)
        } else {
            // Set light mode
            setTheme(for: .light)
        }
    }
    
    private func setTheme(for style: UIUserInterfaceStyle) {
        // Get the current window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        // Apply the theme to all windows in the window scene
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = style
        }
    }
}
