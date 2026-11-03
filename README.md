# 탭체크 TapCheck

해외 도시별 교통카드, 신용카드 탭 결제, 설치할 앱, 공항에서 시내 가는 법을 모은 웹앱이에요.

배포 순서: Supabase(supabase-setup.sql 실행) → config.js에 주소와 anon 키 입력 → GitHub에 이 폴더 안의 파일 업로드 → Vercel에서 Import 후 Deploy.

자세한 단계는 "탭체크 웹사이트 배포 가이드" 문서를 보세요.

- 정보를 고쳐 다시 올릴 때는 sw.js의 `tapcheck-v1` 숫자를 하나 올려주세요.
- 국기 이미지: flag-icons (MIT License, Copyright (c) 2013 Panayiotis Lipiridis), https://github.com/lipis/flag-icons
