// Hyoungsun (Stanley Park)


import Foundation

/// The repo data we will decode from JSON results
struct GlassdoorCompany: Codable {
    let success: Bool
    let status: String
    let response: CompanySubStruct
}
/// Below are custom structs for processing JSON objects from Glassdoor api
struct CompanySubStruct: Codable {
    let totalRecordCount: Int
    let employers: [CompanyDetails]
}
struct CompanyDetails: Codable, CustomStringConvertible, Equatable, Comparable {
    let name: String
    let industryName: String?
    let website: URL
    let numberOfRatings: Int
    let ratingDescription: String
    let seniorLeadershipRating: String
    let compensationAndBenefitsRating: String
    let careerOpportunitiesRating: String
    let workLifeBalanceRating: String
    let overallRating: String
    let featuredReview: CompanyReview
}
/// CompanyDetails conforming protocols
extension CompanyDetails {
    static func == (companyA: CompanyDetails, companyB: CompanyDetails) -> Bool {
        return companyA.name == companyB.name && companyA.website == companyB.website
    }
    
    static func < (companyA: CompanyDetails, companyB: CompanyDetails) -> Bool {
        return companyA.numberOfRatings < companyB.numberOfRatings
    }
    
    var description: String {
        if let industry = companyOverview?.industryName {
            return "\n>>> \(name)'s wesite is 🌍 \(website) \n>>> \(name) is in \(industry) industry 🙌🏻"
        } else {
            return "\n>>> \(name)'s wesite is 🌍 \(website) \n>>> \(name) is not identifiable in Glassdoor api 😜"
        }
    }
}

struct CompanyReview: Codable {
    let location: String
    let headline: String
    let pros: String
    let cons: String
}
/// QuestionType Enum for prompting different questions for users
enum QuestionType {
    case searchNewCompany
    case getProsAndCons
    case getWorkLifeBalance
    case getRatingDetail
    case getStanleyRating
    case askExit
}

var companyOverview: CompanyDetails?
var companyReview: CompanyReview?

/// Helper functions that connects different questions
func promptUserWithQuestion(_ question: String, questionType: QuestionType) {
    print(question)
    let newInput = readLine()
    if newInput == "y" {
        switch questionType {
        case .searchNewCompany:
            askUser()
        case .getProsAndCons:
            askUserProCon()
        case .getWorkLifeBalance:
            askUserOverallRating()
        case .getRatingDetail:
            askUserRatingDetail()
        case .getStanleyRating:
            askUserStanleyRating()
        case .askExit:
            askUserExit()
        }
    } else if newInput == "n" {
        print("Ok! We'll be always ready for your dream career!")
        exit(0)
    } else {
        print("Ok! We'll be always ready for your dream career!")
        exit(0)
    }
}

func askUser() {
    var success: Bool = false
    /// First msg that presents to users
    print("Welcome to Stanley's Career Search! (feat. Glassdoor api)")
    welcomeMsg()
    let firstPromptMsg = """
    What company do you want to search? Enter [help] for more information OR Enter Company Name (e.g. Uber, Facebook, Trunk Club etc.):
    """
    print(firstPromptMsg)
    let userInput = readLine()
    if let nonOptionalInput = userInput {
        
        if nonOptionalInput == "" {
            print("ERROR: ⛔️ You haven't entered anything.")
            askUser()
        } //// in case an user wants to know instructions
        else if nonOptionalInput == "help"{
            let helpMsg = """

            ****************************************************************************************************
            🔎 Stanley's Career Search is a custom employer information search engine where users can look into
            a company's information such as website, ratings, reviews, locations, and pros/cons, etc.
            Also, based on a company's leadership, compensation, career opportunities, and work-life balance,
            It will provide a company's overall rating with 100 scale for your reference. And you can exit whenever
            you want. so, please feel free to search until you are willing to.
            Please enjoy searching your dream companies!
            ****************************************************************************************************

            """
            print(helpMsg)
            askUser()
        } else {
            let employerName: String = nonOptionalInput.replacingOccurrences(of: " ", with: "-")
            /// URL string that corresponds to the web api
            let urlString = "http://api.glassdoor.com/api/api.htm?v=1&format=json&t.p=233892&t.k=CoMVQrzTBC&action=employers&q=\(employerName)&ps=1"
            
            //// getCompany function (also available in networking.swift) including tailing closures
            getCompany(url: urlString) { (information) in
                /// in case the company that an user typed is not available in the Glassdoor api
                if information.response.employers.count == 0 {
                    print("There is no company named '\(nonOptionalInput)' 😅")
                    success = false
                } else {
                
                    for company in information.response.employers {
                        /// Instead of calling getcompany() function, once it gets information, it will be stored in the structs above
                        companyReview = CompanyReview(location: company.featuredReview.location, headline: company.featuredReview.headline, pros: company.featuredReview.pros, cons: company.featuredReview.cons)
                        
                        companyOverview = CompanyDetails(name: company.name, industryName: company.industryName, website: company.website, numberOfRatings: company.numberOfRatings, ratingDescription: company.ratingDescription, seniorLeadershipRating: company.seniorLeadershipRating, compensationAndBenefitsRating: company.compensationAndBenefitsRating, careerOpportunitiesRating: company.careerOpportunitiesRating, workLifeBalanceRating: company.workLifeBalanceRating, overallRating: company.overallRating, featuredReview: companyReview!)
                        
                        print(company)
                        print("\n[Featured Headline]: 💡 \"\(companyReview!.headline)\"")
                        
                        if companyReview?.location.count == 0 {
                            print("\n\(company.name) is located at 📍 various place in the States")
                        } else {
                            print("\n\(company.name) is located at 📍 \(companyReview!.location)")
                        }
                        success = true
                    }
                }
                if success == true {
                    promptUserWithQuestion("\nDo you want to find out the company's pros and cons? Enter: [y] for Continue [n] Exit", questionType: .getProsAndCons)
                } else {
                    askUser()
                }
            }
            
        }
    } else {
        print("It should never go here")
    }
}
/// For providing pros/cons of a company
func askUserProCon() {
    print("\n>>> Pros: 😃 \(companyReview!.pros) \n>>> Cons: 😭 \(companyReview!.cons)")
    
    promptUserWithQuestion("\nDo you want to find out the company's overall balance rating? Enter: [y] for Continue [n] for Exit", questionType: .getWorkLifeBalance)
}

