set -ex

if ! ls microservices-demo; then
  git clone --depth 1 https://github.com/GoogleCloudPlatform/microservices-demo.git
fi

cd microservices-demo/src/checkoutservice

"$HOME"/go/bin/go mod download
"$HOME"/go/bin/go build -gcflags='-N -l' -o "$HOME"/checkoutservice .

PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice.default.svc.cluster.local:3550 \
SHIPPING_SERVICE_ADDR=shippingservice.default.svc.cluster.local:50051 \
CURRENCY_SERVICE_ADDR=currencyservice.default.svc.cluster.local:7000 \
PAYMENT_SERVICE_ADDR=paymentservice.default.svc.cluster.local:50051 \
EMAIL_SERVICE_ADDR=emailservice.default.svc.cluster.local:5000 \
CART_SERVICE_ADDR=cartservice.default.svc.cluster.local:7070 \
GRPC_GO_REQUIRE_HANDSHAKE=off \
DISABLE_PROFILER=true \
"$HOME"/checkoutservice
