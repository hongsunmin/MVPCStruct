//
//  PackTests.swift
//  MVPCStruct
//
//  Created by Per Olofsson on 2014-06-13.
//  Copyright (c) 2014 AutoMac. All rights reserved.
//

import XCTest
import MVPCStruct

class PackTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testHello() {
        let facit = "Hello".data(using: .utf8)
        
        let packer = CStruct()
        switch packer.pack(["H", "e", "l", "l", "o"] as [AnyObject], format: "ccccc") {
        case .success(let result):
            XCTAssertEqual(result, facit)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
        
        switch packer.pack(["H", "e", "l", "l", "o"] as [AnyObject], format: "5c") {
        case .success(let result):
            XCTAssertEqual(result, facit)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
    }
    
    func testInts() {
        let signedFacit = Data(bytes: [0xff, 0xfe, 0xff, 0xfd, 0xff, 0xff, 0xff, 0xfc, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff] as [UInt8], count: 15)
        let packer = CStruct()
        switch packer.pack([-1, -2, -3, -4] as [AnyObject], format: "<bhiq") {
        case .success(let result):
            XCTAssertEqual(signedFacit, result)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
        
        let unsignedFacit = Data(bytes: [0x01, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], count: 15)
        switch packer.pack([1, 2, 3, 4] as [AnyObject], format: "<BHIQ") {
        case .success(let result):
            print("Unsigned result: \(result)")
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
    }
    
    func testAlignment() {
        // This test will fail on bigendian platforms.
        let packer = CStruct()
        
        let signedFacit16 = Data(bytes: [0x01, 0x00, 0x02, 0x00] as [UInt8], count: 4)
        switch packer.pack([1, 2] as [AnyObject], format: "@BH") {
        case .success(let result):
            XCTAssertEqual(signedFacit16, result)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
        
        let signedFacit32 = Data(bytes: [0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00] as [UInt8], count: 8)
        switch packer.pack([1, 2] as [AnyObject], format: "@BI") {
        case .success(let result):
            XCTAssertEqual(signedFacit32, result)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
        
        let signedFacit64 = Data(bytes: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], count: 16)
        switch packer.pack([1, 2] as [AnyObject], format: "@BQ") {
        case .success(let result):
            XCTAssertEqual(signedFacit64, result)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
    }
    
    func testBigEndian() {
        let facit = Data(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e] as [UInt8], count: 14)
        
        let packer = CStruct()
        
        switch packer.pack([0x0102, 0x03040506, 0x0708090a0b0c0d0e] as [AnyObject], format: ">HIQ") {
        case .success(let result):
            XCTAssertEqual(facit, result)
        case .failure(let error):
            XCTFail("result is nil. error: \(error)")
        }
    }
    
    func testBadFormat() {
        let packer = CStruct()
        
        if case .failure(let error) = packer.pack([], format: "4@") {
            XCTFail("bad format should return nil. error: \(error)")
        }
        if case .failure(let error) = packer.pack([1] as [AnyObject], format:"1 i") {
            XCTFail("bad format should return nil. error: \(error)")
        }
        if case .failure(let error) = packer.pack([], format:"i") {
            XCTFail("bad format should return nil. error: \(error)")
        }
        if case .failure(let error) = packer.pack([1, 2] as [AnyObject], format:"i") {
            XCTFail("bad format should return nil. error: \(error)")
        }
    }

}