/// For presting a overall rating and the number of reviews gotten from the employees.
func askUserOverallRating() {
    let rating: Double = Double(companyOverview!.overallRating)!
    let convertStar: Int = Int(rating)
    print("\n\(companyOverview!.name) has received \(companyOverview!.numberOfRatings) rating reviews from its employees. And Overall Glassdoor Company Rating ↓: ")
    for _ in 0..<convertStar {
        print("⭐️", terminator: "")
    }
    print(" out of ⭐️⭐️⭐️⭐️⭐️")
    
    promptUserWithQuestion("\nDo you want to know more detail about the company's rating by category? Enter: [y] for Continue [n] for Exit", questionType: .getRatingDetail)
}

func askUserRatingDetail() {
    var ratingDetails:[String: Double] = [:]
    /// Store rating descriptions and ratings score
    ratingDetails["Senior Leadership"] = Double(companyOverview!.seniorLeadershipRating)
    ratingDetails["Compensation Benefit"] = Double(companyOverview!.compensationAndBenefitsRating)
    ratingDetails["Career Opportunities"] = Double(companyOverview!.careerOpportunitiesRating)
    ratingDetails["Work-Life Balance"] = Double(companyOverview!.workLifeBalanceRating)
    
    /// Sorting the four rating by descending order
    let sortedOutput:[(String, Double)] = ratingDetails.sorted(by: { $0.value > $1.value })
    
    for (key, value) in sortedOutput {
        print("\(key) : \(value) / 5.0")
    }
    
    promptUserWithQuestion("\nOk Now do you want to get a custom Stanley Rating (scale of 100) for the company? Enter: [y] for Continue [n] for Exit", questionType: .getStanleyRating)
    
}

func askUserStanleyRating() {
    /// Give weighting for each category of the ratings
    let ledership = Double(companyOverview!.seniorLeadershipRating)! * 1.05
    let compensation = Double(companyOverview!.compensationAndBenefitsRating)! * 1.2
    let careerOpportunities = Double(companyOverview!.careerOpportunitiesRating)! * 1.25
    let workLife = Double(companyOverview!.workLifeBalanceRating)! * 1.1
    let ratingArray: [Double] = [ledership, compensation, careerOpportunities, workLife]
    
    /// higer order functions for presenting a company's custom rating (out of 100)
    let ratingScale100 = ratingArray.reduce(0, { x, y in
        x + (y * 5)
    })
    
    print("The Stanley Rating for this company is .... \(ratingScale100) / 100.00 👀")
    askUserExit()
}
/// Last question that asks users if they want to search more companies
func askUserExit() {
    print("\nOK! I hope you enjoyed our search engine, Enter: [y] for Searching More Companies [n] for Exit Now")
    let newInput = readLine()
    if newInput == "y" {
        askUser()
    } else if newInput == "n" {
        print("Ok! Hope you had a good time! We'll be always ready for your dream career!")
        exit(0)
    } else {
        print("Ok! Hope you had a good time! We'll be always ready for your dream career!")
        exit(0)
    }
}
/// Cool asciII text
func welcomeMsg() {
    let welcomeMsg = """

 d888b  db       .d8b.  .d8888. .d8888. d8888b.  .d88b.   .d88b.  d8888b.
88' Y8b 88      d8' `8b 88'  YP 88'  YP 88  `8D .8P  Y8. .8P  Y8. 88  `8D
88      88      88ooo88 `8bo.   `8bo.   88   88 88    88 88    88 88oobY'
88  ooo 88      88~~~88   `Y8b.   `Y8b. 88   88 88    88 88    88 88`8b
88. ~8~ 88booo. 88   88 db   8D db   8D 88  .8D `8b  d8' `8b  d8' 88 `88.
 Y888P  Y88888P YP   YP `8888Y' `8888Y' Y8888D'  `Y88P'   `Y88P'  88   YD

"""
    print(welcomeMsg)
}

askUser()
dispatchMain()




