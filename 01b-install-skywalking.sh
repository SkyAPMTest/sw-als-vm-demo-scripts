source env.sh

set -e

if ! ls skywalking-kubernetes; then
  git clone --depth 1 https://github.com/apache/skywalking-kubernetes.git
fi

cd skywalking-kubernetes/chart

helm -n istio-system uninstall skywalking || true

helm repo add elastic https://helm.elastic.co
helm dep up skywalking

helm -n istio-system \
  install skywalking skywalking \
  --set oap.storageType='elasticsearch' \
  --set ui.image.tag=8.3.0 \
  --set oap.image.tag=8.3.0-es6 \
  --set elasticsearch.imageTag=6.8.6 \
  --set elasticsearch.replicas=2 \
  --set oap.replicas=2 \
  --set oap.env.SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS=mx-mesh \
  --set oap.envoy.als.enabled=true
