import XPC
import Foundation

public struct XPCDictionary: XPCHolding {
    public static let xpcType: xpc_type_t = XPC_TYPE_DICTIONARY
    
    public let rawValue: xpc_object_t
    
     public init(rawValue: xpc_object_t) {
        self.rawValue = rawValue
    }
    
     public init() {
        self.init(rawValue: xpc_dictionary_create(nil, nil, 0))
    }
}

public extension XPCDictionary {
    @_disfavoredOverload
    subscript(_ key: String) -> xpc_object_t? {
        get {
            key.withCString {
                xpc_dictionary_get_value(rawValue, $0)
            }
        }
        nonmutating set {
            key.withCString {
                xpc_dictionary_set_value(rawValue, $0, newValue)
            }
        }
    }
    
    subscript<P: XPCConvertible>(_ key: String) -> P? {
        get {
            guard let value = self[key] as xpc_object_t? else {
                return nil
            }
            switch xpc_get_type(value) {
            case XPC_TYPE_NULL:
                return nil
            case P.xpcType:
                break
            case let unknown:
                preconditionFailure("Expected dictionary[\(key)] to be of type \(P.xpcTypeName) but got \(unknown))")
            }
            return P(fromXPC: value)
        }
        nonmutating set {
            self[key] = newValue?.toXPC()
        }
    }
    
    subscript<P: XPCConvertible>(safe key: String) -> P? {
        get {
            guard let value = self[key] as xpc_object_t? else {
                return nil
            }
            guard xpc_get_type(value) == P.xpcType else {
                return nil
            }
            return P(fromXPC: value)
        }
        nonmutating set {
            self[key] = newValue?.toXPC()
        }
    }
}

extension XPCDictionary {
     public var count: Int {
        xpc_dictionary_get_count(rawValue)
    }
}

extension XPCDictionary {
    public func forEach(_ callback: (String, xpc_object_t) throws -> ()) throws {
        var error: Error?
        xpc_dictionary_apply(rawValue) { key, value in
            do {
                try callback(String(cString: key), value)
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
    
    public func forEach(_ callback: (String, xpc_object_t) -> ()) {
        xpc_dictionary_apply(rawValue) { key, value in
            callback(String(cString: key), value)
            return true
        }
    }
    
    public func forEach(_ callback: (String, xpc_object_t, inout Bool) -> ()) {
        var stop = false
        xpc_dictionary_apply(rawValue) { key, value in
            callback(String(cString: key), value, &stop)
            return !stop
        }
    }
}

extension XPCDictionary {
    public var keys: [String] {
        [String](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            forEach { key, _ in
                buffer[initializedCount] = key
                initializedCount += 1
            }
        }
    }
    
    public var values: [xpc_object_t] {
        [xpc_object_t](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            forEach { _, value in
                buffer[initializedCount] = value
                initializedCount += 1
            }
        }
    }
}

extension Dictionary where Key == String, Value == xpc_object_t {
    public init(_ dictionary: XPCDictionary) {
        self.init(minimumCapacity: dictionary.count)
        dictionary.forEach {
            self[$0] = $1
        }
    }
}

extension XPCDictionary: Sequence {
    public struct Iterator: IteratorProtocol {
        let dictionary: XPCDictionary
        var keys: [String]
        
        init(dictionary: XPCDictionary) {
            self.dictionary = dictionary
            self.keys = dictionary.keys.reversed()
        }
        
        public mutating func next() -> xpc_object_t? {
            guard let key = keys.popLast() else {
                return nil
            }
            return dictionary[key]
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(dictionary: self)
    }
}

extension XPCDictionary: Collection {
    public func key(at index: Int) -> Key {
        var key = "", counter = 0
        forEach { currentKey, _, stop in
            if counter == index {
                key = currentKey
                stop = true
            }
            counter += 1
        }
        return key
    }
    
     public func index(after i: Index) -> Index {
        i + 1
    }
    
    public subscript(position: Index) -> OS_xpc_object {
        _read {
            let value = self[key(at: position)] ?? xpc_null_create()
            yield value
        }
    }
    
     public var startIndex: Index {
        0
    }
    
     public var endIndex: Index {
        count
    }
    
    public typealias Key = String
    public typealias Value = xpc_object_t?
    public typealias Index = Int
}

extension XPCDictionary: RandomAccessCollection {
    
}
