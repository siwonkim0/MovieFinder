# MovieFinder
1. 프로젝트 기간

2022.05.13 ~ 진행중

2. 구현 내용  

API: [TMDB API](https://developers.themoviedb.org/3/)  
OAuth를 이용한 로그인을 통해 영화 상세정보에서 평점을 등록할 수 있고 최신 상영작, 인기작 등의 다양한 영화 목록을 제공하며, 영화 검색기능을 가진 앱

# Coordinator Pattern을 이용한 화면전환
<img width="501" alt="스크린샷 2022-09-03 오전 10 59 32" src="https://user-images.githubusercontent.com/60725934/188251530-e5071fe7-98c9-41e9-ba8c-0c9adc15a7a6.png">

### 구현 내용

TabBarController을 AppCoordinator가 가지고 있고, 화면전환 로직을 뷰컨트롤러에서 분리해서 Coordinator가 대신해주도록 구현하였다.

```swift
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start() -> UINavigationController
}
```

- AppCoordinator의 역할
    - SceneDelegate에서 window를 주입받아서 로그인 여부에 따라 rootViewController를 다르게 설정해주는 역할
    - 세개의 NavigationController을 TabBarController에 담아 생성
    - DetailViewController 생성: 영화 id만 넘겨주면 어느 맥락에서나 같은 DetailViewController로 전환
- 각각의 Coordinator들의 역할
    - 자신이 가진 NavigationController에 ViewController를 담아 AppCoordinator에게 전달

### 트러블 슈팅
coordinator 패턴에서 가장 중요한 부분은 참조를 관리하는 것임을 느꼈다.

### AppCoordinator가 메모리에서 바로 해제되는 문제

- 문제 상황
SceneDelegate의 `func scene(_, willConnectTo:)` 메서드에서 AppCoordinator를 생성해 주었는데 함수 실행이 종료되고 나서 참조 카운트가 0이 되어 메모리에서 바로 해제됨

- 해결
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?
}

class AuthCoordinator: Coordinator {
    weak var parentCoordinator: AuthCoordinatorDelegate?
}
```

SceneDelegate의 프로퍼티로 AppCoodinator을 가지고 있어 메모리에서 내려가지 않도록 수정하였다.

### 로그인 화면이 사라졌는데도 AuthViewController가 메모리에서 해제되지 않는 현상

- 문제 상황
로그인이 완료되면, `AuthViewController`의 viewDidDisappear에서 `AuthCoordinator`에게 알리고, 궁극적으로 AppCoordinator가 자신이 가지고 있는 childCoordinators 배열에서 AuthCoordinator을 제거하여 AppCoordinator가 가진 AuthCoordinator의 참조를 해제해주어도 AuthViewController가 메모리에서 해제되지 않았다. 

<img width="190" alt="스크린샷 2022-09-03 오전 11 00 28" src="https://user-images.githubusercontent.com/60725934/188251550-4388cdfe-e95c-471b-a792-3f437a47c7f8.png">

```swift
//AuthViewController
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    coordinator?.didFinishLogin()
}

//AuthCoordinator
func didFinishLogin() {
    parentCoordinator?.childDidFinish(self)
}

