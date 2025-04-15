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

### 회원가입 화면

### 트위터 작성 화면

 
| 유저 검색 화면 | 유저 프로필 화면 | 채팅 화면 |  
| --- | --- | --- |
| ![유저검색](https://github.com/user-attachments/assets/3ae920a5-c12e-45ea-a31e-c3020220ebf9) | ![유저프로필](https://github.com/user-attachments/assets/9d0139f2-2f67-4bb4-b3ed-f5c85acd07bb) | ![채팅](https://github.com/user-attachments/assets/54fe3cf9-7c54-4b20-b6f5-22fbd7c586b8) |

### 유저 검색 화면

### 유저 프로필 화면

### 채팅 화면


# 🔫 트러블 슈팅
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
    - StatusBarStyle을 변경하기 위해 preferredStatusBarStyle을 override하여
    .lightContent로 재정의 하였지만, 실제 화면에서는 .darkContent로 출력되었습니다.
- **문제해결**
    - 단일 뷰가 아닌 containerViewController에 속해있는 ViewController의 경우에는
    상위 ContainerViewController에서 childForStatusBarStyle 속성을 재정의하여,
    해당 속성을 변경할려고하는 ViewController를 호출해 줘야 합니다.
    - 해당 프로젝트에서는 TabBarController안에 NavigationController가 여러개 있는 구조이기 때문에,
    selectedController를 NavigationController로 타입캐스팅하여 제일 최 상단에 있는 뷰 컨트롤러에 대해서 적용시키는 방법으로 구현했습니다.
        
        ```swift
        override var childForStatusBarStyle: UIViewController? {
                let selectedViewController = selectedViewController as? UINavigationController
                return selectedViewController?.topViewController
            }
        ```
        
    - 변경하고 싶은 ViewController에 대해서만 preferredStatusBarStyle를 재정의하여 속성값 변경
        
        ```swift
        override var preferredStatusBarStyle: UIStatusBarStyle {
                return .lightContent
            }
        ```
