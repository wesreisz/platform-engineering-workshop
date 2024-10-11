# Flux Workshop: CI/CD with a Simple Website



Delete the existing kind cluster:

```bash
k3d cluster delete mycluster
```
Create a new kind cluster:
```bash
k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000
```

### Step 5: Install Gitea for Git Server Functionality
Add the Gitea Helm chart repository:


```bash
brew install helm
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
```

Create the gitea namespace:

```bash
kubectl create namespace gitea
```

Install Gitea using Helm:

```bash
helm install gitea gitea-charts/gitea -n gitea
```

* Wait for the Gitea pods to be ready (this may take about a minute).

### Step 6: Expose Gitea Using kubectl port-forward

Forward port 3000 to access Gitea:

``` bash
kubectl port-forward svc/gitea-http -n gitea 3000:3000
```

* Note: Open a new terminal tab to continue executing further commands.

Access Gitea in your browser at:

http://localhost:3000

### Step 7: Register a User in Gitea
Open the Gitea web interface at http://localhost:3000.

Click on "Register" to create a new user account.

Fill out the registration form to create the new user. This user will have administrative privileges by default if it is the first user created.


### Step 8: Initialize a Local Git Repository and Push to Gitea
We're going to clone a GitHub repository, remove the original remote, and automatically create a new repository in Gitea using your newly created credentials. This allows you to have a local copy of the project in Gitea.

To run the script, participants need to execute it with their Gitea username and password as arguments, like this: 

``` bash 
bash create-repo.sh <gitea-username> <gitea-password>
``` 

### Install an Actions Runner for GITEA

Your pipeline needs a runner to do the building, lets make one in our cluster.

First you'll need a registration token from gitea. Go into Gitea => Settings => Actions => Runners and click 'create new runner'. Copy the token and place it in the register-act-runner.yaml file under the value of GITEA_RUNNER_REGISTRATION_TOKEN.

Now save and run:

``` bash
kubectl apply -f -n act-runner deploy-act-runner.yaml
```

Your runner should create in the cluster and once completed, be visible in gitea when clicking on the 'Runners' menu item

### Step 10: Install flux for CICD:

Now that we have gitea set up with a potential runner, let's install our CI/CD to allow us to actually deploy something.

We're going to use flux-cd

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

### Step 11: Check your k8 cluster meets flux requirements:

```bash
flux check --pre
```

### Step X: Configure flux to trigger the build script

Flux can listen to webhooks via a receiver. You can create a Receiver resource like this:

Create the Webhook Secret for the receiver:

You need a Kubernetes secret containing the webhook token that GitHub will use. This can be done using:

```bash
kubectl create secret generic webhook-token \
  --from-literal=token=your-github-webhook-secret-token \
  --namespace=flux-system
```

Create the receiver

```bash
flux create receiver github-receiver \
  --type github \
  --event ping \
  --event push \
  --secret-ref webhook-token \
  --resource GitRepository/react-article-display
```

Make a note of the webhook url that was generated.
/hook/b0859a57efb94200a461ceb3b8c70b9b35f4a768eacf39fa788c73f4f5760932

Create webhook in gitea

Run the following command and make a note of the webhook receiver ip. We will give this to gitea when we create the webhook:

``` bash
kubectl get svc -n flux-system
```

ip = *add here*

Go back to your Gitea window and click on the react-application repo. Click settings and then click webhooks. Click create a new webhook and enter the webhook and the address of the webhook receiver. It should look something like this:

```
http://10.43.169.36/hook/<generated-token>
```

In secret token, enter ```webhook-token```


### Step 12: Bootstrap in flux the repo you'll be using:

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
git clone https://github.com/$GITHUB_USER/react-app
cd react-app
```


Create a GitRepository manifest pointing to podinfo repository’s master branch:

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

Create the namespace for Trivy:

``` bash
kubectl create ns trivy-system
```
Use flux cli to source trivy artifact:

``` bash
flux create source helm trivy-operator --url https://aquasecurity.github.io/helm-charts --namespace trivy-system
  ```

``` bash
flux create helmrelease trivy-operator --chart trivy-operator \
  --source HelmRepository/trivy-operator \
  --chart-version 0.24.1 \
  --namespace trivy-system
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

  

## Trivy command that works (CLI)
trivy k8s kind-dev --scanners vuln --report summary

## create cluster k3d

k3d cluster create MyCluster --servers 1 -p "8081:80@loadbalancer" -p "443:443@loadbalancer" --registry-create registry:0.0.0.0:80


use the inbuilt registry



How to access local cluster gitea-http.gitea.svc.cluster.local