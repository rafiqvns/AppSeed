//
//  UIImage+Rotation.swift
//  MobileOffice
//
//  Created by .D. .D. on 5/8/20.
//  Copyright © 2020 RCO. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func toRadians() -> CGFloat {
        return CGFloat(self * .pi / 180.0)
    }
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

@objc extension UIImage {
@objc func rotated(by degrees: Double, flipped: Bool = false) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: degrees.toRadians())
            renderContext.cgContext.scaleBy(x: flipped ? -1.0 : 1.0, y: -1.0)
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}
