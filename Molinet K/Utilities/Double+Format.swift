//
//  Double+format.swift
//  GRAM_01
//
//  Created by Francisco Gorina Vanrell on 19/08/2019.
//  Copyright © 2019 Francisco Gorina Vanrell. All rights reserved.
//

import Foundation

extension Double {
    
    var stringValue : String {
        return formatted(decimals: 1, separator: false)
    }
    func formatted() -> String {
        return String(format: "%10.1f", self)
    }
    
    func formatted(format : String) -> String{
        return String(format: format, self)
    }
    
    func formatted(decimals: Int, separator: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.usesGroupingSeparator = true

        return formatter.string(from: NSNumber(value:self))!
    }
    

    
    init?(string: String){
        
        // Detectar si hi ha alguna comma
        var clean : String = string
        
        let comma = clean.firstIndex(of: ",")
        let point = clean.firstIndex(of: ".")
        
        if let comma = comma, let point = point {
            if comma < point {
                clean = clean.replacingOccurrences(of: ",", with: "")   // , is thousands, . is decimal
            }else {
                clean = clean.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")  // . is Thousands, , is decimal
            }
        } else if comma != nil {
            clean = clean.replacingOccurrences(of: ",", with: ".")  // , is decimal
        }
        
        self.init(clean)
    }
    
}
