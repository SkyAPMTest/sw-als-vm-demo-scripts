This repo contains the scripts that help to set up an experiment environment to test the solution of Apache SkyWalking +
Envoy Access Log Service (ALS) for observability of hybrid (Kubernetes + VM) service mesh.

```text
.
├── env.sh                                // contains variables that will be used through the entire process, open and edit as per your own scenario, make sure not to use ISTIO_VERSION = 1.8.0/1.8.1 due to https://github.com/istio/istio/issues/28901
├── 00-create-cluster-and-vms.sh          // creates a GKE cluster and 2 GCP instance, is supposed to be executed at most once, or if you already have running clusters and VMs, this is optional
├── 01a-install-istio.sh                  // installs Istio with VM support enabled, ALS enabled and sets the ALS address to Apache SkyWalking receiver
├── 01b-install-skywalking.sh             // installs Apache SkyWalking in istio-system namespace
├── 02-create-files-to-transfer-to-vm.sh  // creates necessary files that will be used to initialize the VMs
├── 03-copy-work-files-to-vm.sh           // securely transfers the files generated above to the VM
├── 04a-deploy-demo-app.sh                // deploys the GoogleCloudPlatform/microservices-demo demo services without CheckoutService and PaymentService, which will be deployed manually on VM
├── 04b-register-vm-with-istio.sh         // registers the VM/services to the service mesh so that Kubernetes service can access VM services via FQDN
├── README.md                             // 
├── resources                             // 
│   ├── clean-vm.sh                       // (run on VM) cleans up the VM after experiment
│   ├── deploy-checkoutservice.sh         // (run on VM) clones, builds and deploys the CheckoutService in VM
│   ├── deploy-paymentservice.sh          // (run on VM) clones, builds and deploys the PaymentSService in VM
│   ├── dns                               // 
│   │   ├── dnsmasq.conf                  // (used on VM) configures the `dnsmasq.service` to resolve the FQDN (such as httpbin.default.svc.cluster.clocal)
│   │   └── resolved.conf                 // (used on VM) configures the `resolved.service` to resolve the FQDN (such as httpbin.default.svc.cluster.clocal)
│   ├── google-demo.yaml                  // (used on VM) the GoogleCloudPlatform/microservices-demo demo services without CheckoutServices and PaymentService
│   ├── prep-checkoutservice.sh           // (run on VM) prepares the VM where the CheckoutService will be deployed
│   ├── prep-paymentservice.sh            // (run on VM) prepares the VM where the PaymentService will be deployed
│   └── vmintegration.yaml                // YAML file that enables `meshExpansion`, `EnvoyAccessLogService` and sets ALS address
└── ssh.sh                                // helps to ssh log into the VM, ./ssh.sh checkoutservice and ./ssh.sh paymentservice
```

For more details about how to use this repo, please refer to the [blog](TODO) post that firstly uses this repo to demonstrate.