//AppCoordinator
func childDidFinish(_ child: Coordinator) {
    for (index, coordinator) in childCoordinators.enumerated() {
        if coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
}
```

- 해결 방법

AuthCoordinator가 navigationController를 가지고 있고, navigationController가 `AuthViewController`를 가지고 있는데 AuthViewController가 coordinator을 강하게 참조하고 있어서 강한 순환 참조 문제가 생겼다.

따라서, AuthViewController가 coordinator을 약하게 참조하도록 변경하여 AppCoordinator의 참조가 해제되면 메모리에서 해제되도록 변경하였다.

```swift
final class AuthViewController: UIViewController {
    weak var coordinator: AuthViewControllerDelegate?
}
```

---

# 네트워크 코드 추상화

### 구현 내용

- urlsession을 generic으로 구현하여 모든 API가 공통적으로 사용할 수 있도록 구현
- API 요청목록을 명시한 프로토콜을 채택하여 쉽게 요청사항을 파악할 수 있다

```swift
func performDataTask<T: NetworkRequest>(with requestType: T) -> Observable<T.ResponseType> {
```

```swift
protocol NetworkRequest {
    associatedtype ResponseType: Decodable
    var httpMethod: HttpMethod { get }
    var urlHost: String { get }
    var urlPath: String { get }
    var queryParameters: [String: String] { get }
    var httpHeader: [String: String]? { get }
    var httpBody: Data? { get }
}
```

# 이미지 처리

### 구현 내용

영화 포스터 이미지가 주를 이루는 앱이다보니 앱 성능 향상을 위한 이미지 처리에 대한 많은 고민을 했다.

CollectionView에서 이미지를 로딩할때 고려해야 할 사항 다음 두가지이다.

1. 이미지 로딩 속도가 느리고, 메모리 사용량이 급격하게 늘어나는 현상
2. 스크롤시 이미지가 깜빡거리면서 바뀌기도 하는 현상

이를 해결하기 위해 아래 두가지 방법을 사용하였다.

- Cache
- Downsampling

### 트러블 슈팅

### UICollectionView 빠르게 스크롤하면 잘못된 이미지가 나타나는 현상

- 문제 상황

셀이 재사용되고, 이미지 로딩 작업이 비동기적으로 작동하여 작업이 끝나는 순서를 보장하지 못한다. 셀이 재사용되면서 새로운 이미지가 로딩되기 전에 기존 이미지가 보여지기도 하고, 새로운 이미지가 로딩되고 나서 그제서야 재사용 전의 기존 이미지가 보여지는 현상이 발생하였다.

[블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%85%80-%EC%9E%AC%EC%82%AC%EC%9A%A9-%EB%AC%B8%EC%A0%9C-%EB%B9%A0%EB%A5%B4%EA%B2%8C-%EC%8A%A4%ED%81%AC%EB%A1%A4%EC%8B%9C-%EC%9E%98%EB%AA%BB%EB%90%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80%EA%B0%80-%EB%82%98%ED%83%80%EB%82%98%EB%8A%94-%ED%98%84%EC%83%81)

- 해결

셀이 재사용 큐에 들어가기전에 불리는 prepareForResue를 오버라이드해서 

1. imageView.image = nil을 해서 재사용되기 전에 imageView가 가진 image를 초기화하고 
2. 만약 재사용 전 이미지가 다운로드되지 않았다면 이미지 다운로드를 취소한다.

### 이미지 로딩 속도 개선하기

**디스크 캐싱 vs 메모리 캐싱?**

ListView에서는 현재상영작, 인기작 등의 목록을 보여주는데 이 목록은 자주 바뀌지 않는 목록이다.  
또한 ListView에서 셀을 터치하면 보여지는 DetailView에서는 동일한 영화 포스터 이미지를 받아온다.  
같은 이미지를 여러번 보여줘야하는 상황에서 네트워크 통신을 통해 매번 이미지를 받아오지 않고 캐시를 통해서 메모리나 디스크에 저장해둔 이미지를 로딩했다.  
이때 디스크 캐싱과 메모리 캐싱 중 어떤 것을 해야하는지 고민이 되었는데,
- 디스크 캐싱을 할 경우에 사용자가 앱을 종료했다가 다시 켜도 저장된 캐시가 남아있고
- 메모리 캐싱을 할 경우에는 앱을 사용하는 동안 같은 이미지를 다시 조회했을때 메모리에 저장된 캐시 이미지를 보여줄 수 있다.

결론적으로 Kingfisher을 이용하여 디스크, 메모리 캐싱 두가지를 다 적용했다.  
이미지 downsampling 후에 원본 이미지는 디스크에 저장하고, downsampling된 이미지는 메모리에 저장하여 다른 사이즈로 downsampling해야할 경우에는 디스크에 저장된 원본 이미지를 불러와서 가공한다.

[블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%85%80%EC%9D%98-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EB%A1%9C%EB%94%A9-%EC%86%8D%EB%8F%84-%EA%B0%9C%EC%84%A0-NSCache%EB%A1%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%BA%90%EC%8B%B1)

### 이미지 downsampling을 통한 메모리 사용량 줄이기

- 문제 상황  
검색 결과를 UICollectionView에 표시할때 원본 이미지의 크기가 큰 경우에 원본 이미지를 그대로 가져오면 메모리를 많이 사용하게 된다.  
원본 이미지를 그대로 저장하는 경우 메모리 사용량이 급격하게 늘어난다.

<img width="638" alt="스크린샷 2022-09-03 오후 4 44 33" src="https://user-images.githubusercontent.com/60725934/188261323-371a386e-0086-4747-af27-520c794f7cf4.png">

- 해결 방법  
UIImage가 이미지를 decoding한 후에는 decoding된 이미지를 메모리에 저장해놓기 때문에 원본 decoding 후에 이미지 사이즈를 줄이는 resizing은 성능 향상에 아무런 도움이 되지 않는다. 따라서 decoding 전에 data buffer 자체의 사이즈를 줄이는 downsampling을 진행하였다.

```swift
func downSample(at url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, imageSourceOptions) else {
        return
    }
    
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
    let downsampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as CFDictionary
    
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
        return UIImage()
    }
    return UIImage(cgImage: downsampledImage)
}
```



downsampling을 한 결과 메모리 사용량이 1/5로 줄었다.

<img width="636" alt="스크린샷 2022-09-03 오후 4 44 11" src="https://user-images.githubusercontent.com/60725934/188261306-98ca9e66-8c6d-40d6-97ac-156c7b1d51e5.png">

WWDC 19 ****Image and Graphics Best Practices**** [블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%B2%98%EB%A6%AC-downsampling)

# AuthViewController

### 구현 내용

- 사용자가 계정 생성 버튼 터치시 token을 발급받아 url을 생성하여 외부 계정 생성 화면으로 보냄
- 사용자가 URL에서 로그인을 하고 앱으로 돌아오면
- `sceneWillEnterForground` 이벤트를 받아 앱이 Background에서 Foreground로 진입할때
    - 사용자가 인증한 토큰으로 session id를 생성하여 `KeyChain`에 민감한 사용자 정보인 Session id 저장 후
    - session id가 정상적으로 생성되었다면 자동으로 메인화면으로 화면전환

### 트러블 슈팅

### 인증 에러가 발생하면 스트림이 끊어지는 현상 해결

- 문제 상황
    
    사용자가 외부 링크에서 로그인을 하지 않고 앱으로 다시 돌아오면 토큰이 인증되지 않아서 session id를 발급받을 수 없어 401에러가 발생하여 Observable 스트림이 종료되는 현상이 발생하였다.
    
- 해결

RxSwift의 에러 핸들링 방법에는 두가지가 있는데, 

1. 에러를 단순히 catch해서 에러 대신 next 이벤트를 내려보내는 방법과 
2. 다시 시도하는 방법이 있다.

```swift
output.didSaveSessionId
    .retry()
    .observe(on: MainScheduler.instance)
    .subscribe(with: self, onNext: { (self, _) in
        self.coordinator?.showTabBarController(at: self)
    }).disposed(by: disposeBag)
