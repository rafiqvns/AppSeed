//
//  ImageSlideshowPlus.swift
//  MobileOffice
//
//  Created by .D. .D. on 7/24/19.
//  Copyright © 2019 RCO. All rights reserved.
//

import Foundation
import ImageSlideshow
open class ImageSlideshowPlus: ImageSlideshow {
    open fileprivate(set) var slideshowTransitioningDelegate1: ZoomAnimatedTransitioningDelegate?

    open func presentFullScreenController1(from controller: UIViewController, withItems imgs:[InputSource] ) -> FullScreenSlideshowViewController {
        let fullscreen = FullScreenSlideshowViewController()
        fullscreen.pageSelected = {[weak self] (page: Int) in
            self?.setCurrentPage(page, animated: false)
        }
        
        fullscreen.initialPage = currentPage
        //fullscreen.inputs = images
        fullscreen.inputs = imgs
        slideshowTransitioningDelegate1 = ZoomAnimatedTransitioningDelegate(slideshowView: self, slideshowController: fullscreen)
        fullscreen.transitioningDelegate = slideshowTransitioningDelegate1
        controller.present(fullscreen, animated: true, completion: nil)
        
        return fullscreen
    }

}
