# K8s Glance Image

This folder shows an example of how to use the [install-k8s](../../modules/install-k8s) module with [Packer](https://www.packer.io/) to create an [an Openstack Glance Image](https://docs.openstack.org/glance/latest/) that has Etcd installed on top of CensOS 7.

This image will have kubernetes binary pre-installed. To see how to deploy this image, check out the [module's main script](../../README.md). 

For more info on K8s installation and configuration, check out the [install-k8s](../../modules/install-k8s) documentation.

## Quick start

To build the k8s Glance Image:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Install the openstac cli by running `pip install python-openstackclient`.
1. Configure your Openstack credentials using one of the [options supported by the Openstack API](https://developer.openstack.org/api-guide/quick-start/api-quick-start.html). 
1. Update the `variables` section of the `packer.json` Packer template to configure the Openstack region, K8s version you wish to use.
1. Run `packer build -var "ext_net_id=<Ext-Net Id>" packer.json`.
1. Or run `make`.

When the build finishes, it will output the ID of the new Glance Image. To see how to deploy this image, check out the [module's main script](../../README.md).


## Creating your own Packer template for production usage

When creating your own Packer template for production usage, you can copy the example in this folder more or less exactly, except for one change: we recommend replacing the `file` provisioner with a call to `git clone` in the `shell` provisioner. Instead of:

```json
{
  "provisioners": [ 
    {
      "type": "file",
      "source": "{{template_dir}}/../../modules",
      "destination": "/tmp/current-module"
    }]
}
```

Your code should look more like this:

```json
{
   "provisioners": [
    {
      "type": "shell-local",
      "command": "git clone --branch <MODULE_VERSION>  https://github.com/ovh/terraform-ovh-publiccloud-k8s.git {{template_dir}}/tmp-module/terraform-ovh-k8s"
    }]
}
```

You should replace `<MODULE_VERSION>` in the code above with the version of this module that you want to use (see the [Releases Page](../../releases) for all available versions). That's because for production usage, you should always use a fixed, known version of this Module, downloaded from the official Git repo. On the other hand, when you're just experimenting with the Module, it's OK to use a local checkout of the Module, uploaded from your own computer.