```

- 2번 방법으로 `retry()` 를 추가하여 에러가 발생해도 스트림이 종료되지 않게 `sceneWillEnterForground` 이벤트 발생시 session id 생성을 다시 시도하도록 설정하였다.

# ListViewController

### 구현 내용
- collectionViewCompositionalLayout 사용  
기존에는 하나의 ViewController에 여러개의 CollectionViewController를 child로 가지도록 구성했다  
그러나 이 방법은 필요 없는 viewController를 여러개 생성하여 성능상 좋지 않다고 판단하여  
collectionViewCompositionalLayout으로 section을 활용하여 리팩토링하였다.

- section이 추가되어도 쉽게 데이터를 추가할 수 있도록 구성  
현재는 now playing, popular, top rated, upcoming으로 이루어진 4개의 Section으로 구성되었지만,  
나중에 새로운 Section을 추가하고 싶을 때 변경에 유연하도록 설계해보았다.  
HomeMovieLists enum으로 Section을 관리하여 enum에 새로운 case를 추가하여 손쉽게 새로운 Section을 만들 수 있다.

```swift
struct MovieList: Hashable {
    let page: Int
    let items: [MovieListItem]
    let totalPages: Int
    var section: HomeMovieLists? = nil
    
    var nextPage: Int? {
        let nextPage = self.page + 1
        guard nextPage < self.totalPages else {
            return nil
        }
        return nextPage
    }
}

