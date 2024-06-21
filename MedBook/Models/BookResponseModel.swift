//
//  BookResponseModel.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation


struct BookResponseModel : Codable{
    var numFound : Int
    var docs : [BookModel]
    enum CodingKeys: String, CodingKey {
        case docs
        case numFound
    }
}

struct BookModel : Codable,Identifiable{
    var id = UUID().uuidString
    var title : String
    var ratingAverage : Double? = nil
    var ratingsCount : Int? = nil
    var authorName : [String]? = nil
    var coverImage : Int? = 0
    var lastModified : Int
    var coverImageURl : String{
        return "https://covers.openlibrary.org/b/id/\(coverImage ?? 0).jpg"
    }
    var nullUrl : String{
        return "https://covers.openlibrary.org/b/id/0.jpg"
    }
    enum CodingKeys: String, CodingKey {
        case title
        case ratingAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case authorName = "author_name"
        case coverImage = "cover_i"
        case lastModified = "last_modified_i"
    }
}
