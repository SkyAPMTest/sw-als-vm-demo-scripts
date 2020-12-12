set -ex

source env.sh

export ROOT_FOLDER=work
export FILES=./"$VM_APP2"

sudo apt -y update
sudo apt -y upgrade

curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -

sudo apt-get install dnsmasq build-essential nodejs -y

sudo mkdir -p /var/run/secrets/istio
sudo cp "${FILES}"/root-cert.pem /var/run/secrets/istio/root-cert.pem

sudo  mkdir -p /var/run/secrets/tokens
sudo cp "${FILES}"/istio-token /var/run/secrets/tokens/istio-token

curl -LO https://storage.googleapis.com/istio-release/releases/$ISTIO_VERSION/deb/istio-sidecar.deb
sudo dpkg -i istio-sidecar.deb

sudo cp "${FILES}"/cluster.env /var/lib/istio/envoy/cluster.env

sudo cp "${FILES}"/sidecar.env /var/lib/istio/envoy/sidecar.env

sudo sed -i 's/^.*istiod.istio-system.svc$//g' /etc/hosts
sudo sh -c "cat $(eval echo ~$SUDO_USER)/$ROOT_FOLDER/$FILES/hosts-addendum >> /etc/hosts"

sudo cp "${FILES}"/root-cert.pem /var/run/secrets/istio/root-cert.pem

sudo mkdir -p /etc/istio/proxy
sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy  /var/run/secrets

if ls /etc/dnsmasq.conf; then
    sudo bash -c "cat ${FILES}/dnsmasq-snippet.conf >> /etc/dnsmasq.conf"
    sudo systemctl restart dnsmasq.service
    
    sudo sed -i 's/^#DNS=/DNS=127.0.0.1/' /etc/systemd/resolved.conf
    sudo sed -i 's/^#Domains=/Domains=~svc.cluster.local/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved.service
fi

sudo systemctl restart istio