enum HomeMovieLists: CaseIterable {
    case nowPlaying
    case popular
    case topRated
    case upComing
    
    var title: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Rated"
        case .upComing:
            return "Upcoming"
        }
    }
}

//DefaultMoviesUseCase
func getMovieLists() -> Observable<[MovieList]> {
    let lists: [HomeMovieLists: String] = [
        .nowPlaying: "movie/now_playing?",
        .popular: "movie/popular?",
        .topRated: "movie/top_rated?",
        .upComing: "movie/upcoming?"
    ]
    let genresList = moviesRepository.getGenresList()
    let movieLists = lists.map { (section, posterPath) -> Observable<MovieList> in
        let movieList = moviesRepository.getMovieList(with: posterPath)
        return makeMovieLists(genresList: genresList, movieList: movieList)
            .map { list in
                return MovieList(
                    page: list.page,
                    items: list.items,
                    totalPages: list.totalPages,
                    section: section
                )
            }
    }
    return Observable.zip(movieLists) { $0 }
}
```

# SearchViewController

### 구현내용  
SearchBar에 글자를 입력할때마다 Api 호출하고, 스크롤을 내려 스크롤이 일정 범위에 도달하면 다음 페이지를 불러오는 pagination 기능을 구현하였다  
사용자가 글자를 입력하고 0.5초가 지난 다음에 Api 호출을 하여 성능을 최적화하였다.

### input - output 구조  
현재 SearchBarViewController에는 세가지의 input과 하나의 output이 존재한다.

```swift
struct Input {
    let searchBarText: Observable<String>
    let searchCancelled: Observable<Void>
    let loadMoreContent: Observable<Bool>
}

