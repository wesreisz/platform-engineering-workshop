Note: we're picking up from pipelines. You will need to complete pipelines before continuing here.
This requires a git instance.

1- Install flux
`brew install fluxcd/tap/flux`

2 - Check your k8 cluster meets flux requirements:
```bash
flux check --pre
```

3 - Create a new repository in Gitea using the API
```bash
export GITEA_URL="http://gitea-http.gitea.svc.cluster.local:3000"
export GITEA_REPO_NAME="fleet-infra"
curl -u "gitea:gitea" \
     -X POST "$GITEA_URL/api/v1/user/repos" \
     -H "Content-Type: application/json" \
     -d "{\"name\":\"$GITEA_REPO_NAME\",\"private\":false}"
```

7 - bootstrap your cluster fleet
```bash
flux bootstrap git \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git \
--branch=main \
--path=clusters/mycluster \
--password=gitea \
--allow-insecure-http=true \
--username=gitea \
--token-auth=true \
--interval=30m 
```

NOTE: Make sure your deployment files are configured to use the internal registry. To switch to the internal registry, swap these the comment on these two lines in your deployment descriptions (`/deploy/web.yaml` and `/deploy/api.yaml`):
```yaml api.yaml
image: tilt-avatar-api
#image: registry.localhost:5000/tilt-avatar-api:v2
```
```bash web.yaml
#image: tilt-avatar-web
image: registry.localhost:5000/tilt-avatar-web:v2
```

8 - Register your app repository as a Flux source. We're using the tilt-avatars project we had before. Also this command will generate the file to register the source in your mycluster folder. It would be greated until it's commited and deployed 
```bash
flux create source git tilt-avatars \
  --url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars.git \
  --branch=main \
  --interval=1m \
  --export > ./clusters/mycluster/tilt-avatars-source.yaml
```

NOTE: Because there are files in the deploy directory that are not k8s yaml, the automatic deployment will silently fail. So we need to excluse those files. After generating this yaml, open it and edit to exclude the two dockerfiles in deploy. Here is what is should look like:
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: tilt-avatars
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  url: http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars.git
  ignore: |
    # include deploy dir
    !/deploy
    # exclude non-Kubernetes YAMLs
    /deploy/api.dockerfile
    /deploy/web.dockerfile
```

11 - Create your Kustomization. 
```bash
flux create kustomization tilt-avatars \
  --target-namespace=default \
  --source=tilt-avatars \
  --path="./deploy" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/mycluster/tilt-avatar-kustomization.yaml
```

NOTE: It may fails if you didn't move the image to the internal registry. 

12 - Commit and push your code to the infra repo
```bash
git add .
git commit -m "adding flux source/kustomization for tilt avatars"
```

13 - List sources. You will see the kustomization kick off the deployment and then if you're still running k8s, you can see the pods deploy. 
```bash
watch flux get kustomizations
```


