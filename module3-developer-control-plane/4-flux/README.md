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

8 - Register your app repository as a Flux source. We're using the tilt-avatars 
```bash
flux create source git tilt-avatars \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars \
--branch=main \
--interval=1m
```

9 - list sources
`flux get sources all`

10 - Update our app deployments to use k3d

11 - Deploy your application 
```bash
flux create kustomization tilt-avatars-app \
--target-namespace=default \
--source=tilt-avatars \
--path="./deploy" \
--prune=true \
--wait=true \
--interval=3m
```

it fails because we moved the image location to an internal registry. let's remap it.

12 - Update the images
```bash
#image: tilt-avatar-web
image: registry.localhost:5000/tilt-avatar-web:v2
```

```bash
#image: tilt-avatar-api
image: registry.localhost:5000/tilt-avatar-api:v2
```

12 - Commit it and it will redeploy.
13 - Make changes and trigger reploys.

NOTE: I didn't configure the additional plugin to track version commits and autodeploy but this is possible.

