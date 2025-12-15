# Strimzi version of Kafka Connect
Strimzi is a Cloud Native Computing Foundation (CNCF) project that provides a way to run an Apache Kafka cluster on Kubernetes in various deployment configurations. For development it’s easy to set up a cluster in Minikube in a few minutes. For production you can tailor the cluster to your needs, using features such as rack awareness to spread brokers across availability zones, and Kubernetes taints and tolerations to run Kafka on dedicated nodes. You can expose Kafka outside Kubernetes using NodePort, Load balancer, Ingress and OpenShift Routes, depending on your needs, and these are easily secured using TLS.

The Kube-native management of Kafka is not limited to the broker. You can also manage Kafka topics, users, Kafka MirrorMaker and Kafka Connect using Custom Resources. This means you can use your familiar Kubernetes processes and tooling to manage complete Kafka applications.

**REFERENCE:**   https://strimzi.io/

The following will guide you through a basic Strimzi Setup. 


## 1 - Create a namesapces

```bash
kubectl create namespace strimzi-connect
kubectl label ns strimzi-connect pod-security.kubernetes.io/enforce=privileged  
kubectl label ns strimzi-connect pod-security.kubernetes.io/audit=privileged 
kubectl label ns strimzi-connect pod-security.kubernetes.io/warn=privileged

kubectl create namespace strimzi-operator
kubectl label ns strimzi-operator pod-security.kubernetes.io/enforce=privileged  
kubectl label ns strimzi-operator pod-security.kubernetes.io/audit=privileged 
kubectl label ns strimzi-operator pod-security.kubernetes.io/warn=privileged

```



## 2 - Install the Operator
```
helm repo add strimzi https://strimzi.io/charts/
helm repo update

helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator  -n strimzi-operator

```

<br /><br /><br /><br />
# OPTIONS
At this point we have two options to create the docker image that we would like to run.  If we include the build-> spec in yaml for Kuberntes, the Strimzi operator will build our kafka-connect image for us, push it to a container registry and then launch the requested number of instances.  In this case Kubernetes cluster is used to build and push.   The second option is to build the image oursleves and push to a container registry and then deploy the cluster. 

## OPTION 1 - Build in cluster

The file in this repo (kafkaBuilder.yaml) provides an example of how we can leverage Kubernetes to build, push and run the image through the use of one single file.  In order to push the image a secret is needed (should be used) to store credentials to the container registry used. 

**CONTAINER SECRET**
```bash
    kubectl -n strimzi-connect create secret docker-registry registry-credentials \
    --docker-server=ghcr.io \
    --docker-username='<GITHUB_USERNAME>' \
    --docker-password='<GITHUB_TOKEN_WITH_PACKAGES_WRITE>' \
    --docker-email='you@example.com'
```

**KAFKA SECRET**
```bash
    kubectl -n strimzi-connect create secret generic ccloud-kafka-credentials \
    --from-literal=KAFKA_API_KEY='<CCLOUD_KEY>' \
    --from-literal=KAFKA_API_SECRET='<CCLOUD_SECRET>' \
    --from-literal=BOOTSTRAP_SERVERS='<CCLOUD_BOOTSTRAP>:9092'
```

**DEPLOY CONNECT**
```bash
  kubectl apply -f kafkaBuilder.yaml -n strimzi-connect
```


<br /><br /><br /><br />

## OPTION 2 - Manually Build

## 3 - Build the Strimzi Image (to add plugins)
```bash
   docker build -t ghcr.io/cloud-focus-tech/strimzi-connect:0.0.1 .
```


## 4 - Push the Strimzi Image
```bash
    docker push ghcr.io/cloud-focus-tech/strimzi-connect:0.0.1 
```


## 5 - Deploy the Connect Host
```bash
    kubectl deploy -f kafka-connect.yaml
```
