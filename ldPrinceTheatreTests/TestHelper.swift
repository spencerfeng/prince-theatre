//
//  TestHelper.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 10/10/21.
//

import Foundation

class TestHelper {
    func loadDataFromJson(fileName: String) -> Data {
        let bundle = Bundle(for: TestHelper.self)
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
