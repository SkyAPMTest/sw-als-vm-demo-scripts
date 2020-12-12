set -ex

if ! ls microservices-demo; then
  git clone --depth 1 https://github.com/GoogleCloudPlatform/microservices-demo.git
fi

cd microservices-demo/src/paymentservice

npm i

PORT=50051 node index.js
