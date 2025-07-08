# proxmox-sighup-installer

Terraform and Ansible scripts to bootstrap a SIGHUP Distribution (Kubernetes) cluster
on Proxmox!

More info on [this blog post](https://tobiabocchi.me/posts/proxmox-terraform-k8s/)

## Instructions

After adjusting all the variables in `variables.tf`, especially in the first section
(proxmox) run `terraform apply` to create the VMs that will be part of the cluster.

Now we need to setup `/etc/hosts` on each VM and on our local machine so that all
the hosts can lookup each other:

```sh
cd ansible
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook update_etc_hosts.yaml -i hosts.yaml
sudo tee -a /etc/hosts < hosts > /dev/null
```

Now, to install kubernetes and SIGHUP distribution:

```sh
cd k8s
furyctl create pki --outdir $(pwd)
furyctl apply --outdir $(pwd)
# Annotate local-path to be default storage class and re-apply to complete the installation
kubectl --kubeconfig kubeconfig annotate storageclass local-path "storageclass.kubernetes.io/is-default-class"="true"
furyctl apply --outdir $(pwd) --phase distribution
```
