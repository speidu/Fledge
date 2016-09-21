//
//  AdsUtility.swift
//  Fledge
//
//  Created by pasi on 21.9.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation


class AdsUtility {
    
    class func chartboostInterstitial() {
        // Play the ad
        Chartboost.showInterstitial(CBLocationHomeScreen)
        
        // Try to cache the next ad
        Chartboost.cacheInterstitial(CBLocationHomeScreen)
    }
}
