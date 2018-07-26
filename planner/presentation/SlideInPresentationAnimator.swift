//
//  UIViewControllerAnimatedTransitioning.swift
//  planner
//
//  Created by Daniil Subbotin on 08/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import UIKit

final class SlideInPresentationAnimator: NSObject {
    
    /// To present or dismiss the view controller
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
}

extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /*
         If this is a presentation,
            the method asks the transitionContext for the view controller associated with the .to key, aka the view controller you’re moving to.
            If dismissal, it asks the transitionContext for the view controller associated with the .from, aka the view controller you’re moving from.
 */
        let key = isPresentation ? UITransitionContextViewControllerKey.to
            : UITransitionContextViewControllerKey.from
        
        let controller = transitionContext.viewController(forKey: key)!
        
        // If the action is a presentation, code adds the view controller’s view to the view hierarchy; this code uses the transitionContext to get the container view.
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        /*
        Calculate the frames you’re animating from and to.
        Asks the transitionContext for the view’s frame when it’s presented.*/
        let presentedFrame = transitionContext.finalFrame(for: controller)
        // Calculating the view’s frame when it’s dismissed. This section sets the frame’s origin so it’s just outside the visible area.
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        
        // Determine the transition’s initial and final frames. When presenting the view controller, it moves from the dismissed frame to the presented frame — vice versa when dismissing.
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        // Lastly, this method animates the view from initial to final frame. Note that it calls completeTransition(_:) on the transitionContext to show the transition has finished.
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .preferredFramesPerSecond60, animations: {
            controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
        
    }
    
}
