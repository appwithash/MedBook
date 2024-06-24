//
//  BookMarkListView.swift
//  MedBook
//
//  Created by ashutosh on 21/06/24.
//

import SwiftUI
import SwiftData
import SwipeActions

struct BookMarkListView: View {
    
    @State var bookmarkViewmodel : BookmarkViewModel
    
    init(context :ModelContext){
        self._bookmarkViewmodel = State(wrappedValue: BookmarkViewModel(modelContext: context))
    }
    
    var body: some View {
        VStack{
            ScrollView(showsIndicators:false){
                ForEach(self.bookmarkViewmodel.bookList){ book in
                   
                    BookCell(book: book, urlString: book.coverImageURl,image: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}) ? "bookmark.fill" : "bookmark", action: {
                        self.bookmarkViewmodel.addBookmark(book : book,isDelete: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}))
                    })
                    
                }
                .padding(.top)
                .padding(.horizontal)
            }
        }
        .medNavigationBar(.bookmarks)
       
        .background(Color.gray.opacity(0.1))
    }
    
    
}

extension BookMarkListView {
    @Observable
    class BookmarkViewModel{
        var bookmarks : [BookmarkModel] = []
        var bookList : [BookModel]  {
            return bookmarks.map({BookModel(id: $0.bookmarkId, title: $0.title, ratingAverage: $0.ratingAverage, ratingsCount: $0.ratingsCount, authorName: $0.authorName, coverImage: $0.coverImage, lastModified: $0.lastModified)})
        }
        var modelContext : ModelContext
        init(modelContext : ModelContext){
            self.modelContext = modelContext
           fetchBookmarks()
        }
        func addBookmark(book : BookModel,isDelete : Bool){
            if let email = UserDefaultManager.shared.currentEmail{
                let newBookmark = BookmarkModel(id: book.id, title: book.title, ratingAverage: book.ratingAverage, ratingsCount: book.ratingsCount, authorName: book.authorName, coverImage: book.coverImage, userEmail: email, lastModified: book.lastModified)
                
                if isDelete{
                    if let bookmark = self.bookmarks.first(where: {$0.lastModified == book.lastModified}){
                        self.modelContext.delete(bookmark)
                    }
                    
                    print("deleted bookmark")
                }else{
                    self.modelContext.insert(newBookmark)
                    print("added bookmark")
                }
                fetchBookmarks()
            }
        }
        
        func fetchBookmarks(){
            do {
                if let currentEmail = UserDefaultManager.shared.currentEmail{
                    let predicate = #Predicate { (bookmark: BookmarkModel) in
                       bookmark.userEmail == currentEmail
                    }
                    let descriptor = FetchDescriptor<BookmarkModel>(predicate: predicate,sortBy: [SortDescriptor(\.title)])
                    self.bookmarks = try modelContext.fetch(descriptor)
                    print("bookmark fetched",bookmarks.map({$0.title}))
                }
                
            } catch {
                print("Fetch failed fetchCountriesFromLocalStorage")
            }
        }
        
    }
}



//#Preview {
//    NavigationStack{
//        BookMarkListView()
//    }
//}
