kubectl -n strimzi-connect create secret docker-registry registry-credentials \
  --docker-server=ghcr.io \
  --docker-username='<GITHUB_USERNAME>' \
  --docker-password='<GITHUB_TOKEN_WITH_PACKAGES_WRITE>' \
  --docker-email='you@example.com'


  kubectl -n strimzi-connect create secret generic ccloud-kafka-credentials \
  --from-literal=KAFKA_API_KEY='<CCLOUD_KEY>' \
  --from-literal=KAFKA_API_SECRET='<CCLOUD_SECRET>' \
  --from-literal=BOOTSTRAP_SERVERS='<CCLOUD_BOOTSTRAP>:9092'