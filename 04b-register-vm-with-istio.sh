source env.sh

set -e

VM_IP1=$(gcloud compute instances describe --zone "$GCP_REGION" "$VM_APP1" --project "$GCP_PROJECT" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

cat <<EOF | kubectl -n "$VM_NAMESPACE" apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $VM_APP1
  labels:
    app: $VM_APP1
spec:
  ports:
  - port: $VM_PORT1
    name: grpc
    protocol: TCP
    targetPort: $VM_PORT1
  selector:
    app: $VM_APP1
EOF

sleep 3s

cat <<EOF | kubectl -n "$VM_NAMESPACE" apply -f -
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: "$VM_APP1"
  namespace: "$VM_NAMESPACE"
spec:
  address: "$VM_IP1"
  labels:
    app: $VM_APP1
  serviceAccount: "$SERVICE_ACCOUNT"
EOF

VM_IP2=$(gcloud compute instances describe --zone "$GCP_REGION" "$VM_APP2" --project "$GCP_PROJECT" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

cat <<EOF | kubectl -n "$VM_NAMESPACE" apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $VM_APP2
  labels:
    app: $VM_APP2
spec:
  ports:
  - port: $VM_PORT2
    name: grpc
    protocol: TCP
    targetPort: $VM_PORT2
  selector:
    app: $VM_APP2
EOF

sleep 3s

cat <<EOF | kubectl -n "$VM_NAMESPACE" apply -f -
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: "$VM_APP2"
  namespace: "$VM_NAMESPACE"
spec:
  address: "$VM_IP2"
  labels:
    app: $VM_APP2
  serviceAccount: "$SERVICE_ACCOUNT"
EOF
