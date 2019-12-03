//
//  Model.swift
//  ZhiHu2.0
//
//  Created by 游奕桁 on 2019/11/28.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Foundation


//MARK: Story
typealias JSONDictionary = [String: AnyObject]

enum ParseError: Error {
    case missingAttribute(message: String)
}


protocol JSONParsable {
    static func parse(json: JSONDictionary) throws -> Self
}

struct Story: BannerViewDataSource {
    var id: Int
    var title: String
    var thumbNailURLString: String
    var storyURL: String {
        return "https://news-at.zhihu.com/api/4/news/\(id)"
    }
    var thumbNailURL: URL {
        return URL(string: thumbNailURLString.replacingOccurrences(of: "http", with: "https"))!
    }
    init(id: Int, title: String, thumbNailURL: String) {
        self.id = id
        self.title = title
        self.thumbNailURLString = thumbNailURL
    }
    var bannerTitle: String {
        return title
    }
    var bannerimageURL: URL? {
        return URL(string: thumbNailURLString.replacingOccurrences(of: "http", with: "https"))
    }
    var bannerImage: UIImage? {
        return nil
    }
}
extension Story: JSONParsable {
    
    static func parse(json: JSONDictionary) throws -> Story {
        guard let title = json["title"] as? String else {
            throw ParseError.missingAttribute(message: "Expected stories String")
        }
        
        guard let id = json["id"] as? Int else {
            throw ParseError.missingAttribute(message: "Expected id Int")
        }
        
        guard let thumbNailURL = (json["images"] as? [String])?.first ?? json["image"] as? String else {
            throw ParseError.missingAttribute(message: "Expected image urlString")
        }
        
        return Story(id: id,
                     title: title,
                     thumbNailURL: thumbNailURL
        )
    }
}
//MARK: News
struct News {
    var dateString: String
    var stories: [Story]
    var topStories: [Story]?
    
    init(dateString: String, stories: [Story], topStories: [Story]) {
        self.stories = stories
        self.topStories = topStories
        self.dateString = dateString
    }
    
    static var latestNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/latest")!
    }
    
    var previousNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/before/\(dateString)")!
    }
}



extension News: JSONParsable {
    
    static func parse(json: JSONDictionary) throws -> News {
        guard let dateString = json["date"] as? String else {
            let message = "Expected date String"
            throw ParseError.missingAttribute(message: message)
        }
        
        guard let storyDicts = json["stories"] as? [JSONDictionary] else {
            let message = "Expected stories String"
            throw ParseError.missingAttribute(message: message)
        }
        
        var topStories: [Story]?
        if let topStoryDicts = json["top_stories"] as? [JSONDictionary] {
            topStories = try topStoryDicts.map { (json) -> Story in
                return try Story.parse(json: json)
            }
        }
        
        
        // Handle Stories
        let stories = try storyDicts.map { (json) -> Story in
            return try Story.parse(json: json)
        }
        
        return News(dateString: dateString,
                    stories: stories,
                    topStories: topStories!)
    }
}
