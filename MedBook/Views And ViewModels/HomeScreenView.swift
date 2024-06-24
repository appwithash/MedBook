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
    @State var homeScreenViewmodel : HomeScreenViewModel
    @State var bookmarkViewmodel : BookmarkViewModel
    @Environment(\.modelContext) private var context
    @AppStorage(UserDefaultsKey.isLoggedIn.rawValue) var isLoggedIn = false
    
    init(context :ModelContext){
        self._bookmarkViewmodel = State(wrappedValue: BookmarkViewModel(modelContext: context))
        self._homeScreenViewmodel = State(wrappedValue: HomeScreenViewModel())
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
                            if homeScreenViewmodel.searchText.count >= 3{
                                self.homeScreenViewmodel.cancelTask()
                                self.homeScreenViewmodel.fetchBooks(more: false)
                            }else{
                                self.homeScreenViewmodel.showPlaceholder = false
                                self.homeScreenViewmodel.cancelTask()
                                self.homeScreenViewmodel.showMoreLoader = false
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
                        if self.homeScreenViewmodel.noSearchResultFound == true{
                            HStack{
                                Spacer()
                                Text("No book found with title - \"\(self.homeScreenViewmodel.searchText)\"")
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                Spacer()
                            }
                        }else{
                            if self.homeScreenViewmodel.showPlaceholder{
                                ForEach(1...10,id:\.self){_ in
                                    BookCell(book: BookModel(title: "", lastModified: 0),urlString : "", image: "bookmark", action: {})
                                        .redacted(reason: .placeholder)
                                }
                            }else{
                                ForEach(self.homeScreenViewmodel.bookList){book in
                                    //                                SwipeView{
                                    BookCell(book: book,urlString : book.coverImageURl,image: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}) ? "bookmark.fill" : "bookmark",action: {
                                        self.bookmarkViewmodel.addBookmark(book : book,isDelete: self.bookmarkViewmodel.bookmarks.contains(where:{$0.lastModified == book.lastModified}))
                                    })
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onChange(of: geo.frame(in: .global).maxY) { maxY in
                                                    if let lastBook = self.homeScreenViewmodel.bookList.last, lastBook.id == book.id{
                                                        
                                                        if maxY < UIScreen.main.bounds.height {
                                                            self.homeScreenViewmodel.fetchBooks(more: true)
                                                        }
                                                    }
                                                }
                                        }
                                    )
                                }
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
        .navigate(using: $homeScreenViewmodel.showBookmarkView, destination: BookMarkListView(context: context))
        .navigate(using: $homeScreenViewmodel.showLandingView, destination: LandingPageView())
       
        .alert(isPresented: $homeScreenViewmodel.showLogoutAlert, content: {
            Alert(
                title: Text(TitleStrings.logout.localized),
                message: Text(TitleStrings.logout_message.localized),
                primaryButton: .default(Text(TitleStrings.no.localized)),
                secondaryButton:  .destructive(Text(TitleStrings.yes.localized)){
                    self.isLoggedIn = false
                    self.homeScreenViewmodel.logout()
                }
            )
        })
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    self.homeScreenViewmodel.showBookmarkView = true
                }, label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.blue)
                })
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                    self.homeScreenViewmodel.showLogoutAlert = true
                }, label: {
                    Text("Logout")
                        .bold()
                        .foregroundStyle(.red)
                })
            }
        }
        .onAppear{
            self.isLoggedIn = true
            if self.homeScreenViewmodel.searchText.isEmpty == false{
                self.homeScreenViewmodel.isFocused = true
            }
            self.bookmarkViewmodel.fetchBookmarks()
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
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel : ImageCacheManager
    @State var pastShown = false
    var image : String
    var action : () -> ()
    init(book: BookModel, urlString: String,image : String, action : @escaping () -> ()) {
        self.book = book
        self._viewModel = State(wrappedValue: ImageCacheManager(url: urlString))
        self.action = action
        self.image = image
    }
    
    @State var offset: CGFloat = 0
    var body: some View {
        ZStack{
            Color.blue
                .overlay(alignment:.trailing,content: {
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .padding(.horizontal,25)
                })
                .foregroundStyle(.white)
                .onTapGesture {
                    self.action()
                    withAnimation(.spring) {
                        offset = 0
                    }
                }
            
            HStack{
                ZStack{
                    if colorScheme == .dark {
                        Color(.systemGray2)
                    }else{
                        Color(.systemGray5)
                    }
                    if let image = viewModel.image{
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .scaledToFill()
                            .presentationCornerRadius(10)
                    }else{
                        if let url = URL(string: viewModel.url){
                            ProgressView()
                                .frame(width: 50, height: 50)
                                .onAppear {
                                    viewModel.load()
                                }
                        }else{
                            Image(systemName: "book")
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
                            .foregroundStyle(colorScheme == .dark ? Color(.white).opacity(0.8) : Color(.systemGray3))
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
            .background(Color("bg"))
            .cornerRadius(10)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        withAnimation(.spring) {
                            if value.translation.width < 0 && value.translation.width >= -100 {
                                offset = value.translation.width
                            }else if value.translation.width > 0{
                                offset = 0
                            }
                        }
                    })
                    .onEnded({ value in
                        if value.translation.width < -80{
                            withAnimation(.spring) {
                                offset = -70
                            }
                        }else if  value.translation.width > 0{
                            withAnimation(.spring) {
                                offset = 0
                            }
                        }else{
                            withAnimation(.spring) {
                                offset = 0
                            }
                        }
                    })
            )
        }
        .frame(maxWidth: .infinity)
        .shadow(color: .gray.opacity(0.2),radius: 5)
        .cornerRadius(10)

    }
}


extension BookCell{
    @Observable
    class ImageCacheManager {
        var image: UIImage?

        private var cancellable: AnyCancellable?
        let url: String
        private let cacheDirectory: URL

        init(url: String) {
         
            self.url = url

            // Define the cache directory path
            let fileManager = FileManager.default
            if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                self.cacheDirectory = cacheDirectory
            } else {
                self.cacheDirectory = fileManager.temporaryDirectory
            }
        }

        func load() {
            guard let url = URL(string: self.url) else {return}
           
            let cacheFileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

            if let cachedImage = UIImage(contentsOfFile: cacheFileURL.path) {
                self.image = cachedImage
            } else {
                cancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .map { UIImage(data: $0.data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] downloadedImage in
                        guard let self = self, let image = downloadedImage else { return }
                        self.image = image
                        self.saveToCache(image: image, url: cacheFileURL)
                    }
            }
        }

        private func saveToCache(image: UIImage, url: URL) {
            guard let data = image.pngData() else { return }
            try? data.write(to: url)
        }
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
        var showBookmarkView = false
        var showLandingView = false
        var showLogoutAlert = false
        var showPlaceholder = false
        private var currentTask: Task<Void, Never>?
        var noSearchResultFound = false
        func fetchBooks(more : Bool){
            if self.searchText.count < 3{
                return
            }
           
            if more == true && self.isLoading == true{
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
                self.showPlaceholder = true
                self.bookList = []
                offset = 0
                totalBooks = 1_000_000_000
                self.showMoreLoader = false
               
            }
            self.noSearchResultFound = false
            currentTask = Task{
                do{
                    let response : BookResponseModel = try await NetworkManager.shared.fetchDataWithParameters(from: .book_list,queryParams: [
                        "title":self.searchText,
                        "offset":"\(offset)",
                        "limit" : "10"
                    ])
                    
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else { return }
                        
                        if self.searchText.isEmpty {
                            self.bookList = []
                            self.totalBooks = 0
                        }else{
                            self.totalBooks = response.numFound
                            for book in response.docs{
                                if self.bookList.contains(where: {$0.lastModified == book.lastModified}) == false{
                                    self.bookList.append(book)
                                }
                                self.sortBooks()
                            }
                            if self.bookList.isEmpty{
                                self.noSearchResultFound = true
                            }else{
                                self.noSearchResultFound = false
                            }
                            print("\nbooklist",response.docs.map({$0.title}))
                            print("\n=========================================\n")
                          
                        }
                        self.isLoading = false
                        self.showPlaceholder = false
                    }
                }catch let err{
                    if err.localizedDescription == "cancelled"{
                        print("fetchBooks task was cancelled")
                    } else {
                        print("fetchingBookError",String(describing: err))
                        
                        self.isLoading = false
                        self.showPlaceholder = false
                    }
                    
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
        
        func logout(){
            var transaction = Transaction()
            transaction.disablesAnimations = true
//            withTransaction(transaction) {
//                self.showLandingView = true
//            }
            UserDefaultManager.shared.logout()
        }
        
        func cancelTask(){
            self.currentTask?.cancel()
        }
       
    }
}

extension HomeScreenView {

    @Observable
    class BookmarkViewModel{
        var bookmarks : [BookmarkModel] = []
        var modelContext : ModelContext
        private var cancellable = Set<AnyCancellable>()
        init(modelContext : ModelContext){
            self.modelContext = modelContext
           
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
//        HomeScreenView()
//    }
//}
