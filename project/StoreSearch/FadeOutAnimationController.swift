//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/28/21.
//

import UIKit

    class FadeOutAnimationController: NSObject,
                         UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.4
            
        }
        
        // setting the view's alpha value to 0 in order to fade out
        
  func animateTransition(using transitionContext:
       UIViewControllerContextTransitioning) {
    if let fromView = transitionContext.view( forKey: UITransitionContextViewKey.from) {
        let time = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: time, animations: {
            fromView.alpha = 0
            
        }, completion: { finished in
            transitionContext.completeTransition(finished)
            
        })
} }
}
