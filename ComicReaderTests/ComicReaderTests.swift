//
//  ComicReaderTests.swift
//  ComicReaderTests
//
//  Created by Flavius Stan on 28/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import XCTest
@testable import ComicReader

class ComicReaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let fileManager = FileManager.default
        let path = URL(fileURLWithPath: "/Volumes/Toshiba 3TB/PruebaComics/Tests/TempFolder")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: path.path)
            
            for item in directoryContents{
                let fullPath = path.path + "/" + item
                try fileManager.removeItem(atPath: fullPath)
            }
        } catch {
            
        }
    }
    
    func testGetPagesFromCbr() throws {
        let pages = ComicFinder.getComicPagesFromCbr(path: "/Volumes/Toshiba 3TB/PruebaComics/Tests/Ultimate Spiderman #119.cbr",tempPath: URL(fileURLWithPath: "/Volumes/Toshiba 3TB/PruebaComics/Tests/TempFolder"), fileName: "Ultimate Spiderman #119")
        
        XCTAssertEqual(pages.count, 25)
    }
    
    func testGetPagesFromCbz() throws {
        let pages = ComicFinder.getComicPagesFromZip(path: "/Volumes/Toshiba 3TB/PruebaComics/Tests/Ultimate Spiderman #119.cbz",tempPath: URL(fileURLWithPath: "/Volumes/Toshiba 3TB/PruebaComics/Tests/TempFolder"), fileName: "Ultimate Spiderman #119")
        
        XCTAssertEqual(pages.count, 25)
    }
    
    func testGetPagesFromCb7() throws {
        let pages = ComicFinder.getComicPagesFrom7zip(path: "/Volumes/Toshiba 3TB/PruebaComics/Tests/Ultimate Spiderman #119.cb7",tempPath: URL(fileURLWithPath: "/Volumes/Toshiba 3TB/PruebaComics/Tests/TempFolder"), fileName: "Ultimate Spiderman #119")
        
        XCTAssertEqual(pages.count, 25)
    }

}
