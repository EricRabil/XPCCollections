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

/// Shim method for platforms that do not support `xpc_type_get_name`
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

/// Weak link to `xpc_copy_short_description` which provides a more concise description as opposed to the public `xpc_copy_description`
/// If `xpc_copy_short_description` is removed, this weak link will fall back to `xpc_copy_description`, meaning all `description` fields will be equivalent to `debugDescription`
@usableFromInline let xpc_copy_short_description: @convention(c) (xpc_object_t) -> UnsafeMutablePointer<CChar> = {
    if let sym = dlsym(dlopen(nil, RTLD_GLOBAL), "xpc_copy_short_description") {
        return unsafeBitCast(sym, to: (@convention(c) (xpc_object_t) -> UnsafeMutablePointer<CChar>).self)
    }
    return {
        xpc_copy_description($0)
    }
}()
