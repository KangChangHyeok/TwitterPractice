# 트위터 클론 프로젝트
- [유데미 트위터 클론코딩 강의](https://www.udemy.com/course/twitter-ios-clone-swift)를 보고 따라하면서 만든 프로젝트입니다.
- 강의를 다 수강하고 난 이후 오랜만에 다시 프로젝트를 점검해보니 부족하고 고칠 부분들이 많이 보여서 리팩토링을 진행하고 있습니다.( 23.09.20 ~ 진행중)

# ✨ 핵심 키워드
- UICompositional Layout + DiffableDataSource
- Swift Concurrency (async - await)

# 🎬 화면 시연 영상
| 로그인 | 회원가입 | 트윗 작성 | 
| :--: | :--: | :--: |
| <img src = "https://github.com/user-attachments/assets/a41fc939-029d-4c33-bbe4-7bbe0c8a15f6"> | <img src = "https://github.com/user-attachments/assets/bac62146-6200-4f48-a1df-6075badc87fc"> | <img src = "https://github.com/user-attachments/assets/aa5ac40f-16c7-4c15-ae37-2e6ad869ef9d"> |
| 유저 검색 | 유저 프로필 |  |  
<img src = "https://github.com/user-attachments/assets/9bbce1b8-4cea-437c-8338-39b4520e5e6e" witdh = 200> | ![유저 프로필](https://github.com/user-attachments/assets/e6d6b556-8288-441b-a910-af0518c0e24d) | ![유저 목록, 검색](https://github.c![Simulator Screen Recording - 

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
