//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/28/21.
//

import Foundation
import UIKit

class LandscapeViewController: UIViewController {
    
    // outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // properties
    
    var search: Search!
    
    private var downloads = [URLSessionDownloadTask]() // this array keeps track of all the active URLSessionDownloadTask objects.
    
    private var firstTime = true // internal peice of state that only LandscapeViewController cares about
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
    // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
    // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
   
        pageControl.numberOfPages = 0
        
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        // adding a background to the view
        view.backgroundColor = UIColor(patternImage:
                                        UIImage(named: "LandscapeBackground")!)
        
       
    }
    

    // Custom scroll view layout
    // the scroll vuew should always be as large as the entire screen.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = CGRect(x: safeFrame.origin.x,
                                   y: safeFrame.size.height - pageControl.frame.size.height,
                                   width: safeFrame.size.width,
                                   height: pageControl.frame.size.height)
        
        
        if firstTime {
            firstTime = false
            switch search.state {
            case .notSearchedYet:
              break
            case .loading:
              showSpinner()
            case .noResults:
              showNothingFoundLabel()
            case .results(let list):
              tileButtons(list) // calculates where to place the tiles
            }

        }
        
    }
    
    // stops download for any button whose image was still pending/in transit
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
    }
    
    // MARK:- Actions
    
    // used to determine when the user taps on the Page Control so we can update the scroll view.
    // also has an animation method to configure an animation to play from one page to another when tapping in the page control
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0,
                       options: [.curveEaseInOut], animations: {
    self.scrollView.contentOffset = CGPoint(
    x: self.scrollView.bounds.size.width *
    CGFloat(sender.currentPage), y: 0)
                        
    },
      completion: nil)
}
    
    // Called when a button is tapped. Executes a segue.
    @objc func buttonPressed(_ sender: UIButton) {
        
      performSegue(withIdentifier: "ShowDetail", sender: sender)
        
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      if segue.identifier == "ShowDetail" {
        
        if case .results(let list) = search.state {
            
          let detailViewController = segue.destination as! DetailViewController
          let searchResult = list[(sender as! UIButton).tag - 2000]
          detailViewController.searchResult = searchResult
            
            detailViewController.isPopUp = true
            
        }
      }
    }
    
    
    // MARK:- Public Methods
    func searchResultsReceived() {
      hideSpinner()
      
      switch search.state {
      case .notSearchedYet, .loading:
        break
      case .noResults:
        showNothingFoundLabel()
      case .results(let list):
        tileButtons(list)
      }
    }


    
    // MARK:- Private Methods
    // private aka limited to this class
    
    // displays an activity indicator, creating a new UIActivityIndicatorView object
    private func showSpinner() {
      let spinner = UIActivityIndicatorView(style: .large)
      spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
      spinner.tag = 1000
      view.addSubview(spinner)
      spinner.startAnimating()
    }
    
    private func hideSpinner() {
      view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    
    private func tileButtons(_ searchResults: [SearchResult]) {
    var columnsPerPage = 6
    var rowsPerPage = 3
    var itemWidth: CGFloat = 94
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 2
    var marginY: CGFloat = 20
        
    let viewWidth = scrollView.bounds.size.width
        
    switch viewWidth { // for specification on how many rows and columns etc. pg 1079
    case 568:
    // 4-inch device
    break
        
    case 667:
    // 4.7-inch device
        columnsPerPage = 7
        itemWidth = 95
        itemHeight = 98
        marginX = 1
        marginY = 29
        
    case 736:
       // 5.5-inch device
        columnsPerPage = 8
        rowsPerPage = 4
        itemWidth = 92
        marginX = 0
        
    case 724:
           // iPhone X
           columnsPerPage = 8
           rowsPerPage = 3
           itemWidth = 90
           itemHeight = 98
           marginX = 2
           marginY = 29
       default:
       break
       }
         // TODO: more to come here
        
        // Button Size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
        // 1  Creating the UIButton object. Instead of a regular button we made a .custom one.
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal) // Giving the button a background image instead of a white background and title.
            
            button.tag = 2000 + index // tag 0 is default on all views, so we add 2000.
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside) // When tapped, call buttonPressed
            
            // configures images for buttons
            downloadImage(for: result, andPlaceOn: button)
            
            // 2  To make a button by hand, we have to set its frame.
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth, height: buttonHeight)
            
        // 3 Adding the new button object to the UIScrollView as a subview. After 18 buttons or so, any subsequent buttons are placed out of the visible range of the scroll view.
        scrollView.addSubview(button)
            
            
        // 4 Using the x and row variables to position the button, going from top to bottom. When the bottom is reached we go up to again to row 0 and skip to the next column.
          row += 1
          if row == rowsPerPage {
            row = 0; x += itemWidth; column += 1
          
            if column == columnsPerPage {
              column = 0; x += marginX * 2
            }
        } }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(  // calculate the contentSize for the scroll view based on how many buttons fit on a page and the number of SearchResult object
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        // setting the number of dots that the page control displays to the number of pages that you calculated.
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
       }

    // displaying button images, first: dowloading the artwork images
    private func downloadImage(for searchResult: SearchResult,
                              andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
         
            if error == nil, let url = url,
             let data = try? Data(contentsOf: url),
             let image = UIImage(data: data) {
            DispatchQueue.main.async {
                if let button = button {
                    button.setImage(image, for: .normal)
                    
                }
            }
        }
    }
    task.resume() // resuming the download task
    downloads.append(task)
            
        }
    }
    
    // If no matches are found we tell the user about this in landscape mode
    private func showNothingFoundLabel() {
      let label = UILabel(frame: CGRect.zero)
      label.text = "Nothing Found"
      label.textColor = UIColor.white
      label.backgroundColor = UIColor.clear
      
      label.sizeToFit()
      
      var rect = label.frame
      rect.size.width = ceil(rect.size.width/2) * 2
      rect.size.height = ceil(rect.size.height/2) * 2
      label.frame = rect
      
      label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
      view.addSubview(label)
    }
    
    
    
    
}


// MARK:- Extensions


extension LandscapeViewController: UIScrollViewDelegate { // A UISrollViewDelegate method.
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) // if the content offset goes beyond halfway on the page,
                                                        / width)
        pageControl.currentPage = page       // the scroll view will move on to the next page. we then update the pageControl's active page number.
}





}
