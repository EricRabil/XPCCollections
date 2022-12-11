//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/8/22.
//

import Foundation
import XPC

/// Wraps an `xpc_data_t` object, providing conformance to the `DataProtocol`
public struct XPCData: XPCHolding {
    public static let xpcType: xpc_type_t = XPC_TYPE_DATA
    
    public let rawValue:  xpc_object_t
    
    public init(rawValue:  xpc_object_t) {
        self.rawValue = rawValue
    }
}

public extension XPCData {
    /// Size of the data as reported by `xpc_data_get_length`
    var count: Int {
        xpc_data_get_length(rawValue)
    }
}

public extension XPCData {
    typealias Element = Data.Element
    typealias Index = Data.Index
}

extension XPCData {
    public struct Iterator: IteratorProtocol {
        let data: XPCData
        var index: Index = 0
        var scratch: Element = 0
        
        public mutating func next() -> Element? {
            if index >= data.count {
                return nil
            }
            if xpc_data_get_bytes(data.rawValue, &scratch, index, 1) == 0 {
                return nil
            }
            return scratch
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(data: self)
    }
}

extension XPCData: Sequence {}

extension XPCData: Collection {
    public func index(after i: Data.Index) -> Data.Index {
        i + 1
    }
    
    public subscript(position: Data.Index) -> Data.Element {
        get {
            var scratch: Element = 0
            _ = xpc_data_get_bytes(rawValue, &scratch, position, 1)
            return scratch
        }
    }
    
    public var startIndex: Data.Index {
        0
    }
    
    public var endIndex: Data.Index {
        count
    }
}

extension XPCData: RandomAccessCollection {
    
}

extension XPCData: BidirectionalCollection {
    
}

extension XPCData: ContiguousBytes {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try body(.init(start:  xpc_data_get_bytes_ptr(rawValue), count: count))
    }
}

extension XPCData: DataProtocol {
    public typealias Regions = CollectionOfOne<XPCData>
    
    public var regions: CollectionOfOne<XPCData> {
        CollectionOfOne(self)
    }
}

extension Data {
    init(_ data: XPCData) {
        guard let bytes = xpc_data_get_bytes_ptr(data.rawValue) else {
            self = Data()
            return
        }
        self.init(bytes: bytes, count: data.count)
    }
}

extension XPCData {
    init(_ data: Data) {
        self.rawValue = data.withUnsafeBytes {
            xpc_data_create($0.baseAddress, $0.count)
        }
    }
}