struct Output {
    let searchResults: Driver<[SearchCellViewModel]>
}
```

### **viewModel에서 subscribe를 하는 것**

viewModel에 검색 결과를 가지고 있는 BehaviorRelay를 두고  
위 세가지의 input이 들어오면 api 호출 결과를 searchResults에 accept로 전달한다.  
그리고 searchResults BehaviorRelay를 Driver로 output에 전달한다.

물론 세 input에 대해 각각 output을 생성하여 viewcontroller에 보낸다면 stream이 끊어지지 않고 viewcontroller에서 subscribe를 할수도 있겠지만,  
이렇게 구현한 이유는 세 input은 모두 같은 타입의 output을 리턴하고, output에 대해서는 diffable datasource의 snapshot에 apply하는 같은 처리를 해주고 있기 때문에 중복 코드를 줄일 수 있고 output이 더 명확하게 보여질 수 있어서이다.

```swift
//SearchViewModel
var searchResults = BehaviorRelay<[SearchCellViewModel]>(value: [])
func transform(_ input: Input) -> Output {
    input.searchBarText
        .skip(1)
        .filter { $0.count > 0 }
        .withUnretained(self)
        .flatMapLatest { (self, keyword) in
            return self.useCase.getSearchResults(with: keyword, page: 1)
                .withUnretained(self)
                .map { (self, movieList) -> [SearchCellViewModel] in
                    self.searchText = keyword
                    self.page = movieList.page
                    return movieList.items.filter { $0.posterPath != "" }
                        .map { SearchCellViewModel(movie: $0) }
                }
        }
        .subscribe(with: self, onNext: { _, result in
            self.searchResults.accept(result)
        })
        .disposed(by: self.disposeBag)
    
    input.searchCancelled
        .subscribe(with: self, onNext: { _,_ in
            self.searchResults.accept([])
        })
        .disposed(by: self.disposeBag)
    
    input.loadMoreContent
        .withUnretained(self)
        .skip(3)
        .flatMapLatest { (self, _) -> Observable<[SearchCellViewModel]> in
            return self.useCase.getSearchResults(with: self.searchText, page: self.page)
                .withUnretained(self)
                .map { (self, movieList) -> [SearchCellViewModel] in
                    self.page = movieList.page + 1
                    return movieList.items.filter { $0.posterPath != "" }
                        .map { SearchCellViewModel(movie: $0) }
                }
        }
        .subscribe(with: self, onNext: { _, newContents in
                let oldContents = self.searchResults.value
                self.searchResults.accept(oldContents + newContents)
        })
        .disposed(by: self.disposeBag)

//SearchBarViewController
let output = viewModel.transform(input)
output.searchResults
    .drive(with: self, onNext: { (self, result) in
        self.applySearchResultSnapshot(result: result)
    })
    .disposed(by: disposeBag)
```

### 트러블 슈팅

### 페이지네이션 구현  
SearchViewController에서 CollectionView의 contentOffset.y가 일정 범위에 도달하면 이벤트를 방출하는 옵저버블을 input으로 넣고 SearchViewModel에서 input을 받아 Api 호출을 한 결과를 리턴하여 Output으로 보낸다.  
이때 스크롤을 하면 contentOffset.y가 소수점 단위로 바뀌기 때문에 특정 숫자와 같다(==)는 조건을 걸면 이벤트가 발생되지 않아서 크거나 같다(>=)는 조건을 걸었다. 하지만 이렇게 되면 저 범위를 지날 때 수많은 이벤트가 발생하게 되어 이벤트를 한번만 받는 방법에 대한 고민을 하였다.

1. **이벤트를 한번만 받는 방법에 대한 고민**
- 처음에는 throttle 을 사용하여 3초동안 받는 이벤트중 가장 첫번째 이벤트만 받도록 하였지만, 3초동안 지연되는 현상이 발생하여
- flatMapLatest를 사용하여 여러 이벤트중 가장 마지막 이벤트만 받아서 api 호출을 했더니 지연 없이 자연스럽게 페이지네이션이 되었다

```swift
//SearchViewController
private func contentOffset() -> Observable<Bool> {
    return collectionView.rx.contentOffset
        .withUnretained(self)
        .filter { (self, offset) in
            guard self.collectionView.contentSize.height != 0 else {
                return false
            }
            return self.collectionView.frame.height + offset.y + 100 >= self.collectionView.contentSize.height
        }
        .map { offset -> Bool in
            return true
        }
}

//SearchViewModel
input.loadMoreContent
    .withUnretained(self)
    .skip(3)
    .flatMapLatest { (self, _) -> Observable<[SearchCellViewModel]> in
        return self.useCase.getSearchResults(with: self.searchText.value, page: self.page)
            .withUnretained(self)
            .map { (self, movieList) -> [SearchCellViewModel] in
                self.page = movieList.page + 1
                return movieList.items.filter { $0.posterPath != "" }
                    .map { SearchCellViewModel(movie: $0) }
            }
    }
    .subscribe(with: self, onNext: { _, newContents in
        if self.canLoadNextPage {
            let oldContents = self.searchResults.value
            self.searchResults.accept(oldContents + newContents)
        }
    })
    .disposed(by: self.disposeBag)
```

1. Cancel 버튼을 누르면 collectionView.rx.contentOffset 이벤트가 발생하여 CollectionView에 잘못된 데이터가 표시되는 현상
    
![cancelll](https://user-images.githubusercontent.com/60725934/188251589-d750bde8-b496-4e50-9390-18b9b3a54f80.gif)  
cancel버튼을 누르면 페이지네이션 이벤트가 트리거 되는 이유는 collectionview의 컨텐츠가 없어지면서 collectionview contentsize의 height가 0이 되어서였다.

```swift
 self.collectionView.frame.height + offset.y + 500 >= self.collectionView.contentSize.height
```
<img width="151" alt="스크린샷 2022-09-03 오후 4 46 59" src="https://user-images.githubusercontent.com/60725934/188261400-3c5d5e54-cce5-42e9-a692-bf90b82ab3e0.png">

따라서 `self.collectionView.contentSize.height != 0` 조건을 걸어서 해결하였다.

```swift
private func contentOffset() -> Observable<Bool> {
    return collectionView.rx.contentOffset
        .withUnretained(self)
        .filter { (self, offset) in
            guard self.collectionView.contentSize.height != 0 else {
                return false
            }
            return self.collectionView.frame.height + offset.y + 100 >= self.collectionView.contentSize.height
        }
        .map { offset -> Bool in
            return true
        }
}
```
