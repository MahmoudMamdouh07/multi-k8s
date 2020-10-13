# $GIT_SHA => SHA is the id that uniquely identify each commit. it has a benefit of assigning a version to each image before sending them to docker hub
# when implicitly setting images we are setting the image which is last commited by us using the same SHA
# we can revert to the previous image if we found a bug using this SHA too, by getting the SHA of the current image then -> git checkout (SHA) and debug this bugged image locally
# we add latest tag just to make sure if someone wanted to apply k8s folder without using SHA
docker build -t doo7a/multi-client:latest -t doo7a/multi-client:$SHA -f ./client/Dockerfile.dev ./client
docker build -t doo7a/multi-server:latest -t doo7a/multi-server:$SHA -f ./server/Dockerfile.dev ./server
docker build -t doo7a/multi-worker:latest -t doo7a/multi-worker:$SHA -f ./worker/Dockerfile.dev ./worker
docker push doo7a/multi-client:latest
docker push doo7a/multi-server:latest
docker push doo7a/multi-worker:latest

docker push doo7a/multi-client:$SHA
docker push doo7a/multi-server:$SHA
docker push doo7a/multi-worker:$SHA
kubectl apply -f k8s
#                 object kind/metadata name     containerName=(docker Id)/(docker image from docker hub):image version
kubectl set image deployments/server-deployment server=doo7a/multi-server:$SHA
kubectl set image deployments/client-deployment client=doo7a/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=doo7a/multi-worker:$SHA