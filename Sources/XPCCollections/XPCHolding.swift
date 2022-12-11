//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/9/22.
//

import Foundation

public protocol XPCHolding: Hashable, Equatable, XPCConvertible, CustomStringConvertible, CustomDebugStringConvertible, RawRepresentable where RawValue == xpc_object_t {
}

extension XPCHolding { // : XPCConvertible
    public init(fromXPC value: xpc_object_t) {
        self.init(rawValue: value)!
    }
    
    public func toXPC() -> xpc_object_t {
        rawValue
    }
}

extension XPCHolding { // : CustomStringConvertible
    public var description: String {
        _read {
            let description = xpc_copy_short_description(rawValue)
            yield String(cString: description)
            free(description)
        }
    }
}

extension XPCHolding { // : CustomDebugStringConvertible
    public var debugDescription: String {
        _read {
            let description = xpc_copy_description(rawValue)
            yield String(cString: description)
            free(description)
        }
    }
}

extension XPCHolding {
    public func copy() -> Self {
        Self.init(rawValue: xpc_copy(rawValue)!)!
    }
}

extension XPCHolding { // : Equatable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        xpc_equal(lhs.rawValue, rhs.rawValue)
    }
}

extension XPCHolding { // : Hashable
    public func xpcHash() -> Int {
        xpc_hash(rawValue)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(xpcHash())
    }
}
