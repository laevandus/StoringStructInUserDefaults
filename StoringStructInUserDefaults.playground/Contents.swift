import UIKit

struct Context: Codable {
    let duration: TimeInterval
    let view: String
}

struct SearchInfo: Codable {
    let query: String
    let numberOfMatches: Int
    let context: Context
}

let searchInfos = [SearchInfo(query: "query1", numberOfMatches: 1, context: Context(duration: 1.0, view: "view1")),
                   SearchInfo(query: "query2", numberOfMatches: 2, context: Context(duration: 2.0, view: "view2"))]

// Converting to dictionary
extension SearchInfo {
    var dictionaryRepresentation: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
    }
}

// Converting back to struct
extension SearchInfo {
    init?(dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
        guard let info = try? JSONDecoder().decode(SearchInfo.self, from: data) else { return nil }
        self = info
    }
}

let defaults = UserDefaults()

// [Struct] -> [Dictionary]
let searchInfoDictionaries = searchInfos.map({ $0.dictionaryRepresentation })

// [Dictionary] to UserDefaults
defaults.set(searchInfoDictionaries, forKey: "Searches")

// [Dictionary] from UserDefaults
let dictionariesFromUserDefaults = defaults.array(forKey: "Searches")! as! [[String: Any]]

// [Dictionary] -> [Struct]
let convertedSearchInfos = dictionariesFromUserDefaults.compactMap({ SearchInfo(dictionary: $0) })

print("Struct")
print(searchInfos)

print("Struct -> Dictionary -> Struct")
print(convertedSearchInfos)

// Generalizing the implementation
protocol DictionaryConvertible {
    var dictionaryRepresentation: [String: Any] { get }
}

extension DictionaryConvertible where Self: Encodable {
    var dictionaryRepresentation: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
    }
}

protocol DictionaryDecodable {
    init?(dictionary: [String: Any])
}

typealias DictionaryRepresentable = DictionaryConvertible & DictionaryDecodable

struct AutocompleteResult: Codable {
    let text: String
    let suggestions: [String]
}

extension AutocompleteResult: DictionaryRepresentable {
    init?(dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
        guard let info = try? JSONDecoder().decode(AutocompleteResult.self, from: data) else { return nil }
        self = info
    }
}

let result = AutocompleteResult(text: "text1", suggestions: ["result1", "result2"])
let dictionary = result.dictionaryRepresentation
let convertedResult = AutocompleteResult(dictionary: dictionary)!
print(result)
print(convertedResult)
