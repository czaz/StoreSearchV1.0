//
//  ViewController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/19/21.
//

import UIKit

class SearchViewController: UIViewController {

    
    
    // outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
   
    // optional since we can only have one active LandscapeViewController instance (when the phone is in landscape orientation). In portrait orientation, this will be given a nil value
    var landscapeVC: LandscapeViewController?
    
   
    private let search = Search()
   
    weak var splitViewDetail: DetailViewController? // is an optional since it will be nil when the application runs on an iPhone
   

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Configures the two starting (2) table cells to no longer display underneath the search bar, but after it
        // 64 point margin top, -20 for status bar, and 44 for Search Bar
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        // creating a new variable to hold an UINib named SearchResultCell
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        // registering in the tableview the cellNib that is using the identifier SearchResultCell
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName:
                            TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.nothingFoundCell)
        
        // registering the LoadinCell nib in viewDidLoad()
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,
                        bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.loadingCell)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
        searchBar.becomeFirstResponder() // makes the search bar immediatly visible upon app launch
        
        }
        
        // changing the color of the segment in its normal, selected, and highlighted state
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes =
            [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentedControl.selectedSegmentTintColor = segmentColor

        
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
        
        // array / the data model for the table
        
        
        title = NSLocalizedString("Search", comment: "split view master button") // Back button will now say "Search" in the nav bar
    }

    
    // invoked when the device is rotated, when any time the trait collection for the view controller changes.
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) || (rect.width == 414 && rect.height == 736) {
            
          if presentedViewController != nil {
            
            dismiss(animated: true, completion: nil)
            
          }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            
          switch newCollection.verticalSizeClass {
          
          
          case .compact:
            showLandscape(with: coordinator)
          case .regular, .unspecified:
            hideLandscape(with: coordinator)
    
            
    @unknown default:
        fatalError()
      }
    }
}
    
    struct TableView { // creating a struct holding a secondary struct named CellIdentifiers that contains a constant named searchResultCell with th the value "SearchResultCell"
        // this is helpful since if we need to rename the reuse identifier, we would have to change its name in all places it occurs, but now we only need to limit those changes to one spot. Is the same for both constants
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    
    
    
    // MARK:- Helper Methods
    
    
    
    
    // method that displays an alert to handle any potential errors
    func showNetworkError() {
        
      let alert = UIAlertController(title: NSLocalizedString("Whoops...",
                                                             comment: "Network error Alert title"), message: NSLocalizedString("There was an error accessing the iTunes Store. Please try again.", comment: "Network error message"), preferredStyle: .alert)
      
      let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button title"), style: .default, handler: nil)
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
        
    }
    func showLandscape(with coordinator:
                        UIViewControllerTransitionCoordinator) {
    // 1 If landscapeVC is nil, return right away.
        // its a guard to prevent the application from instantiating a second landscape view if we are already looking at one.
   
    guard landscapeVC == nil else { return }
    // 2 finding the scene that has the ID "LandscapeViewController) and instantiating it. Since the landscapeVC instance var is an optional, we need to unwrap it before moving on.
    landscapeVC = storyboard!.instantiateViewController(
                    withIdentifier: "LandscapeViewController")
                    as? LandscapeViewController
      if let controller = landscapeVC {
        controller.search = search // the view controller will read from the searchResults array in viewDidLoad()
        
    // 3 Setting the size and position of the new view controller, we are making the landscape view just as big as the SearchViewController, covering the entire screen.
    controller.view.frame = view.bounds
        
    controller.view.alpha = 0
        
    // 4  Adding the contents of one view controller to another.
    view.addSubview(controller.view) // adding the landscape controller's view as a subview.
    addChild(controller) // Telling the SearchViewController that the LandscapeViewController is now managing that part of the screen via addChild().
   
        // landscape view starts out completely transparent (alpha = 0) and slowly fades in while rotation takes place until it's fully visible ( alpha = 1)
        coordinator.animate(alongsideTransition: { _ in
            controller.view.alpha = 1
            
            self.searchBar.resignFirstResponder() // hiding keyboard when device is rotated
            
            // hiding the Detail pop-up
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        
      },
        completion: { _ in
            controller.didMove(toParent: self)  // Telling the new view controller that it now has a parent view controller using didMove(toParent:)
        } )
    }
        
    }
    
    
    func hideLandscape(with coordinator:
                        UIViewControllerTransitionCoordinator) {
        
        if let controller = landscapeVC {
            controller.willMove(toParent: nil) // calling willMove(toParent:) to tell the view controller that it is leaving the view controller hierachy and it no longer has a parent.
         
        coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 0

            if self.presentedViewController != nil {
              self.dismiss(animated: true, completion: nil)
            }
            
        }, completion: { _ in
        controller.view.removeFromSuperview() // Remove its view from screen
        controller.removeFromParent() // truly disposing from the view controller
        self.landscapeVC = nil
    })
}
    }
}

