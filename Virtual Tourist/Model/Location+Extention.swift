//
//  Location+Extention.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude:  CLLocationDegrees(long))
    }
    
}
