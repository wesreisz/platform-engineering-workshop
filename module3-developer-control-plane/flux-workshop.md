# Flux Workshop: CI/CD with a Simple Website



Delete the existing kind cluster:

```bash
kind delete cluster --name dev
```
Create a new kind cluster:
```bash
kind create cluster --name dev --config ./create-cluster.yaml
```


Install flux:

```bash
brew install fluxcd/tap/flux
```

Make sure to create and store your PAT Token (we use it in the next step):

https://github.com/settings/tokens

Export Git Credentials:
```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

Check your k8 cluster meets flux requirements:

```bash
flux check --pre
```

Bootstrap the repo you'll be using:
```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=fleet-infra \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```
```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=react-app \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```


Clone the git repo:
```bash
git clone https://github.com/$GITHUB_USER/fleet-infra
cd fleet-infra
```
Clone the git repo:
```bash
git clone https://github.com/$GITHUB_USER/react-app
cd react-app
```


Create a GitRepository manifest pointing to podinfo repository’s master branch:

```bash
flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=1m \
  --export > ./clusters/my-cluster/podinfo-source.yaml
```

```bash
flux create source git react \
    --url=https://github.com/AnaisUrlichs/react-article-display \
    --branch=main \
    --export > ./clusters/my-cluster/react-article-display-source.yaml
```

Commit and push the podinfo-source.yaml file to the fleet-infra repository:

```bash
git add -A && git commit -m "Add podinfo GitRepository"
git push
```

Use the flux create command to create a Kustomization that applies the podinfo deployment:

``` bash
flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/podinfo-kustomization.yaml
```
``` bash
flux create kustomization react-app \
  --target-namespace=default \
  --source=react \
  --path="./deploy/manifests" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/react-app-kustomization.yaml
```


Commit and push the Kustomization manifest to the repository:

```bash
git add -A && git commit -m "Add podinfo Kustomization"
git push
```

Use the flux get command to watch the podinfo app:

```bash
flux get kustomizations --watch
```

Check podinfo has been deployed on your cluster:

```bash
kubectl -n default get deployments,services
```

Forward a port for now until I figure out a better way:

```bash
kubectl port-forward svc/react-application 8080:8080 -n default
```

## Embedding Security in a Flux Pipeline

Create the namespace for Starboard:

``` bash
kubectl -n default get deployments,services
```
Use flux cli to source starboard artifact:

``` bash
flux create source helm starboard-operator --url <https://aquasecurity.github.io/helm-charts> --namespace starboard-system
flux create helmrelease starboard-operator --chart starboard-operator **\\**
  --source HelmRepository/starboard-operator **\\**
  --chart-version 0.10.3 **\\**
  --namespace starboard-system
  ```

  Deploy the app:
``` bash
flux create kustomization react-app \\
  --target-namespace=app \\
  --source=react \\
  --path="./manifests" \\
  --prune=true \\
  --interval=5m \\
  ```