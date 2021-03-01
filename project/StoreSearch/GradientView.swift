//
//  GradientView.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/27/21.
//

import UIKit


class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        // telling the view it should change both its width and its height proportionally when the superview it belongs to resizes due to being rotated, or for some other reason.
        
        // now the gradient will always cover the whole screen
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
        
    }
    
    
required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clear
    
    // telling the view it should change both its width and its height proportionally when the superview it belongs to resizes due to being rotated, or for some other reason.
    
    // now the gradient will always cover the whole screen
    autoresizingMask = [.flexibleWidth , .flexibleHeight]
}
    
override func draw(_ rect: CGRect) {
    // 1   Two arrays containing the color stops for the graident
    let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
    let locations: [CGFloat] = [ 0, 1 ]

    // 2 Via those colors we can make the gradient. We now create a new CGGradient object.
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorSpace: colorSpace,
                   colorComponents: components,
                   locations: locations, count: 2)

    // 3 We now have the graident object, we have to figure out how big we need to draw it.
    // midX and midY properties return the center of a rectangle.
    // centerPoint contains the coords for the center point of the view
    // radius contains the larger of the x and y values. We use max to make sure we assign the larger values to radius.


    let x = bounds.midX
    let y = bounds.midY
    let centerPoint = CGPoint(x: x, y : y)
    let radius = max(x, y)
    
// 4  With this information we draw the gradient view, we need to obtain a reference to the current context and we then can do the drawing.
    
    let context = UIGraphicsGetCurrentContext()
            // drawRadialGradient() draws the gradient according to our specifications
    context?.drawRadialGradient(gradient!,
        startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
}
    
}
