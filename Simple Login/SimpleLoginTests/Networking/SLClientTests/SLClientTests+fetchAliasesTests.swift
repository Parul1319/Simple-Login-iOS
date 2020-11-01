//
//  SLClientTests+fetchAliasesTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 31/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchAliasesTests: XCTestCase {
    func whenFetchingAliasesWith(engine: NetworkEngine) throws -> (aliasArray: AliasArray?, error: SLError?) {
        var storedAliasArray: AliasArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchAliases(apiKey: ApiKey(value: ""), page: 10, searchTerm: nil) { result in
            switch result {
            case .success(let aliasArray): storedAliasArray = aliasArray
            case .failure(let error): storedError = error
            }
        }

        return (storedAliasArray, storedError)
    }

    func testFetchAliasesFailureWithUnknownError() throws {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithUnknownError()

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchAliasesFailureWithUnknownResponseStatusCode() throws {
        // given
        let engine = NetworkEngineMock(data: nil, statusCode: nil, error: nil)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.unknownResponseStatusCode)
    }

    func testFetchAliasesSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "AliasArray"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNotNil(result.aliasArray)
        XCTAssertNil(result.error)
    }

    func testFetchAliasesFailureWithStatusCode400() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 400)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchAliasesFailureWithStatusCode401() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithSpecificError(statusCode: 401)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }

    func testFetchAliasesFailureWithStatusCode500() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(500)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testFetchAliasesFailureWithStatusCode502() throws {
        // given
        let engine = try NetworkEngineMock.givenEngineWithDummyDataAndStatusCode(502)

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, SLError.badGateway)
    }

    func testFetchAliasesFailureWithUnknownErrorWithStatusCode() throws {
        // given
        let (engine, expectedError) =
            try NetworkEngineMock.givenEngineWithUnknownErrorWithStatusCode()

        // when
        let result = try whenFetchingAliasesWith(engine: engine)

        // then
        XCTAssertNil(result.aliasArray)
        XCTAssertEqual(result.error, expectedError)
    }
}