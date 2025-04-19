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

  ### 채팅 화면 구현
  - 사실 강의를 사서 들었지만, 채팅방 기능을 구현하는 내용을 들으려면 추가적으로 결제를 해야 들을 수 있었다. 사서 들어도 상관은 없었으나 뭔가 오기가 생겨서 혼자서 구현해보기로 결심했다.
  - 구조같은 경우, 채팅 메세지 1개를 1개의 셀로 생각하고 구조를 잡아서 그렸고, 그 결과 컬렉션뷰를 활용하여 구도를 잡았다.

  - xCode의 View Hierarchy를 사용하여, 모든 뷰의 프레임을 확인하면 이런 모습이다.

<img src="https://github.com/user-attachments/assets/8f4e10ab-cad4-4bd4-a47c-493459b33a79" width= "34%" height = "34%"> 

   - 가변적인 셀 높이 활용을 위한 compositional layout 활용해서 셀마다 가변적 높이를 적용시키기기 위해서 NSCollectionLayoutSize로 사이즈를 지정할때,   
   item과 group의 widthDimension의 경우 .fractionalWidth(1.0) 으로 설정하여 기기의 전체 너비를 사용하도록 하고, heightDimension을 설정할때     
   .estimated(50) 으로 설정하여 Cell이 입력되는 메세지 내용에 따라 가변적인 높이를 가져갈수 있도록 설정했다.
  - 이 화면을 그리는 데에 있어서 핵심은, "내가 작성한 메세지 여부"를 판단해서 해당 조건의 분기에 따른 각각의 레이아웃 설정이 핵심이라고 생각했다.
  - 그래서 메세지를 전송할때, 전송한 유저의 이메일을 같이 담아 서버에 전달되고 나면 이후 채팅을 다시 가져왔을때 현재 로그인한 아이디와 메세지 안에 담겨있는 유저의 아이디가 같은지를 판단해서 각 상황에 맞은 레이아웃 처리 하는것으로 생각하여 구현했다.
  - 또한 분기에 따른 레이아웃 처리는 아래 이미지처럼 진행했다.
  - <img src="https://github.com/user-attachments/assets/70fde4d7-edd3-4ef1-a1ca-8234e2bd8903" width= "34%" height = "34%"> 

  - 추가적으로 CollectionViewCell의 구조상, 셀을 초기화 하는 과정에서 전에 설정한 constraint들이 그대로 적용된 상태로 남아서 새로 셀을 초기화하는과정에서 문제가 생길수 있기 때문에, 각 레이아웃을 설정 완료하고 cell 의 변수로 Constraints를 저장해놨다가, 해당 셀이 재사용되면서 prepareForReuse() 메서드가 호출 될 때, 해당 변수에 담겨있는 Constraints를 nil을 넣어 지우고, 새로 Constraints가 설정될수 있도록 하였다.
 
  - 마지막으로 메세지를 입력하기 위해 화면 최하단에 커스텀한 MessageInputView를 붙여놓았는데, 키보드 노출이 일부 메세지가 키보드에 가려져 보이지 않는 상황이 발생했다.
  - 기존에는 keyboardWillShowNotification, keyboardWillHideNotification같은 Notification을 NotificationCenter에 등록한 후 호출되는 셀렉터 메소드에 sender값에 접근해 키보드의 크기를 가져와 화면을 대응하는 방식이었다.
  - 기존 방식이 조금 설정해야 되는것도 많고, 일일이 설정해줘야 하는 부분들이 많았어서 힘들었는데, 새로나온 KeyboardLayoutGuide를 활용하여,  MessageInputView의 bottom Anchor를 키보드레이아웃 가이드의 topAnchor에 고정시키니 키보드 높이에 따라 화면이 알아서 대응되어 보이게 구현되어서 너무 편했고, 신기했다.
    | 코드 예시 | 실제 화면 | 
    | --- | --- |
    | <img width="524" alt="스크린샷 2025-04-19 21 32 51" src="https://github.com/user-attachments/assets/264c8c84-8458-4bf5-8dae-4f75f0a6d936" /> | ![ScreenRecording_04-19-2025 21-30-31_1](https://github.com/user-attachments/assets/a2673d44-b5a5-48ba-bed2-eea0b2650d3d) |
