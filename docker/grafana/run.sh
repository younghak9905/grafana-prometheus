#!/bin/bash

#Docker Compose를 사용하여 컨테이너 중지
#sudo docker-compose -f docker-compose.yamln

# Docker Compose를 사용하여 컨테이너 다시 시작 및 백그라운드 실행
sudo docker-compose up --build -d

# 현재 실행 중인 모든 Docker 컨테이너 목록 표시
sudo docker ps -a

