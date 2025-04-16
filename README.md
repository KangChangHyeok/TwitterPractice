# 트위터 클론 프로젝트

## 개요
- [유데미 트위터 클론코딩 강의](https://www.udemy.com/course/twitter-ios-clone-swift)를 보고 따라하면서 만든 프로젝트입니다.
- 강의를 보면서 다 작성한 이후, Realtime DataBase가 사용하는데 너무 불편해서 Firestore로 데이터베이스를 변경했습니다.
- 추가적으로 추가 결제를 해야 들을수 있던 채팅 기능 구현 강의를 듣지 않고, 직접 채팅 기능을 구현했습니다.

## 아키텍처
- UIKit을 기반으로 화면을 구성했습니다.
- 프로젝트 구조는 MVC입니다.

## 주요 화면 & 기능
| 로그인 화면 | 회원가입 화면 | 트위터 작성 화면 | 
| --- | --- | --- |
| ![로그인](https://github.com/user-attachments/assets/2cf92420-bd75-4238-b423-252b1b82cf44) | ![회원가입](https://github.com/user-attachments/assets/e86a7b01-1743-40a1-a4a4-11d9864438dd) | ![트위터작성](https://github.com/user-attachments/assets/94687afc-e073-498e-b14c-7e864893847f) |

### 로그인 화면
- email, password가 입력되었는지 확인 후 로그인을 시도합니다. 둘중에 하나라도 입력되지 않았다면 UIAlertController를 통해 어떤 것이 입력되지 않았는지 전달합니다.
- 이후 데이터베이스를 조회해서 입력된 이메일로 가입된 이메일이 있는지 검증합니다.
- 마지막으로 조회된 아이디와 비밀번호가 일치하는지 확인후 로그인 처리를 합니다.
### 회원가입 화면
- UIImagePickerController를 활용하여 현재 기기의 사진앱에서 유저가 사용할 프로필 사진을 가져옵니다.
- 이후 입력된 값들을 토대로, 정상적으로 입력되었다면 회원가입을 완료하며, 바로 로그인 처리를 하여 유저가 접속할수 있도록 합니다.
### 트윗 작성 화면
- 앱 오른쪽 하단의 버튼을 통해 트윗을 작성할 수 있습니다.
- 트윗 화면이나 홈 피드에 나타나는 리트윗 버튼을 누르면 해당 트윗의 리트윗을 작성할수 있습니다.
 
| 유저 검색 화면 | 유저 프로필 화면 | 채팅 화면 |  
| --- | --- | --- |
| ![유저검색](https://github.com/user-attachments/assets/3ae920a5-c12e-45ea-a31e-c3020220ebf9) | ![유저프로필](https://github.com/user-attachments/assets/9d0139f2-2f67-4bb4-b3ed-f5c85acd07bb) | ![채팅](https://github.com/user-attachments/assets/54fe3cf9-7c54-4b20-b6f5-22fbd7c586b8) |

### 유저 검색 화면
- 데이터베이스에 등록되어있는 모든 유저의 정보를 가져와 보여줍니다.
- 유저가 서치바에 텍스트를 입력할때마다 검색 결과를 업데이트해주는 UISearchResultsUpdating의 updateSearchResults(for: UISearchController) 메서드를 활용하여 처음 화면 초기화시 가져온 유저들을 서치바에 입력된 텍스트를 포함한 유저들만 필터링하여 보여줍니다.
### 유저 프로필 화면
- 해당하는 유저의 팔로우/ 팔로잉 갯수를 보여주고, 트윗, 리트윗, 좋아요한 트윗을 탭바 형식의 UI를 사용해 선택된 탭의 카테고리에 해당하는 트윗을 필터링하여 보여줍니다.
- 자신의 프로필인 경우 우측 상단의 팔로잉 버튼이 프로필 수정 버튼으로 변경되며, 해당 버튼으로 프로필 수정 화면에 진입하여 프로필 정보를 수정하거나, 로그아웃을 할 수 있습니다.

### 채팅 화면
- 유저간 채팅을 할수 있는 화면입니다. 메세지 내용을 입력하여 전송하면, 서버에 전달하고 보낸 메세지를 말풍선 모양의 UI로 표시해줍니다.
- 메세지를 보낸 시간을 같이 확인할수 있으며, 채팅 내용에 따라 말풍선의 크기가 수정되도록 구성했습니다.

## 기술적 고민, 문제 해결 🤔

### iOS 15 이후 지정한 NavigationBar의 BartintColor가 적용되지 않는 문제

- 문제상황
    - 코드에서 navigationBar의 색상을 white로 지정하였습니다.
    - 하지만 실행해서 확인할 경우 지정한 색상이 적용되지 않고 투명하게 NavigationBar가 출력되었습니다
- 원인
    - iOS 15부터 UIKit의 기능 확장으로 인해 isTranslucent 의 default 설정이 false으로 지정되어 발생
- 문제해결
    - AppDelegate의 didFinishLaunchingWithOptions함수에서 
    UINavigationBarAppearance 객체를 생성합니다.
    - 해당 객체의 configureWithOpaqueBackground()함수를 실행하여
    불투명하게 navigationBar를 설정합니다.
    - backgroundColor 속성값을 내가 바꾸고자 하는 색상으로 변경합니다.
    - UINavigationBar.appearance()의 standardAppearance와 
    scrollEdgeAppearance를 위에서 만든 appearance 객체로 변경하여 문제를 해결했습니다.
        
        ```swift
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
                
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        ```
        
### preferredStatusBarStyle이 적용되지 않는 문제

- **문제상황**
    - statusBar의 StatusBarStyle을 변경하기 위해 preferredStatusBarStyle을 override하여
    .lightContent로 재정의 하였지만, 실제 화면에서는 .darkContent로 출력되었습니다.
- **문제해결**
    - 공식문서를 찾아보니 containerViewController(UINavigationController, UITabBarController)에서 관리하는 ViewController의 경우에는
    상위 ContainerViewController에서 childForStatusBarStyle 속성을 재정의하여, 자식 뷰 컨트롤러의 상태 표시줄 스타일을 사용할수 있도록 구성해야 함. 
    - 해당 프로젝트에서는 TabBarController안의 viewController들이 각각 NavigationController로 감싸져 들어가 있었기 때문에, 먼저 .lightCotent를 사용할 뷰컨트롤러에서 preferredStatusBarStyle를 재정의하여 원하는 설정값으로 반환할수 있도록 처리한다.
 
  ```swift
  override var preferredStatusBarStyle: UIStatusBarStyle {
                return .lightContent
            }
  ```
  - 이후 UINavigationController의 childForStatusBarStyle 속성을 재정의하여 네비게이션 스택 맨 위에 있는 뷰컨트롤러의 preferredStatusBarStyle를 사용하도록 설정하였다.
  - 서브클래싱을 하여 사용할수도 있지만, extension을 사용하여 구현하는 방식이 제일 깔끔하다고 생각해서 해당 방식을 사용하여 해결함.
  ```swift
        extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
  }
  ```
