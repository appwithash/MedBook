//
//  BookLocalModel.swift
//  MedBook
//
//  Created by ashutosh on 21/06/24.
//

import Foundation
import SwiftData

@Model
class BookmarkModel : Identifiable{
    var bookmarkId : String
    var title : String
    var ratingAverage : Double? = nil
    var ratingsCount : Int? = nil
    var authorName : [String]? = nil
    var coverImage : Int? = 0
    var userEmail : String
    var lastModified : Int
    var coverImageURl : String{
        return "https://covers.openlibrary.org/b/id/\(coverImage ?? 0).jpg"
    }
    var nullUrl : String{
        return "https://covers.openlibrary.org/b/id/0.jpg"
    }
    
    init(id: String, title: String, ratingAverage: Double? = nil, ratingsCount: Int? = nil, authorName: [String]? = nil, coverImage: Int? = nil,userEmail : String,lastModified :Int) {
        self.bookmarkId = id
        self.title = title
        self.ratingAverage = ratingAverage
        self.ratingsCount = ratingsCount
        self.authorName = authorName
        self.coverImage = coverImage
        self.userEmail = userEmail
        self.lastModified = lastModified
    }
}
