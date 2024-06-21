//
//  MainView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import Combine
import IHProgressHUD
import SwipeActions
import SwiftData

struct HomeScreenView: View {
    @State var homeScreenViewmodel = HomeScreenViewModel()
    @State var bookmarkViewmodel : BookmarkViewModel
    init(context :ModelContext){
        self._bookmarkViewmodel = State(wrappedValue: BookmarkViewModel(modelContext: context))
    }
    var body: some View {
        ScrollViewReader{reader in
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading){
                    Text(TitleStrings.home_screen_msg.localized)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    
                    TextFieldView(placeholder: .search, text: $homeScreenViewmodel.searchText, isSecureField: false, error: .constant(nil), isFocused: $homeScreenViewmodel.isFocused,rightImage: "xmark")
                        .onChange(of: homeScreenViewmodel.searchText){ text in
                            if text.isEmpty == false{
                                self.homeScreenViewmodel.fetchBooks(more: false)
                            }else{
                                self.homeScreenViewmodel.bookList = []
                            }
                        }
                    if homeScreenViewmodel.isFocused == true{
                        HStack{
                            
                            Text("SortBy :")
                                .font(.body)
                                .fontWeight(.semibold)
                            Spacer()
                            ForEach(SortType.allCases,id:\.rawValue){sortType in
                                SortCell(sortType: sortType,currentSortType: $homeScreenViewmodel.selectedSortType)
                                   
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top,5)
                        .onChange(of: self.homeScreenViewmodel.selectedSortType){newvalue in
                            self.homeScreenViewmodel.sortBooks()
                        }
                        
                        ForEach(self.homeScreenViewmodel.bookList){book in
                                SwipeView{
                                    BookCell(book: book)
                                        .background(
                                            GeometryReader { geo in
                                                Color.clear
                                                    .onAppear {
                                                        
                                                    }
                                                    .onChange(of: geo.frame(in: .global).maxY) { maxY in
                                                        if let lastBook = self.homeScreenViewmodel.bookList.last, lastBook.id == book.id{
                                                            
                                                            if maxY < UIScreen.main.bounds.height {
                                                                self.homeScreenViewmodel.fetchBooks(more: true)
                                                            }
                                                        }
                                                    }
                                            }
                                        )
                                } trailingActions: { _ in
                                   
                                    SwipeAction(systemImage: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}) ? "bookmark.fill" : "bookmark",backgroundColor: Color.blue) {
                                        self.bookmarkViewmodel.addBookmark(book : book,isDelete: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}))
                                    }
                                    .foregroundStyle(.white)
                                    
                                }
                        }
                         
                        if self.homeScreenViewmodel.showMoreLoader{
                            HStack{
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            
                        }
                    }
                    
                }
                .padding(.horizontal)
            }
        }
        .medNavigationBar(.app_name,backIcon: backButtonStyles.none)
        .background(Color.gray.opacity(0.1))
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.blue)
                })
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Text("Logout")
                        .bold()
                        .foregroundStyle(.red)
                })
            }
        }
    }
}


struct SortCell : View {
    var sortType : SortType
    @Binding var currentSortType : SortType
    var body: some View {
        ZStack{
            Text(sortType.rawValue)
                .font(.body)
                .padding(.all,5)
                .background(self.currentSortType == sortType ? Color.blue.opacity(0.3) : .clear)
                .cornerRadius(5)
                .onTapGesture {
                    self.currentSortType = sortType
                }
        }
    }
}


