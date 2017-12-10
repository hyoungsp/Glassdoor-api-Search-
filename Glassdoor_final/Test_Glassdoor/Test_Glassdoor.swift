//
//  Test_Glassdoor.swift
//  Test_Glassdoor
//
//  Created by HYOUNGSUN park on 12/7/17.
//

import XCTest

/// To see if the custom structs are matching in terms of equatable protocol
class Test_Glassdoor: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let savedResult = CompanyDetails(
            name: "Facebook",
            industryName: "",
            website: URL(string: "www.facebook.com")!,
            numberOfRatings: 199,
            ratingDescription: "4.5",
            seniorLeadershipRating: "3.3",
            compensationAndBenefitsRating: "2.1",
            careerOpportunitiesRating: "3.2",
            workLifeBalanceRating: "1.9",
            overallRating: "3.4",
            featuredReview: CompanyReview(location: "San Francisco, CA", headline: "Great!", pros: "nice salary", cons: "political")
        )
        /// Success !!
        let apiurl = "http://api.glassdoor.com/api/api.htm?v=1&format=json&t.p=233892&t.k=CoMVQrzTBC&action=employers&q=facebook&ps=1"
        getCompany(url: apiurl) { (results) in
            XCTAssertEqual(results.response.employers[0], savedResult)
        }
        
    }
    
    
    static var allTests = [
        ("testExample", testExample),
        ]
 
    
}
