//
//  ViewController.swift
//  VatCalculator+
//
//  Created by Mustafa Altınsoy on 6.09.2025.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController,UITextFieldDelegate {
    //MARK:ADS
    private var bannerView: BannerView!
    @IBOutlet weak var supportStackView: UIStackView!
    
    //MARK:VARIABLES
    let appTitle: String = NSLocalizedString("vat_calculator_+", comment: "")
    let amountPlaceHolder: String = NSLocalizedString("enter_amount", comment: "")
    let specialRate: String = NSLocalizedString("special_rate", comment: "")
    let specilRatePlaceHolder: String = NSLocalizedString("enter_special_rate", comment: "")
    let sgControlTitles: [String] = [NSLocalizedString("add_vat", comment: ""), NSLocalizedString("deduct_vat", comment: "")]
    let transactionLabel: String = NSLocalizedString("transaction_amount", comment: "")
    let vatLabel: String = NSLocalizedString("vat_amount", comment: "")
    let lastResultLabel: String = NSLocalizedString("result", comment: "")
    let supportTitles: [String] = [ NSLocalizedString("contact_us", comment: ""), NSLocalizedString("privacy_policy", comment: "")]
    let calculateButtonTitle: String = NSLocalizedString("calculate", comment: "")
    var vatRates: [Double] = [0.0, 0.01, 0.1, 0.2, 0.0]
    var stringConstants: [String] = [NSLocalizedString("transaction_amount", comment: ""), NSLocalizedString("vat_amount", comment: ""), NSLocalizedString("result", comment: ""),]
    var sgIndex = 0
    let formatter = NumberFormatter()
    var vatResultCopy: String = ""
    var totalResultCopy: String = ""
    var selectedRateButton: UIButton?
    
    
    //MARK:IBOUTLES
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var specialRateLabel: UILabel!
    @IBOutlet weak var specialRateTextField: UITextField!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var vatAmountLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var clickedCopyButtonOneOutlet: UIButton!
    @IBOutlet weak var clickedCopyButtonTwoOutlet: UIButton!
    @IBOutlet weak var clickedCalculateButtonOutlet: UIButton!
    @IBOutlet weak var clickedOneRateButtonOutlet: UIButton!
    @IBOutlet weak var clickedTenRateButtonOutlet: UIButton!
    @IBOutlet weak var clickedTwentyRateButtonOutlet: UIButton!
    @IBOutlet weak var sgControlOutlet: UISegmentedControl!
    @IBOutlet weak var contactUsTitle: UIButton!
    @IBOutlet weak var privacyPolicyTitle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //IOS18 check about copy button icon change.
        if #available(iOS 18.0, *) {
            clickedCopyButtonOneOutlet.setImage(UIImage(systemName: "document.on.document.fill"), for: .normal)
            clickedCopyButtonTwoOutlet.setImage(UIImage(systemName: "document.on.document.fill"), for: .normal)
        } else {
            clickedCopyButtonOneOutlet.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
            clickedCopyButtonTwoOutlet.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        }

        
        //create banner
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-8295883188188812/3928571174"
        bannerView.rootViewController = self
        bannerView.load(Request())
        supportStackView.addArrangedSubview(bannerView)
        
        amountTextField.delegate = self
        appTitleLabel.text = appTitle
        amountTextField.placeholder = amountPlaceHolder
        specialRateLabel.text = specialRate
        sgControlOutlet.setTitle(sgControlTitles[0], forSegmentAt: 0)
        sgControlOutlet.setTitle(sgControlTitles[1], forSegmentAt: 1)
        contactUsTitle.setTitle(supportTitles[0], for: .normal)
        privacyPolicyTitle.setTitle(supportTitles[1], for: .normal)
        transactionAmountLabel.text = transactionLabel
        vatAmountLabel.text = vatLabel
        resultLabel.text = lastResultLabel
        clickedCalculateButtonOutlet.setTitle(calculateButtonTitle, for: .normal)
        
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale.current
        
    }
    
    //MARK:IBACTIONS
    @IBAction func clickedRateButton(_ sender: UIButton) {
        if sender.tag != 4 {
            specialRateTextField.text = ""
            vatRates[4] = 0.0
        }
        selectedRateButton = sender
        if amountTextField.text == "" {
            amountTextField.attributedPlaceholder = NSAttributedString(string: "please enter amount!!!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
        } else {
            let specialRateString = specialRateTextField.text ?? ""
            
            
            if let specialRate = Int(specialRateString) {
                vatRates[4] = Double(specialRate) / 100.0   // 90 → 0.90
            }
            
            
            
            for i in 1...5 {
                if let button = self.view.viewWithTag(i) as? UIButton {
                    button.backgroundColor = .systemGray3
                }
            }
            
            sender.backgroundColor = .systemRed
            
            let amount = amountTextField.text ?? ""
            let vatRate = vatRates[sender.tag]
            
            switch sgIndex {
            case 0:
                if let amount = Double(amount) {
                    updateUI(amount, vatRate, sgIndex)
                }
            case 1:
                if let amount = Double(amount) {
                    updateUI(amount, vatRate, sgIndex)
                }
            default:
                return
            }
            
            view.endEditing(true)
        }
    }
    
    @IBAction func calculateSegmentedControl(_ sender: UISegmentedControl) {
        sgIndex = sender.selectedSegmentIndex
        view.endEditing(true)
        
        if let button = selectedRateButton {
            let amount = amountTextField.text ?? ""
            let vatRate = vatRates[button.tag]
            
            if let amount = Double(amount) {
                updateUI(amount, vatRate, sgIndex)
            }
        }
    }
    
    @IBAction func clickedContactUsButton(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "mailto:mltnsy@icloud.com?subject=Feedback")! as URL,
                                  options: [:], completionHandler: nil)
    }
    
    @IBAction func clickedCopyButton(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            UIPasteboard.general.string = vatResultCopy
        case 2:
            UIPasteboard.general.string = totalResultCopy
        default:
            return
        }
    }
    
    @IBAction func clickedPrivacyPolicyButton(_ sender: UIButton) {
        if let url = URL(string: "https://kdv-hesaplama-mltnsy.web.app/privacy.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK:FUNCTIONS
    func updateUI(_ amount: Double,_ rate: Double,_ sgIndex: Int) {
        let vatResult: Double
        let totalResult: Double
        
        if sgIndex == 0 {
            // Add VAT
            totalResult = amount * (1 + rate)
            vatResult = totalResult - amount
        } else {
            // Deduct VAT
            let net = amount / (1 + rate)
            vatResult = amount - net
            totalResult = net
        }
        
        if let transactionAmountString = formatter.string(for: amount) {
            transactionAmountLabel.text = stringConstants[0] + transactionAmountString
        }
        
        if let vatAmountString = formatter.string(for: vatResult) {
            vatAmountLabel.text = stringConstants[1] + vatAmountString
            vatResultCopy = vatAmountString
        }
        
        if let resultString = formatter.string(for: totalResult) {
            resultLabel.text = stringConstants[2] + resultString
            totalResultCopy = resultString
        }
    }
}

//MARK:EXTENSIONS
extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

