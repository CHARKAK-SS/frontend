# charkak

A new Flutter project.

## 환경 수정 필요
android/app/build.gradle.kts의 android 내에 
ndkVersion = flutter.ndkVersion -> ndkVersion = "27.0.12077973" 변경

## 깃 코드 정리
### 개발 전 코드 가져오기
- git pull origin main
  
### 개발 중 바뀐 코드 저장 후 push
1. 현재 로컬 변경 사항 저장
   - git stash
2. 최신 코드 받아오기
  - git pull origin main
3. stash 변경 사항 복원
  - git stash pop
4. if 충돌 발생 시, 수동으로 수정하고 다시 커밋
  - git add .
  - git commit -m "Resolve merge conflicts and continue work"
5. 최신 코드 푸시
  - git add .
  - git commit -m "sample"
  - git push origin main

### 기타
1. 현재 브랜치 확인
   - git branch
   - 원격 브랜치 목록 : git branch -r
2. pull 전 상태 점검 -> 바뀐 내용 확
   - git fetch origin
   - git status
   - git log origin/main --online
3. 기타
   - git remote -v : 원격 저장소 이름 확인

### backend와 연결
- baseUrl = 'http://10.0.2.2:8080' 

### api 연결
1. 구글맵 api -> android/app/main/AndroidManifest.xml
  - meta-data의 androdi:value= 부분 구글맵 api key로 수정 필요
2. 기상청 api -> spotdetail_screen
  - apiKey 부분 기상청 api key로 수정 필요
