1 - Create a cluster
`k3d cluster create mycluster --agents 2`

2 - Install Trivy:

``` bash
helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --set="trivy.ignoreUnfixed=true" \
  --version 0.8.0
```
