import UIKit

class ProfilePageTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply the theme when the view loads
        ThemeManager.shared.applyTheme()
    }
    
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
        // Toggle dark mode based on the switch state
        ThemeManager.shared.isDarkMode = sender.isOn
        
        // Apply the new theme
        ThemeManager.shared.applyTheme()
        
        // Optionally, show an alert confirming the mode change
        let modeText = sender.isOn ? "Dark Mode Enabled" : "Light Mode Enabled"
        let alert = UIAlertController(title: "Theme Changed", message: modeText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
