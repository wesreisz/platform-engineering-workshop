1 - Create a cluster. We're also setting up a registry inside the cluster that we'll use for images. Note: There isn't a UI on this registry.
```bash
export K3D_FIX_DNS=0
k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000
```

2 - clone the code repo to your local machine
`git clone https://github.com/wesreisz/tilt-avatars.git`

3 tilt up