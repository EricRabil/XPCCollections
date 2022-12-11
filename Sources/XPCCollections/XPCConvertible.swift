//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/9/22.
//

import Foundation

/// Types conforming to this protocol may be seamlessly passed to and from XPC collections.
public protocol XPCConvertible {
    /// The `xpc_type_t` that raw values must conform to
    static var xpcType: xpc_type_t { get }
    /// Initializes the type according to a raw XPC value.
    init(fromXPC value: xpc_object_t)
    /// Encodes the type to a raw XPC value.
    func toXPC() -> xpc_object_t
}

extension XPCConvertible {
    /// A short string identifying the XPC type requirement
    public static var xpcTypeName: String { _xpc_type_get_name(xpcType) }
}

extension String: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_STRING
    
    public init(fromXPC value: xpc_object_t) {
        if let pointer = xpc_string_get_string_ptr(value) {
            self.init(cString: pointer)
        } else {
            self = ""
        }
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_string_create(self)
    }
}

extension Int64: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_INT64
    
    public init(fromXPC value: xpc_object_t) {
        self = xpc_int64_get_value(value)
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_int64_create(self)
    }
}

extension UInt64: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_UINT64
    
    public init(fromXPC value: xpc_object_t) {
        self = xpc_uint64_get_value(value)
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_uint64_create(self)
    }
}

extension Int: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_INT64
    
    public init(fromXPC value: xpc_object_t) {
        self = Int(Int64(fromXPC: value))
    }
    
    public func toXPC() -> xpc_object_t {
        Int64(self).toXPC()
    }
}

extension UInt: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_UINT64
    
    public init(fromXPC value: xpc_object_t) {
        self = UInt(UInt64(fromXPC: value))
    }
    
    public func toXPC() -> xpc_object_t {
        UInt64(self).toXPC()
    }
}

extension Bool: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_BOOL
    
    public init(fromXPC value: xpc_object_t) {
        self = xpc_bool_get_value(value)
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_bool_create(self)
    }
}

extension UUID: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_UUID
    
    public init(fromXPC value: xpc_object_t) {
        guard let bytes = xpc_uuid_get_bytes(value) else {
            fatalError()
        }
        self = UUID(uuid: UnsafeRawPointer(bytes).assumingMemoryBound(to: uuid_t.self).pointee)
    }
    
    public func toXPC() -> xpc_object_t {
        withUnsafePointer(to: uuid) {
            xpc_uuid_create(UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self))
        }
    }
}

extension Date: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_DATE
    
    @usableFromInline static var xpcDateInterval: TimeInterval { 1000000000 }
    
    public init(fromXPC value: xpc_object_t) {
        self = Date(timeIntervalSince1970: TimeInterval(xpc_date_get_value(value)) / Self.xpcDateInterval)
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_date_create(Int64(timeIntervalSince1970 * Self.xpcDateInterval))
    }
}

extension Double: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_DOUBLE
    
    public init(fromXPC value: xpc_object_t) {
        self = xpc_double_get_value(value)
    }
    
    public func toXPC() -> xpc_object_t {
        xpc_double_create(self)
    }
}

extension Data: XPCConvertible {
    public static let xpcType: xpc_type_t = XPC_TYPE_DATA
    
    public init(fromXPC value: xpc_object_t) {
        self.init(XPCData(fromXPC: value))
    }
    
    public func toXPC() -> xpc_object_t {
        XPCData(self).toXPC()
    }
}

extension RawRepresentable where RawValue: XPCConvertible {
    public static var xpcType: xpc_type_t { RawValue.xpcType }
    
    public init(fromXPC value: xpc_object_t) {
        self.init(rawValue: RawValue(fromXPC: value))!
    }
    
    public func toXPC() -> xpc_object_t {
        rawValue.toXPC()
    }
}
