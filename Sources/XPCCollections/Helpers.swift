//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/10/22.
//

import Foundation

public protocol XPCDictionaryHolding: XPCConvertible, RawRepresentable where RawValue == XPCDictionary {
}

public extension XPCDictionaryHolding {
    static var xpcType: xpc_type_t { XPCDictionary.xpcType }
    
    init(fromXPC value: xpc_object_t) {
        self.init(rawValue: XPCDictionary(fromXPC: value))!
    }
    
    init() {
        self.init(rawValue: XPCDictionary())!
    }
    
    func toXPC() -> xpc_object_t {
        rawValue.rawValue
    }
}
