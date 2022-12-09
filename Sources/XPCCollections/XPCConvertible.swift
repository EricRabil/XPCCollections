//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/9/22.
//

import Foundation

public protocol XPCConvertible {
    static var xpcType: xpc_type_t { get }
    init(fromXPC value: xpc_object_t)
    func toXPC() -> xpc_object_t
}

func _xpc_type_get_name(_ type: xpc_type_t) -> String {
    if #available(macOS 10.15, iOS 13, *) {
        return String(cString: xpc_type_get_name(type))
    } else {
        switch type {
            case XPC_TYPE_ACTIVITY: return "XPC_TYPE_ACTIVITY"

            case XPC_TYPE_ARRAY: return "XPC_TYPE_ARRAY"

            case XPC_TYPE_BOOL: return "XPC_TYPE_BOOL"

            case XPC_TYPE_CONNECTION: return "XPC_TYPE_CONNECTION"

            case XPC_TYPE_DATA: return "XPC_TYPE_DATA"

            case XPC_TYPE_DATE: return "XPC_TYPE_DATE"

            case XPC_TYPE_DICTIONARY: return "XPC_TYPE_DICTIONARY"

            case XPC_TYPE_DOUBLE: return "XPC_TYPE_DOUBLE"

            case XPC_TYPE_ENDPOINT: return "XPC_TYPE_ENDPOINT"

            case XPC_TYPE_ERROR: return "XPC_TYPE_ERROR"

            case XPC_TYPE_FD: return "XPC_TYPE_FD"

            case XPC_TYPE_INT64: return "XPC_TYPE_INT64"

            case XPC_TYPE_NULL: return "XPC_TYPE_NULL"

            case XPC_TYPE_SHMEM: return "XPC_TYPE_SHMEM"

            case XPC_TYPE_STRING: return "XPC_TYPE_STRING"

            case XPC_TYPE_UINT64: return "XPC_TYPE_UINT64"

            case XPC_TYPE_UUID: return "XPC_TYPE_UUID"

            case XPC_TYPE_CONNECTION: return "XPC_TYPE_CONNECTION"

            case XPC_TYPE_ENDPOINT: return "XPC_TYPE_ENDPOINT"

            case XPC_TYPE_NULL: return "XPC_TYPE_NULL"

            case XPC_TYPE_BOOL: return "XPC_TYPE_BOOL"

            case XPC_TYPE_INT64: return "XPC_TYPE_INT64"

            case XPC_TYPE_UINT64: return "XPC_TYPE_UINT64"

            case XPC_TYPE_DOUBLE: return "XPC_TYPE_DOUBLE"

            case XPC_TYPE_DATE: return "XPC_TYPE_DATE"

            case XPC_TYPE_DATA: return "XPC_TYPE_DATA"

            case XPC_TYPE_STRING: return "XPC_TYPE_STRING"

            case XPC_TYPE_UUID: return "XPC_TYPE_UUID"

            case XPC_TYPE_FD: return "XPC_TYPE_FD"

            case XPC_TYPE_SHMEM: return "XPC_TYPE_SHMEM"

            case XPC_TYPE_ARRAY: return "XPC_TYPE_ARRAY"

            case XPC_TYPE_DICTIONARY: return "XPC_TYPE_DICTIONARY"

            case XPC_TYPE_ERROR: return "XPC_TYPE_ERROR"

            case XPC_TYPE_ACTIVITY: return "XPC_TYPE_ACTIVITY"
        default:
            return "XPC_TYPE_UNKNOWN"
        }
    }
}

extension XPCConvertible {
    public static var xpcTypeName: String { String(cString: _xpc_type_get_name(xpcType)) }
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