// MARK:- Extensions
// this extensions handles all search bar related delegate methods
extension SearchViewController: UISearchBarDelegate {
    
    // this function is executed when the user taps the Search button the keyboard
    
    // is it as of right now putting some fake data into the array and displaying it using the table
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        
      if let category = Search.Category(
        rawValue: segmentedControl.selectedSegmentIndex) {
        search.performSearch(for: searchBar.text!, category: category, completion: {success in
          if !success {
            self.showNetworkError()
          }
          self.tableView.reloadData()
          self.landscapeVC?.searchResultsReceived()
          self.landscapeVC?.searchResultsReceived()
            
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
      }
        
    }

    // gives the search bar the ability to indicate its top position
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        
        return .topAttached
    }
  
    
    
    
    
    // MARK:- Navigation
    
    // when didSelectRowAt starts the segue, this send along the index-path of the selected row
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      if segue.identifier == "ShowDetail" {
        
        if case .results(let list) = search.state {
            
          let detailViewController = segue.destination as! DetailViewController
          let indexPath = sender as! IndexPath
          let searchResult = list[indexPath.row]
          detailViewController.searchResult = searchResult
            detailViewController.isPopUp = true
        }
      }
    }

    // hides the mater pane when in portrait mode when the user makes a selection
    private func hideMasterPane() {
        
      UIView.animate(withDuration: 0.25, animations: {
        
        self.splitViewController!.preferredDisplayMode = .primaryHidden
      },
      completion: { _ in
        self.splitViewController!.preferredDisplayMode = .automatic
        
      })
    }
    
    
    
   
}
    






// this extension will handle all table view related delegate methods
extension SearchViewController: UITableViewDelegate,
                                UITableViewDataSource {
    
    
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   // creates a single cell that will display (based on cellForRowAt: ) (Nothing Found). This is needed since otherwise the user would see nothing
    // this singular row lets them know now there were no results found. If the search button hasnt been pressed, then return 0 rows (display 0 rows)
   
    
    
    switch search.state {
    case .notSearchedYet:
        return 0
    case .loading:
        return 1 // need a row to show the user the table is loading
    case .noResults:
        return 1 //need a row to display a table was not found
    case .results(let list):
        return list.count
    }
}
    
   
    
    
    
    
    // returning the number of rows to display based on the contents of the searchResults array, then creating a UITableViewCell (by hand) to display the table rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      switch search.state {
      case .notSearchedYet:
        fatalError("Should never get here")
        
      case .loading:
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
        return cell
        
      case .noResults:
        return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        
      case .results(let list):
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        let searchResult = list[indexPath.row]
        cell.configure(for: searchResult)
        return cell
      }
    
    
}
    
    // these two methods makes the row that is tapped to no longer stay selected
    // tableView(didSelectRowAt: ) will deselect the row with an animation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            
          tableView.deselectRow(at: indexPath, animated: true)
          performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        }
        else {
          if case .results(let list) = search.state {
            splitViewDetail?.searchResult = list[indexPath.row]
          }
            if splitViewController!.displayMode != .allVisible {
              hideMasterPane()
            }

        }

        
    }
    
    // willSelectRowAt makes sure the user can only select rows when there are actual search results
    func tableView(_ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        switch search.state {
        case .notSearchedYet, .loading, .noResults: // if the application has not searched yet, is loading, or has no results, the cells are unable to be tapped by the user.
            return nil
        case .results:
            return indexPath
        }
    }
        
        
    
    

}


    
    



