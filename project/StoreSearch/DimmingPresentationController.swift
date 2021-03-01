//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/26/21.
// Custom Presentation Controller

// presentation controller, an object that controls the presnetation of something.
//
import UIKit


class DimmingPresentationController: UIPresentationController {
    
    
    
  override var shouldRemovePresentersView: Bool {
return false
}
    
    
    
lazy var dimmingView = GradientView(frame: CGRect.zero)

    // will be invoked when the new view contrller is to be shwon on the screen. We create the GradientView object, and  make it as big as the containerView, where we then insert it behind everything else in this container view
override func presentationTransitionWillBegin() {
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, at: 0)
    
    
    // Animate background gradient view, going to go along with Bounce animation
    dimmingView.alpha = 0
    if let coordinator =
        presentedViewController.transitionCoordinator { coordinator.animate(alongsideTransition: { _ in
    self.dimmingView.alpha = 1
            
        }, completion: nil)
    }
    
    
}

    // used to animate the gradient view out of sight, when the Detail pop-up is dismissed. Makes the alpha revert back to 0 (from 1)
    override func dismissalTransitionWillBegin()  {
      if let coordinator =
    presentedViewController.transitionCoordinator { coordinator.animate(alongsideTransition: { _ in
    self.dimmingView.alpha = 0
    }, completion: nil)
    }
        
    }
    
}



