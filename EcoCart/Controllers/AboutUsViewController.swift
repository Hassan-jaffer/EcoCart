//
//  AboutUsViewController.swift
//  WeSide
//
//  Created by Yousif Isa Shamtoot on 18/04/2023.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var aboutUsStatement: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutUsStatement.text = aboutUsStatementTemp
        
        let attributedText = NSMutableAttributedString(string: aboutUsStatementTemp)
                let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
                
                let aboutUsRange = (aboutUsStatementTemp as NSString).range(of: "ABOUT US")
                attributedText.addAttributes(boldAttributes, range: aboutUsRange)
                
                let whoWeAreRange = (aboutUsStatementTemp as NSString).range(of: "WHO WE ARE")
                attributedText.addAttributes(boldAttributes, range: whoWeAreRange)
                
                let whatWeDoRange = (aboutUsStatementTemp as NSString).range(of: "WHAT WE DO")
                attributedText.addAttributes(boldAttributes, range: whatWeDoRange)
                
                let ourCommitmentRange = (aboutUsStatementTemp as NSString).range(of: "OUR COMMITMENT TO CUSTOMER SATISFACTION")
                attributedText.addAttributes(boldAttributes, range: ourCommitmentRange)
                
                aboutUsStatement.attributedText = attributedText
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
var aboutUsStatementTemp: String = """

ABOUT US

At EcoCart, we believe in building a sustainable future, one eco-friendly product at a time. Our app is designed to empower individuals to make environmentally conscious choices by providing access to a wide range of eco-friendly products. From reusable household items to sustainably sourced personal care products, EcoCart is your go-to platform for shopping responsibly.

Our mission is simple: to make it easy and accessible for everyone to reduce their environmental impact without compromising on quality or style. We carefully curate products from trusted brands that prioritize sustainability, ethical practices, and reducing carbon footprints.

Whether you’re looking to live a zero-waste lifestyle or just take small steps toward a greener planet, EcoCart is here to support your journey. Together, we can create a cleaner, healthier, and more sustainable world for generations to come. Thank you for choosing EcoCart – where every product tells a story of care for our planet. 

We value your feedback and suggestions, as they help us improve our services and better meet your needs. If you have any questions or feedback, please don't hesitate to contact us at EcoCart@gmail.com.🌿💚


"""
