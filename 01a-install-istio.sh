source env.sh

istioctl install -f resources/vmintegration.yaml

kubectl label namespace default istio-injection=enabled
