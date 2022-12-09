//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/8/22.
//

import Foundation

public struct XPCArray: XPCHolding {
    public static let xpcType: xpc_type_t = XPC_TYPE_ARRAY
    
    public let rawValue: xpc_object_t
    
     public init(rawValue: xpc_object_t) {
        self.rawValue = rawValue
    }
    
     public init() {
        self.init(rawValue: xpc_array_create(nil, 0))
    }
}

public extension XPCArray {
    subscript(_ key: Int) -> xpc_object_t {
        get {
            xpc_array_get_value(rawValue, key)
        }
        nonmutating set {
            xpc_array_set_value(rawValue, key, newValue)
        }
    }
    
    subscript<P: XPCConvertible>(_ key: Int) -> P {
        get {
            let value = self[key]
            guard xpc_get_type(value) == P.xpcType else {
                preconditionFailure("Expected array[\(key)] to be of type \(P.xpcTypeName) but got \(_xpc_type_get_name(xpc_get_type(value)))")
            }
            return P(fromXPC: value)
        }
        nonmutating set {
            self[key] = newValue.toXPC()
        }
    }
    
    subscript<P: XPCConvertible>(safe key: Int) -> P? {
        get {
            let value = self[key]
            guard xpc_get_type(value) == P.xpcType else {
                return nil
            }
            return P(fromXPC: value)
        }
        nonmutating set {
            self[key] = newValue?.toXPC() ?? xpc_null_create()
        }
    }
}

//char *
//xpc_copy_short_description(xpc_object_t object);

extension XPCArray {
     public var count: Int {
        xpc_array_get_count(rawValue)
    }
    
     public var isEmpty: Bool {
        count == 0
    }
}

extension XPCArray {
    public func forEach(_ callback: (xpc_object_t) throws -> ()) throws {
        var error: Error?
        xpc_array_apply(rawValue) { _, value in
            do {
                try callback(value)
                return false
            } catch (let e) {
                error = e
            }
            return true
        }
        if let error = error {
            throw error
        }
    }
    
    public func forEach(_ callback: (xpc_object_t) -> ()) {
        xpc_array_apply(rawValue) { _, value in
            callback(value)
            return true
        }
    }
}

extension XPCArray {
    public var indices: Range<Int> {
        0..<count
    }
}

extension Array where Element == xpc_object_t {
    public init(_ array: XPCArray) {
        self.init(unsafeUninitializedCapacity: array.count) { buffer, initializedCount in
            array.forEach { value in
                buffer[initializedCount] = value
                initializedCount += 1
            }
        }
    }
}

extension XPCArray: Sequence {
    public struct Iterator: IteratorProtocol {
        let array: XPCArray
        var index = 0
        
        public mutating func next() -> xpc_object_t? {
            if index == array.count {
                return nil
            }
            return array[index]
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(array: self)
    }
}

extension XPCArray: Collection {
     public func index(after i: Int) -> Int {
        i + 1
    }
    
     public var startIndex: Int {
        0
    }
    
     public var endIndex: Int {
        count
    }
}

extension XPCArray: BidirectionalCollection {
    
}

extension XPCArray: RandomAccessCollection {
    
}

extension XPCArray {
     public func append(_ value: xpc_object_t) {
        xpc_array_append_value(rawValue, value)
    }
    
    public func append(_ value: XPCConvertible) {
        xpc_array_append_value(rawValue, value.toXPC())
    }
}

extension XPCArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: XPCConvertible...) {
        self = elements.map { $0.toXPC() }.withUnsafeBufferPointer {
            XPCArray(rawValue: xpc_array_create($0.baseAddress!, elements.count))
        }
    }
}
