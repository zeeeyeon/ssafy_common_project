# JPA

## 간단 설명
자바의 ORM기술을 쉽게 구현하도록 도와주는 API
- JpaRepository를 상속하는 인터페이스에 메서드 이름만 적어놓으면
알아서 다 처리(구현체 생성, 쿼리문 구현 등)해줌

## JPA (Java Persistence API)란?

**자바에서 객체를 데이터베이스에 저장하고 관리하기 위한 인터페이스와 기능을 제공하는 API**
- JPA를 사용하면 겍체와 관계형 데이터베이스 간의 매핑을 손쉽게 처리할 수 있으며 데이터베이스의 CRUD 작업을 간편하게 수행할 수 있다. 


## 커뮤니티 기능을 직접 구현해보면서 CRUD 부셔보기

### 1. Entity에 테이블 정보 작성하기 

#### 코드 작성중 알게된 것

#### @Builder 
Lombok에서 제공하는 어노테이션 중 하나로 빌더 패턴을 자동으로 생성해주는 역할을 한다. 
- 코드의 가독성 향상과 유연한 객체 생성이 가능해짐

**사용 예시
```
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class User {
    private Long id;
    private String username;
    private String password;
    private String email;
    // 기타 필드들...
}

// 객체 생성
User user = User.builder()
                .username("alice")
                .password("securepassword")
                .email("alice@example.com")
                .build();
```

#### @Builder.Default ?
기본값을 설정하기 윈한 어노테이션, 달라지는 것에 붙이고 값을 설정하면 됨

#### private Set<User> followers = new HashSet<>(); ?
followers 필드는 **팔로워(User)**의 집합(Set)입니다. 초기값으로 빈 HashSet을 할당하여, null이 아닌 빈 컬렉션으로 초기화

#### @GenerateValue ?
@Id는 데이터베이스의 테이블의 기본키와 객체의 필드를 매핑시켜주는 어노테이션인데 @GeneratedValue는 기본 키를 자동으로 생성해주는 어노테이션이다.

GenerationType.IDENTITY : 기본 키 생성을 데이터베이스에 위임하는 전략

GenerationType.SEQUENCE : 데이터 베이스 시퀀스를 사용해서 기본 키를 생성

GenerationType.AUTO : JPA가 데이터베이스에 맞는 전략을 자동으로 선택

GenerationType.TABLE : 별도의 테이블을 만들어 기본 키를 생성

#### JoinTable
테이블의 연관 관계를 설계하는 방법 중 하나로 별도의 테이블을 만들어서 각 테이블의 외래키를 통해 연관 관계를 설정하는 방법
- JoinColumn은 외래키를 가지고 직접적으로 테이블 사이의 연관관계를 설정하는 방법

#### @PrePersist
데이터베이스가 저장되기 직전에 호출

#### @PreUpdate 
데이터베이스가 업데이트되기 직전에 호출

#### FetchType.LAZY (지연 로딩)
- 연관된 엔티티를 실제 사용할 때 데이터베이스에서 조회
    - 초기 로딩 시 불필요한 데이터를 가져오지 않으므로 성능 최적화에 유리
    - 연관된 데이터를 실제로 사용할 때 추가적인 쿼리가 발생

#### FetchType.EAGER (즉시 로딩)
- 연관된 엔티티를 즉시 로딩하여, 기본 엔티티와 한 번에 조회
    - 연관된 데이터를 미리 로딩하므로 추가적인 쿼리가 발생 X
    - 필요하지 않은 데이터까지 로딩할 수 있어 성능에 부담을 줄 수 있다. 

### 2. DTO 클래스 생성 (작성중)

DTO (DATA Transfer Object)란?
데이터 전송 객체로, 애플리케이션의 다양한 계층 간에 데이터를 주고받을 때 사용하는 객체
- 보통 엔티티와 유사한 구조를 가진다.
- Entity : 데이터베이스의 테이블과 매핑, 비즈니스 로직에 포함될 수 있음
- DTO : 데이터 전송을 목적으로 하며, 비즈니스 로직에 포함하지 않고 필요한 **데이터만** 담고 있음

**DTO를 사용하는 이유**
- 필요한 정보만 포함시켜 민감한 정보의 노출을 최소화
- 필요한 데이터만 전송하여 네트워크의 트래픽을 줄이고, 응답 속도를 향샹시킨다.
- 계층간의 독립성을 유지 뷰 계층과 데이터 접근계층을 분리하여 서로 영향 X

**DTO 종류**
Request DTO : 클라이언트가 서버로 요청할 때 사용하는 DTO
Response DTO : 서버가 클라이언트에게 응답할 때 사용하는 DTO
Projection DTO : 특정 필드만 조회하거나, 복잡한 데이터 구조를 단순화할 때 사용하는 DTO


### 3. 각 엔티티에 대한 JPA리포지토리 인터페이스 작성:

### 4. 서비스 계층 구현

### 5. 컨트롤러 작성

### 6. Thymeleaf 템플릿 작성:



