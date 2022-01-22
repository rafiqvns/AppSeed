//
//  ImagePickerControllerPlus.swift
//  MobileOffice
//
//  Created by .D. .D. on 10/26/18.
//  Copyright © 2018 RCO. All rights reserved.
//

import ImagePicker
import UIKit
import Foundation

@objc class ImagePickerControllerPlus: ImagePickerController {
    @objc func setImageLimit(number: Int) {
        super.imageLimit = number
    }
/*
     20.06.2019 enable rotation
    override var shouldAutorotate: Bool {
        let executableName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String
        
        if (executableName == "CSD") {
            return true

            //return false
        } else {
            return true
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        let executableName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String
        
        if (executableName == "CSD") {
            //return .all
            return .landscape
        } else {
            return super.supportedInterfaceOrientations
        }
    }
    */
  /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! BillingAppDelegate
       // appDelegate.enableAllOrientation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = false
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    */
 }