struct BookCell : View {
    var book : BookModel
    var body: some View {
        HStack{
            ZStack{
                Color(.systemGray5)
                AsyncImage(url: URL(string: book.coverImageURl)!) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .scaledToFill()
                            .presentationCornerRadius(10)
                    case .failure(_):
                        if book.coverImageURl == book.nullUrl{
                            Image(systemName: "book")
                                .frame(width: 50, height: 50)
                        }else{
                            ProgressView()
                                .frame(width: 50, height: 50)
                               
                        }
                    @unknown default:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }
                
            }
            .frame(width: 50, height: 50)
            .cornerRadius(10)
            
            VStack(alignment: .leading){
                Text(book.title)
                    .lineLimit(1)
                    .font(.body)
                    .fontWeight(.semibold)
                HStack{
                    Text(book.authorName?.joined(separator: ", ") ?? "")
                        .lineLimit(1)
                        .foregroundStyle(Color(.systemGray4))
                    Spacer()
                    
                    HStack(spacing: 5){
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(String(format: "%.1f", book.ratingAverage ?? 0.0))")
                            .font(.system(size: 14))
                    }
                    
                    HStack(spacing: 5){
                        Image(systemName: "appwindow.swipe.rectangle")
                            .foregroundStyle(.yellow)
                        Text("\(book.ratingsCount ?? 0)")
                            .font(.system(size: 14))
                    }
                    .padding(.leading,5)
                }
            }
            
        }
        .padding(.vertical,12)
        .padding(.horizontal,10)
        .background(Color.white)
        .shadow(color: .gray.opacity(0.2),radius: 5)
        .cornerRadius(10)
    }
}

enum SortType : String,CaseIterable{
    case title = "Title"
    case average = "Average"
    case hit = "Hits"
    
}

extension HomeScreenView{
    @Observable
    class HomeScreenViewModel{
        var searchText : String = ""
        var isFocused : Bool = false
        var selectedSortType : SortType = .title
        var offset = 0
        var bookList : [BookModel] = []
        var showMoreLoader = false
        private var cancellable = Set<AnyCancellable>()
        var isLoading = false
        var totalBooks = 1_000_000_000
       
       
        func fetchBooks(more : Bool){
            if self.searchText.count < 3{
                return
            }
            
            if self.isLoading == true{
                return
            }
            self.isLoading = true
            if more{
                offset += 1
                self.showMoreLoader = true
                if self.bookList.count >= self.totalBooks{
                    self.showMoreLoader = false
                    return
                }
            }else{
                self.bookList = []
                offset = 0
                totalBooks = 1_000_000_000
                self.showMoreLoader = false
                IHProgressHUD.show(withStatus: "Fetching books...")
            }
            
            
          
            print("fetchBooks called",offset)
            Task{
                do{
                    let response : BookResponseModel = try await NetworkManager.shared.fetchDataWithParameters(from: .book_list,queryParams: [
                        "title":self.searchText,
                        "offset":"\(offset)",
                        "limit" : "10"
                    ])
                    
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else { return }
                        self.totalBooks = response.numFound
                        self.bookList.append(contentsOf: response.docs)
                        self.isLoading = false
                        self.sortBooks()
                        IHProgressHUD.dismiss()
                    }
                }catch let err{
                    print("fetchingBookError",String(describing: err))
                    await IHProgressHUD.dismiss()
                }
            }
        }
        
        func sortBooks(){
            switch self.selectedSortType {
            case .title:
                self.bookList = self.bookList.sorted(by: {$0.title < $1.title})
            case .average:
                self.bookList = self.bookList.sorted(by: {
                    if $0.ratingAverage != $1.ratingAverage{
                        return $0.ratingAverage ?? 0 > $1.ratingAverage ?? 0
                    }else{
                        return $0.title < $1.title
                    }
                    
                })
            case .hit:
                self.bookList = self.bookList.sorted(by: {
                    if $0.ratingsCount != $1.ratingsCount{
                        return $0.ratingsCount ?? 0 > $1.ratingsCount ?? 0
                    }else{
                        return $0.title < $1.title
                    }
                    
                })
            }
        }
        
       
    }
}

extension HomeScreenView {
    @Observable
    class BookmarkViewModel{
        var bookmarks : [BookmarkModel] = []
        var modelContext : ModelContext
        init(modelContext : ModelContext){
            self.modelContext = modelContext
           fetchBookmarks()
        }
        func addBookmark(book : BookModel,isDelete : Bool){
            if let email = UserDefaultManager.shared.currentEmail{
                let newBookmark = BookmarkModel(id: book.id, title: book.title, ratingAverage: book.ratingAverage, ratingsCount: book.ratingsCount, authorName: book.authorName, coverImage: book.coverImage, userEmail: email, lastModified: book.lastModified)
                
                if isDelete{
                    self.modelContext.delete(newBookmark)
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
//        HomeScreenView()
//    }
//}
