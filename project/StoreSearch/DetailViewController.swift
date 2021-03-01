//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/27/21.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {

    // outlets
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded{ // after searchResult has changed, we call the updateUI() method to set the text on the labels.
                updateUI()
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    var isPopUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (traitCollection.userInterfaceStyle == .light) { // Changing the tint color of the pop-up dialog when we switch between light and dark modes.
            view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        } else {
        view.tintColor = UIColor(red: 140/255, green: 140/255, blue: 240/255, alpha: 1)
        }
        
        // Do any additional setup after loading the view.
        
        
        
       
        
        // gets the layer for pop-up view and sets the corner radius of the layer to 10 points
        popupView.layer.cornerRadius = 10
        
    
        if searchResult != nil {
            updateUI()
        }
        
        if isPopUp {
          let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(close))
          gestureRecognizer.cancelsTouchesInView = false
          gestureRecognizer.delegate = self
          view.addGestureRecognizer(gestureRecognizer)
            
          view.backgroundColor = UIColor.clear
        } else {
          view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
          popupView.isHidden = true
            
            // displays application name on the Detail pane
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
              title = displayName
            }
          
    
    }
    }

 

    
    
    // telling UIKit this view controller uses a custom presentation, as well as setting the delegate that will call method created.
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    // MARK:- Actions
    @IBAction func close() {
        
        dismissStyle = .slide // setting the animation to .slide 
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func openInStore() {
    if let url = URL(string: searchResult.storeURL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
        
    }
    
    
    // MARK:- Navigation
    
    // telling the MenuViewController object who its delegate is
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      if segue.identifier == "ShowMenu" {
        let controller = segue.destination as! MenuViewController
        controller.delegate = self
      }
    }



// MARK:- Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        }
            else {
                artistNameLabel.text = searchResult.artist
                
            }
                kindLabel.text = searchResult.type
                genreLabel.text = searchResult.genre
        
        
        
        // Showing the price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
        priceText = "Free"
        } else if let text = formatter.string(
        from: searchResult.price as NSNumber) { priceText = text
        } else {
          priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        // getting image for pop up view
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        popupView.isHidden = false // makes the view visible when on the iPad.
        
    }
    
    // called whenever the object instance is deallocated and its memory is reclaimed.
    // closes the DetailViewController and the animation to remove it from the screen has completed. If the download task is not done by then, its cancelled.
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    
    // listing a list of possible values, slide and fade.The animations the Detail pop-up can perform when dismissed.
    enum AnimationStyle {
        case slide
        case fade
    }
    
    // determines which animation is chosen. Since the type is AnimationStyle it can only contain one of the values from the enum. The default is .fade, the animation that'll be used when rotating to landscape.
    var dismissStyle = AnimationStyle.fade
    
    
}

// MARK:- Extensions

// telling application that we want to use our own presentation controller, to display the Detail pop-up

extension DetailViewController:
          UIViewControllerTransitioningDelegate {
    
    
func presentationController(
    
forPresented presented: UIViewController,
presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
    return DimmingPresentationController( presentedViewController: presented, presenting: presenting)
    
}
    // telling application to use the animation controller ( BounceAnimationController) when presenting the Detail pop-up. 
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      return BounceAnimationController()
    }

    // overrides the animation controller to be used when a view controller is dismissed.
    func animationController(forDismissed dismissed:
                                UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
      }
    }
    
    
}


extension DetailViewController: UIGestureRecognizerDelegate {
  
    // closing the detail screen when the user taps outside the pop up, ignore other taps
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
shouldReceive touch: UITouch) -> Bool {
    
    return (touch.view === self.view)
}
    
    
    
}


extension DetailViewController: MenuViewControllerDelegate {
  func menuViewControllerSendEmail(_: MenuViewController) {
   
    
    dismiss(animated: true) {
        
      if MFMailComposeViewController.canSendMail() {
        
        let controller = MFMailComposeViewController()
        controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
        controller.setToRecipients(["your@email-address-here.com"])
        
        controller.mailComposeDelegate = self
        
        controller.modalPresentationStyle = .formSheet // determining how a modal view controller is presented on the iPad
        
        self.present(controller, animated: true, completion: nil)
    
    
    

      }
        
    }
    
  }


}



extension DetailViewController: MFMailComposeViewControllerDelegate {
    
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    
    dismiss(animated: true, completion: nil) // pressing Canel or Send will dismiss the mail compose sheet.
    
  }
    
}
