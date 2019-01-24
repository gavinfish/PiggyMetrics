REM mvn package -DskipTests && ^
docker build .\config -t andxu/config && ^
docker build .\registry -t andxu/registry && ^
docker build .\gateway -t andxu/gateway && ^
docker build .\account-service -t andxu/account-service && ^
docker build .\auth-service -t andxu/auth-service && ^
docker build .\monitoring -t andxu/monitoring && ^
docker build .\notification-service -t andxu/notification-service && ^
docker build .\statistics-service -t andxu/statistics-service && ^
docker build .\turbine-stream-service -t andxu/turbine-stream-service && ^
docker push andxu/config && ^
docker push andxu/registry && ^
docker push andxu/gateway && ^
docker push andxu/account-service && ^
docker push andxu/auth-service && ^
docker push andxu/monitoring && ^
docker push andxu/notification-service && ^
docker push andxu/statistics-service && ^
docker push andxu/turbine-stream-service



