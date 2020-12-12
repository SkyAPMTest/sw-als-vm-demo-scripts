source env.sh

set -e

rm -rf "$WORK_DIR"

for VM_APP in {$VM_APP1,$VM_APP2}; do

mkdir -p "$WORK_DIR"/"$VM_APP"

cp env.sh $WORK_DIR
cp resources/prep-$VM_APP.sh $WORK_DIR
cp resources/deploy-$VM_APP.sh $WORK_DIR

tokenexpiretime=3600000
echo '{"kind":"TokenRequest","apiVersion":"authentication.k8s.io/v1","spec":{"audiences":["istio-ca"],"expirationSeconds":'$tokenexpiretime'}}' | kubectl create --raw /api/v1/namespaces/$VM_NAMESPACE/serviceaccounts/$SERVICE_ACCOUNT/token -f - | jq -j '.status.token' > "$WORK_DIR"/"$VM_APP"/istio-token

kubectl -n "$VM_NAMESPACE" get configmaps -n istio-system istio-ca-root-cert -o json | jq -j '."data"."root-cert.pem"' > "$WORK_DIR"/"$VM_APP"/root-cert.pem

ISTIO_SERVICE_CIDR=$(echo '{"apiVersion":"v1","kind":"Service","metadata":{"name":"tst"},"spec":{"clusterIP":"1.1.1.1","ports":[{"port":443}]}}' | kubectl apply -f - 2>&1 | sed 's/.*valid IPs is //')
cat <<EOF > "$WORK_DIR"/"$VM_APP"/cluster.env
ISTIO_SERVICE_CIDR=$ISTIO_SERVICE_CIDR
ISTIO_INBOUND_PORTS=*
EOF

INGRESS_HOST=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{print $4}')
echo "${INGRESS_HOST} istiod.istio-system.svc" > "$WORK_DIR"/"$VM_APP"/hosts-addendum
ISTIO_SERVICE_IP_STUB=$(echo $ISTIO_SERVICE_CIDR | cut -f1 -d"/")

cat resources/dns/dnsmasq.conf | sed s/{ISTIO_SERVICE_IP_STUB}/$ISTIO_SERVICE_IP_STUB/ > "$WORK_DIR"/"$VM_APP"/dnsmasq-snippet.conf

cp resources/dns/resolved.conf "${WORK_DIR}"/"$VM_APP"/resolved.conf

cat <<EOF > "$WORK_DIR"/"$VM_APP"/sidecar.env
ISTIO_INBOUND_PORTS=*
ISTIO_LOCAL_EXCLUDE_PORTS=15090,15021,15020
ISTIO_METAJSON_LABELS='{"app":"$VM_APP","class":"vm","cloud":"gcp","version":"v3"}'
PROXY_CONFIG='{"envoyAccessLogService":{"address":"skywalking-oap.istio-system.svc.cluster.local:11800"}}'
PROV_CERT=/var/run/secrets/istio
OUTPUT_CERTS=/var/run/secrets/istio
EOF

done
