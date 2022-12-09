import XCTest
@testable import XPCCollections

final class XPCCollectionsTests: XCTestCase {
    func testDictionary() throws {
        let dictionary = XPCDictionary()
        dictionary["hi"] = ""
        dictionary["bye"] = 0
        dictionary["die"] = true
        dictionary["hii"] = dictionary.copy()
        dictionary["hey"] = XPCData(Data.init("hi".utf8))
        print(dictionary.hashValue)
    }
    
    func testArray() throws {
        let array: XPCArray = [
            "hi", "there", 1, 2, XPCDictionary()
        ]
        array.append(1234)
        print(array[safe: 0] as Int?)
        print(array == array.copy())
        print(array.count)
        print(array.description)
    }
}
