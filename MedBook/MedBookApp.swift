//
//  MedBookApp.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import SwiftData

@main
struct MedBookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for:[CountryModel.self, User.self, BookmarkModel.self])
       
    }
}
