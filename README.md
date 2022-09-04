# MovieFinder
1. 프로젝트 기간

2022.05.13 ~ 진행 중

2. 구현 내용  

사용한 API: [TMDB API](https://developers.themoviedb.org/3/)  

OAuth를 이용한 로그인을 통해 영화 상세정보에서 평점을 등록할 수 있고 최신 상영작, 인기작 등의 다양한 영화 목록을 제공하며, 영화 검색기능을 가진 앱

3. 동작 영상  

|로그인|메인화면|상세화면|
|---|---|---|
|![Simulator Screen Recording - iPhone 13 Pro Max - 2022-09-04 at 12 57 01](https://user-images.githubusercontent.com/60725934/188296749-4aa0aac3-53eb-47c6-ade8-83a7cf81f0a4.gif)|![Simulator Screen Recording - iPhone 13 Pro - 2022-09-04 at 12 39 23](https://user-images.githubusercontent.com/60725934/188296377-64931c2b-4c9d-4158-96d1-967dc75cdcff.gif)|![Simulator Screen Recording - iPhone 13 Pro - 2022-09-04 at 12 52 32](https://user-images.githubusercontent.com/60725934/188296543-7de0d655-3861-4f5a-b66e-950365f9bb96.gif)|

|검색|평점|
|---|---|
|![Simulator Screen Recording - iPhone 13 Pro Max - 2022-09-04 at 15 30 59](https://user-images.githubusercontent.com/60725934/188300672-5997282e-8830-4b69-882b-062ec61352ef.gif)|![Simulator Screen Recording - iPhone 13 Pro - 2022-09-04 at 12 42 42](https://user-images.githubusercontent.com/60725934/188296808-7025ccaa-ab93-401e-925e-00425d706db6.gif)|

4. 기술 스택  
- `UIKit`, `RxCocoa`, `RxSwift`
- 라이브러리 `Kingfisher`, `Cosmos`, `SnapKit`
- 아키텍처 `MVVM-C`
- 의존성 관리 `CocoaPods`
- iOS Deployment Target `iOS 15.4`

# 목차
1. [MVVM + Clean Architecture](#MVVM-+-Clean-Architecture)
2. [이미지 처리](#이미지-처리)
3. [Coordinator Pattern을 이용한 화면전환](#Coordinator-Pattern을-이용한-화면전환)
4. [네트워크 코드 추상화](#네트워크-코드-추상화)
5. [로그인 화면](#로그인-화면)
6. [메인 화면](#메인-화면)
7. [검색 화면](#검색-화면)
8. [영화 상세 정보 화면](#영화-상세-정보-화면)

# MVVM + Clean Architecture
<img width="492" alt="스크린샷 2022-09-04 오후 1 43 38" src="https://user-images.githubusercontent.com/60725934/188297779-0db5c636-9206-4b6d-ab3a-77d86bf5490d.png">

- 객체간 단방향 의존관계를 가지도록 설계하였고, Dependency Injection을 통해 객체간 의존성을 낮추었다.
- DIP에 따라 구체적인 클래스가 추상적인 프로토콜에 의존하여 변경되기 쉬운 것에 의존하지 않도록 설계하였다.
```swift
let urlSessionManager = URLSessionManager()
let moviesRepository = DefaultMoviesRepository(urlSessionManager: urlSessionManager)
let defaultMoviesUseCase = DefaultMoviesUseCase(moviesRepository: moviesRepository)
let viewModel = MovieListViewModel(defaultMoviesUseCase: defaultMoviesUseCase)
let viewController = MovieListViewController(viewModel: viewModel)
```

# 이미지 처리

영화 포스터 이미지가 주를 이루는 앱이다보니 성능 향상을 위한 이미지 처리에 대한 많은 고민을 했다.

특히 CollectionView에서 이미지를 로딩할때 다음 세가지 부분을 고려했다.
1. 이미지 로딩 속도
2. 메모리 사용량
3. 스크롤시 이미지가 깜빡거리면서 변하는 현상

이를 해결하기 위해 아래 두가지 방법을 사용하였다.

- Downsampling
- Cache

### 트러블 슈팅
### 1. 이미지 downsampling을 통한 메모리 사용량 줄이기
[WWDC 19 Image and Graphics Best Practices 블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%B2%98%EB%A6%AC-downsampling)

- 문제 상황  

검색 결과를 UICollectionView에 표시할때 원본 이미지의 크기가 큰 경우에 원본 이미지를 그대로 가져오면 메모리를 많이 사용하게 된다.
따라서 처음에는 이미지 resizing을 해보았는데, 메모리 사용량이 크게 줄지 않았다.  
그 이유는 이미 렌더링이 된 이미지의 사이즈를 줄여서 다시 렌더링을 하기 때문에 원본 이미지가 이미 메모리에 저장이 되어있는 상태에서 새로 저장을 하기 때문이다.

```swift
func resize(newWidth: CGFloat) -> UIImage {
    let scale = newWidth / self.size.width
    let newHeight = self.size.height * scale

    let newSize = CGSize(width: newWidth, height: newHeight)
    let render = UIGraphicsImageRenderer(size: newSize)
    let renderImage = render.image { context in
        self.draw(in: CGRect(origin: .zero, size: newSize))
    }

    print("origin: \(self), resize: \(renderImage)")
    return renderImage
}
```
<img width="638" alt="스크린샷 2022-09-03 오후 4 44 33" src="https://user-images.githubusercontent.com/60725934/188261323-371a386e-0086-4747-af27-520c794f7cf4.png">

- 해결 방법  

UIImage가 이미지를 decoding한 후에는 decoding된 이미지를 메모리에 저장해놓기 때문에 원본 decoding 후에 이미지 사이즈를 줄이는 resizing은 성능 향상에 아무런 도움이 되지 않았다.  
따라서 decoding 전에 data buffer 자체의 사이즈를 줄이는 downsampling을 진행하였다.

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

직접 downSample 메서드를 구현해보고 나서 Kingfisher의 DownsamplingImageProcessor가 동일한 기능을 하는 것을 확인하고, Kingfisher을 사용하는 것으로 변경했다.

```swift
let processor = DownsamplingImageProcessor(size: CGSize(width: 368, height: 500))
self.posterImageView.kf.setImage(
    with: url,
    placeholder: UIImage(),
    options: [
        .transition(.fade(1)),
        .forceTransition,
        .processor(processor),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage
    ],
    completionHandler: nil
)
```

### 2. 이미지 로딩 속도 개선하기
[블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%85%80%EC%9D%98-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EB%A1%9C%EB%94%A9-%EC%86%8D%EB%8F%84-%EA%B0%9C%EC%84%A0-NSCache%EB%A1%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%BA%90%EC%8B%B1)

**디스크 캐싱 vs 메모리 캐싱?**

현재상영작, 인기작 등의 목록을 보여주는 ListView의 영화 목록은 자주 바뀌지 않는다.
또한 ListView에서 셀을 터치하면 보여지는 DetailView에서는 동일한 영화 포스터 이미지를 받아온다.  
이와 같은 앱을 실행할때마다 같은 이미지를 여러번 보여줘야하는 상황에서 매번 네트워크 통신을 통해 받아오는 것은 비효율적이라고 생각했다. 따라서 캐시를 사용하여 메모리나 디스크에 저장해둔 이미지를 로딩했다.  

이때 디스크 캐싱과 메모리 캐싱 중 어떤 것을 해야하는지 고민이 되었는데,
- 디스크 캐싱을 할 경우에 사용자가 앱을 종료했다가 다시 켜도 저장된 캐시가 남아있고
- 메모리 캐싱을 할 경우에는 앱을 사용하는 동안 같은 이미지를 다시 조회했을때 메모리에 저장된 캐시 이미지를 보여줄 수 있다.

결론적으로 Kingfisher을 이용하여 디스크, 메모리 캐싱 두가지를 다 적용했다.  
이미지 downsampling 후에 원본 이미지는 디스크에 저장하고, downsampling된 이미지는 메모리에 저장하여 다른 사이즈로 downsampling해야할 경우에는 디스크에 저장된 원본 이미지를 불러와서 가공한다.

### 3. UICollectionView 빠르게 스크롤하면 잘못된 이미지가 나타나는 현상 해결
[블로그 정리글](https://velog.io/@dev_jane/UICollectionView-%EC%85%80-%EC%9E%AC%EC%82%AC%EC%9A%A9-%EB%AC%B8%EC%A0%9C-%EB%B9%A0%EB%A5%B4%EA%B2%8C-%EC%8A%A4%ED%81%AC%EB%A1%A4%EC%8B%9C-%EC%9E%98%EB%AA%BB%EB%90%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80%EA%B0%80-%EB%82%98%ED%83%80%EB%82%98%EB%8A%94-%ED%98%84%EC%83%81)
- 문제 상황  

셀이 재사용되고, 이미지 로딩 작업이 비동기적으로 작동하여 작업이 끝나는 순서를 보장하지 못한다. 셀이 재사용되면서 새로운 이미지가 로딩되기 전에 기존 이미지가 보여지기도 하고, 새로운 이미지가 로딩되고 나서 그제서야 재사용 전의 기존 이미지가 보여지는 현상이 발생하였다.

- 해결 방법  

셀이 재사용 큐에 들어가기전에 불리는 prepareForResue를 오버라이드해서 
1. imageView.image = nil을 해서 재사용되기 전에 imageView가 가진 image를 초기화하고 
2. 만약 재사용 전 이미지가 다운로드되지 않았다면 이미지 다운로드를 취소한다.

# Coordinator Pattern을 이용한 화면전환
<img width="501" alt="스크린샷 2022-09-03 오전 10 59 32" src="https://user-images.githubusercontent.com/60725934/188251530-e5071fe7-98c9-41e9-ba8c-0c9adc15a7a6.png">

### 구현 내용
coordinator 패턴을 사용하면 화면 전환 로직을 viewController에서 coordinator에 위임하면서 역할 분리를 통해 코드의 결합도를 낮춰 유연한 코드를 작성할 수 있다.

```swift
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start() -> UINavigationController
}
```

- AppCoordinator의 역할
    - SceneDelegate에서 window를 주입받아서 로그인 여부에 따라 rootViewController를 다르게 설정하는 역할
    - TabBarController 생성
    - DetailViewController 생성: AppCoordinator가 DetailViewController로 화면을 전환하는 역할을 맡아서 코드의 중복을 제거할 수 있다.
- 각각의 Coordinator들의 역할
    - 자신이 가진 NavigationController에 ViewController를 담아 AppCoordinator에게 전달

**coordinator 패턴에서 가장 중요한 부분은 참조를 관리하는 것임을 느꼈다.**

로그인이 완료되면, 로그인 화면이 내려가고 AuthViewController와 관련된 AuthCoordinator, AuthViewModel, AuthUseCase, AuthRepository 등이 모두 메모리에서 해제되어야 한다.

AuthCoordinator가 navigationController를 가지고 있고, navigationController가 `AuthViewController`를 가지고 있기 때문에 순환 참조를 방지하기 위해 AuthViewController가 coordinator을 약하게 참조해야 한다.

따라서 화면 전환이 일어날 때 `AuthViewController`의 viewDidDisappear에서 `AuthCoordinator`위임하면, `AuthCoordinator`는 `AppCoordinator`에게 위임하여 `AppCoordinator`가 자신이 가지고 있는 childCoordinators 배열에서 AuthCoordinator을 제거한다.

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


# 로그인 화면

### 구현 내용

- 사용자가 계정 생성 버튼 터치시 token을 발급받아 url을 생성하여 외부(TMDB) 계정 생성 화면으로 보낸다.
- 사용자가 URL에서 로그인을 하고 앱으로 돌아오면
- `sceneDidBecomeActive` 이벤트를 받아 scene이 activate 되었을때
    - 사용자가 인증한 토큰으로 session id를 생성하여 `KeyChain`에 민감한 사용자 정보인 Session id 저장 후
    - session id가 정상적으로 생성되었다면 자동으로 메인화면으로 화면전환이 이루어지도록 구현했다.
    - 화면전환 시도 시점은 [Preparing Your UI to Run in the Foreground 공식문서](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_foreground)를 참고하여 scene-based life-cycle event 중 하나인 `sceneDidBecomeActive`시점에 이루어지도록 구현하였다.
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

- 2번 방법으로 `retry()` 를 추가하여 에러가 발생해도 스트림이 종료되지 않도록 하였다.
- sceneDidBecomeActive 이벤트는 scene이 active되었을때 한번만 발생하기 때문에 여러번 retry가 발생하지 않아 사용하였다.

# 메인 화면

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
}

//DefaultMoviesUseCase
    func getMovieLists() -> Observable<[MovieList]> {
        let lists = HomeMovieLists.allCases
        let genresList = moviesRepository.getGenresList()
        let movieLists = lists.map { section -> Observable<MovieList> in
            let movieList = moviesRepository.getMovieList(with: section.posterPath)
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

### 구현 내용  
- debounce를 사용하여 SearchBar에 사용자가 글자를 입력하고 0.5초가 지난 다음에 Api 호출이 일어나도록 하여 글자를 입력하고 있는 도중에 불필요한 호출이 일어나지 않도록 성능을 최적화하였다.
-  한번에 모든 결과를 가져오지 않고 사용자가 스크롤을 내려 스크롤이 일정 범위에 도달한다면 다음 페이지를 불러오는 pagination 기능을 구현하여 필요한 시점에 적절한 api 호출이 일어나도록 구현하였다.

```swift
let newSearchResults = input.searchBarText
    .skip(1)
    .filter { $0.count > 0 }
    .withUnretained(self)
    .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
    .flatMapLatest { (self, keyword) in
        return self.useCase.getSearchResults(with: keyword, page: 1)
            .map { (movieList) -> [SearchCellViewModel] in
                self.searchText = keyword
                self.page = movieList.page
                return movieList.items.filter { $0.posterPath != "" }
                    .map { SearchCellViewModel(movie: $0) }
            }
            .withUnretained(self)
            .map { (self, result) -> [SearchCellViewModel] in
                self.searchResults = result
                return self.searchResults
            }
    }
    .asDriver(onErrorJustReturn: [])
```

### 트러블 슈팅

### 페이지네이션 이벤트를 한번만 받는 방법에 대한 고민 
SearchViewController에서 CollectionView의 contentOffset.y가 일정 범위에 도달하면 이벤트를 방출하는 옵저버블을 input으로 넣고 SearchViewModel에서 input을 받아 Api 호출을 한 결과를 리턴하여 Output으로 보낸다.  
이때 스크롤을 하면 contentOffset.y가 소수점 단위로 바뀌기 때문에 특정 숫자와 같다(==)는 조건을 걸면 이벤트가 발생되지 않아서 크거나 같다(>=)는 조건을 걸었다. 하지만 이렇게 되면 저 범위를 지날 때 수많은 이벤트가 발생하게 되어 이벤트를 한번만 받는 방법에 대한 고민을 하였다.

- 처음에는 throttle 을 사용하여 3초동안 받는 이벤트중 가장 첫번째 이벤트만 받도록 하였지만, 3초동안 지연되는 현상이 발생하였다.
- 따라서 flatMapLatest를 사용하여 여러 이벤트중 가장 마지막 이벤트만 받아서 api 호출을 했더니 지연 없이 자연스럽게 페이지네이션이 되었다.

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
let moreResults = input.loadMoreContent
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
    .withUnretained(self)
    .map { (self, newContents) -> [SearchCellViewModel] in
        let oldContents = self.searchResults
        self.searchResults = oldContents + newContents
        return self.searchResults
    }
    .asDriver(onErrorJustReturn: [])
```

# 영화 상세 정보 화면
### 구현 내용  
CollectionView Compositional Layout과 Diffable DataSource를 사용하여 영화 상세정보 화면을 구성하였다.

### 트러블 슈팅  
### CollectionView Diffable DataSource가 item의 변경사항을 인지하지 못하는 문제

**변경되는 item의 경우 수정사항만 변경하도록 reconfigureitems 사용하여 성능 최적화를 위해 노력했다.** 

- 문제 상황

영화 리뷰 내용이 길어서 300자를 넘어갈 경우에 preview를 먼저 보여주고, 더보기를 터치하면 전체 리뷰를 보여주는 더보기 기능을 구현하고 싶었다.
따라서 셀을 터치할때마다 item의 내용이 변경되어야 했다.  
하지만, diffable datasource의 item이 바뀌어도 변경사항을 인지하지 못하여 매번 새로운 snapshot을 생성하여 모든 데이터를 다시 로딩하는 reloadItems를 사용하해야 했다.  
이 방법은 불필요하게 셀을 삭제하거나 새로 삽입하게 되어 오버헤드가 발생한다고 판단하였다.

- 해결 방법  

따라서 변경된 model만을 업데이트할 수 있는 방법에 대해 찾아보다가 [공식문서](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/updating_collection_views_using_diffable_data_sources)를 참고하여 해결할 수 있었다.

Diffable DataSource 의 item identifier을 MovieDetailReview.ID로 설정하여  
기존 셀의 내용을 업데이트할 때 해당 셀의 내용만 변경하는 [reconfigureItems(_:)](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot/3804468-reconfigureitems) 을 사용할 수 있었다.

이때 item identifier가 struct라면 이 메서드를 사용할 수 없기 때문에 MovieDetailReview에 Identifiable을 채택하여 associatedType인 MovieDetailReview.ID 을 Diffable Datasource의 item identifier로 지정해주었다.

```swift
private typealias DataSource = UICollectionViewDiffableDataSource<DetailSection, MovieDetailReview.ID>

struct MovieDetailReview: Identifiable, Hashable {
    let id: UUID = UUID()
    let userName: String
    let rating: Double
    var content: String
    var contentOriginal: String
    var contentPreview: String
    let createdAt: String
    var showAllContent: Bool = false
}
```

문서에서 item identifier로 struct를 사용하는 경우는 diffable datasource의 item의 내용이 바뀌지 않는 간단한 경우에만 사용하라는 내용을 참고하여 SearchController나 ListController의 경우에는 item identifier로 struct를 사용하였다.
