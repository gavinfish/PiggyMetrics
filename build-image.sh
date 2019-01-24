mvn package -DskipTests && \
docker build ./config -t $DOCKER_HUB_USER/config && \
docker build ./registry -t $DOCKER_HUB_USER/registry && \
docker build ./gateway -t $DOCKER_HUB_USER/gateway && \
docker build ./account-service -t $DOCKER_HUB_USER/account-service && \
docker build ./auth-service -t $DOCKER_HUB_USER/auth-service && \
docker build ./monitoring -t $DOCKER_HUB_USER/monitoring && \
docker build ./notification-service -t $DOCKER_HUB_USER/notification-service && \
docker build ./statistics-service -t $DOCKER_HUB_USER/statistics-service && \
docker build ./turbine-stream-service -t $DOCKER_HUB_USER/turbine-stream-service && \
docker push $DOCKER_HUB_USER/config && \
docker push $DOCKER_HUB_USER/registry && \
docker push $DOCKER_HUB_USER/gateway && \
docker push $DOCKER_HUB_USER/account-service && \
docker push $DOCKER_HUB_USER/auth-service && \
docker push $DOCKER_HUB_USER/monitoring && \
docker push $DOCKER_HUB_USER/notification-service && \
docker push $DOCKER_HUB_USER/statistics-service && \
docker push $DOCKER_HUB_USER/turbine-stream-service

