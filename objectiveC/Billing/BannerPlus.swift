//
//  BannerPlus.swift
//  MobileOffice
//
//  Created by .D. .D. on 9/11/18.
//  Copyright © 2018 RCO. All rights reserved.
//

import BRYXBanner

@objc class BannerPlus: Banner {
    @objc func showBanner(view: UIView, duration: Double) {
        super.show(view, duration:duration)
    }
    @objc func dismissBanner(oldStatusBarStyle: UIStatusBarStyle) {
        super.dismiss(oldStatusBarStyle)
    }

}
