source env.sh

# Create GKE cluster
gcloud container clusters create "$CLUSTER_NAME" \
  --project "$GCP_PROJECT" \
  --zone "$GCP_REGION" \
  --cluster-version latest \
  --machine-type e2-standard-4 \
  --num-nodes 3 \
  --enable-network-policy

# Configure the GKE cluster credentials in the local machine
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$GCP_REGION" --project "$GCP_PROJECT"

# Create firewall rules to allow 5050,50051 for the two VM services
gcloud compute firewall-rules create sw-als-vm-test --allow tcp:5050,tcp:50051 --target-tags sw-als-vm-test

# Create 2 GCP instances for VM services
for VM_APP in {"$VM_APP1","$VM_APP2"}; do

gcloud compute instances create "$VM_APP" \
  --project "$GCP_PROJECT" \
  --zone "$GCP_REGION" \
  --machine-type n1-standard-2 \
  --subnet default \
  --network-tier PREMIUM \
  --maintenance-policy MIGRATE \
  --image-family ubuntu-1604-lts \
  --image-project ubuntu-os-cloud \
  --boot-disk-size 40GB \
  --boot-disk-type pd-standard \
  --boot-disk-device-name "$VM_APP" \
  --tags=sw-als-vm-test

done
