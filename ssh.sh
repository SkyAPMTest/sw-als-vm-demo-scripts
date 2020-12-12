source env.sh

gcloud beta compute ssh --zone "$GCP_REGION" --project "$GCP_PROJECT" "$1"
