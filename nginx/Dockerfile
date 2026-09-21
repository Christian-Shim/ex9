# 실행 환경: nginx 1.31.3 (mainline), Alpine Linux 기반 (이미지 용량이 작은 경량 버전)
FROM nginx:1.31.3-alpine

# 이유: html 폴더에 있는 index.html, images/ 등을
#       nginx의 기본 웹 루트(/usr/share/nginx/html)로 복사해서
#       컨테이너 실행 즉시 웹페이지가 뜨도록 함
COPY html/ /usr/share/nginx/html/

# nginx는 기본적으로 80번 포트에서 대기함 (문서화 목적의 명시, 실제 포트 개방은 docker run 시 -p 옵션으로 처리)
EXPOSE 80

# nginx:alpine 이미지는 기본 CMD가 nginx를 foreground로 실행하도록 이미 설정되어 있어
# 별도 CMD를 지정하지 않아도 정상 동작함