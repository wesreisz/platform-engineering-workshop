Note: we're picking up from pipelines
4- Install flux
`brew install fluxcd/tap/flux`

5 - Check your k8 cluster meets flux requirements:
```bash
flux check --pre
```

6 - Create a new repository in Gitea using the API
```bash
export GITEA_URL="http://gitea-http.gitea.svc.cluster.local:3000"
export GITEA_REPO_NAME="fleet-infra"
curl -u "gitea:gitea" \
     -X POST "$GITEA_URL/api/v1/user/repos" \
     -H "Content-Type: application/json" \
     -d "{\"name\":\"$GITEA_REPO_NAME\",\"private\":false}"
```

6 - bootstrap your cluster fleet
```bash
flux bootstrap git \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git \
--branch=main \
--path=clusters/mycluster \
--password=gitea \
--allow-insecure-http=true \
--username=gitea \
--token-auth=true \
--interval=30m \
--components-extra image-reflector-controller,image-automation-controller
```

9 - Register your app repository as a Flux source. We're using the tilt-avatars 
```bash
flux create source git tilt-avatars \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars \
--branch=main \
--interval=1m
```

10 - list sources
`flux get sources all`

10 - Deploy your application 
```bash
flux create kustomization tilt-avatars-app \
--target-namespace=default \
--source=tilt-avatars \
--path="./deploy" \
--prune=true \
--wait=true \
--interval=5m
```