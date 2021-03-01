//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/28/21.
//

import UIKit

class MenuViewController: UITableViewController {

    weak var delegate: MenuViewControllerDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    
    // MARK:- Table View Delegates
    
    // handles taps on the rows from the table view.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      tableView.deselectRow(at: indexPath, animated: true)
      
      if indexPath.row == 0 {
        delegate?.menuViewControllerSendEmail(self)
      }
    }
    
}
protocol MenuViewControllerDelegate: class {
  func menuViewControllerSendEmail(_ controller: MenuViewController)
}
