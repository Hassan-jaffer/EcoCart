import UIKit

class ProfilePageTableViewController: UITableViewController {
    
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply the theme when the view loads
        ThemeManager.shared.applyTheme()
        
        // Restore the saved switch state from UserDefaults
        if let savedState = UserDefaults.standard.value(forKey: "darkModeState") as? Bool {
            // Update the switch's state based on the saved value
            darkModeSwitch.isOn = savedState
        } else {
            // If no saved state exists, default to dark mode or light mode based on user preferences
            darkModeSwitch.isOn = ThemeManager.shared.isDarkMode
        }
    }

    
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
        // Save the switch state to UserDefaults
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeState")
        
        // Toggle dark mode based on the switch state
        ThemeManager.shared.isDarkMode = sender.isOn
        
        // Apply the new theme
        ThemeManager.shared.applyTheme()
        
        
    }

}
