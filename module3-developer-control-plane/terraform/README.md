# Build k3d server using terraform
1. Install Terraform
`brew install terraform`
2. initialize terraform 
`terraform init`
3. User the k3d provider to provision and create k3d clusters
`terraform plan`
`terraform apply`
`terraform destroy`

NOTE: On a m1, there maybe a dns issue if that's the case you need to disable a features gflag
using an env variable: `export K3D_FIX_DNS=0`
