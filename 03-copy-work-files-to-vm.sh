source env.sh

gcloud compute scp --zone "$GCP_REGION" --project "$GCP_PROJECT" --recurse ./work "$VM_APP1":~
gcloud compute scp --zone "$GCP_REGION" --project "$GCP_PROJECT" --recurse ./work "$VM_APP2":~
