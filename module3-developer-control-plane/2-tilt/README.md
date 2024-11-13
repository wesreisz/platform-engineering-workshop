NOTE: Skip to 2 if you just did the previous section.

1 - Create a cluster. We're also setting up a registry inside the cluster that we'll use for images. Note: There isn't a UI on this registry.
```bash
export K3D_FIX_DNS=0
k3d cluster create mycluster --agents 3 --registry-create registry.localhost:5000 -p "80:80@loadbalancer"
```

1a - Install Tilt: Tilt is already installed on the VDI we're using. If you're doing this locally, you can install it using `brew install tilt`

2 - clone the code repo to a folder outside your current repo on the local machine (such as your home directory `cd ~/`)
`git clone https://github.com/wesreisz/tilt-avatars.git`

3 - Run Tilt using 
```bash
cd tilt-avatars
tilt up
```

4 - Make a code change