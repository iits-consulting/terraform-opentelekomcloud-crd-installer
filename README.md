## Custom Resource Definition Installer

A module designed to automatically extract the crds from Helm charts and install them on the target kubernetes cluster. The module can be used with existing CRDs without importing.

> **WARNING:** This module will have a large footprint on the terraform state depending on the size and number of charts.  
> Module execution and subsequent state generation can take a longer than usual time due to the large size of the state the module generates.  
> It is recommended to use it as standalone in its own script to separate its state from other terraform scripts.

Usage example (overriding versions and disabling built-in default charts):
```hcl
module "crds" {
  source  = "iits-consulting/crd-installer/opentelekomcloud/"

  default_chart_overrides = {
    cert-manager = {
      version = "1.16.1"
    }
    traefik = {
      version = "32.1.1"
    }
    kyverno = {
      enabled = false
    }
    prometheus-stack = {
      version = "62.6.0"
    }
  }
}
```
Usage example (adding new charts for crd installation):
```hcl
module "crds" {
  source  = "iits-consulting/crd-installer/opentelekomcloud/"

  charts = {
    exampleChart1 = {
      repository = "https://charts.iits.tech"
      version    = "0.0.1"
      set = [{
        name  = "exampleChart1.installCRDs"
        value = true
      }]
    }
    exampleChart2 = {
      repository = "https://charts.iits.tech"
      version    = "0.0.2"
      set = [{
        name  = "exampleChart2.crds.install"
        value = true
      }]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.19 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.17 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.19 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.crds](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [helm_template.charts](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template) | data source |
| [kubectl_file_documents.manifests](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/file_documents) | data source |
| [kubectl_server_version.current](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/server_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_only"></a> [apply\_only](#input\_apply\_only) | Apply only, prevents destruction of CRDs. | `bool` | `true` | no |
| <a name="input_charts"></a> [charts](#input\_charts) | A map of additional charts and their parameters to extract CRDs from. (Please ensure that the CRD flags are set to true for the charts) | <pre>map(object({<br/>    repository = string<br/>    version    = string<br/>    enabled    = optional(bool, true)<br/>    values     = optional(list(string), [""])<br/>    set = optional(list(object({<br/>      name  = string<br/>      value = optional(string)<br/>      type  = optional(string)<br/>    })), [])<br/>    set_list = optional(list(object({<br/>      name  = string<br/>      value = list(string)<br/>    })), [])<br/>    set_sensitive = optional(list(object({<br/>      name  = string<br/>      value = string<br/>      type  = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_default_chart_overrides"></a> [default\_chart\_overrides](#input\_default\_chart\_overrides) | Overrides for the default charts. Supported parameters are: repository, version, enabled, values, set and set\_sensitive. (see https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template) | `map(any)` | `{}` | no |
| <a name="input_force_conflicts"></a> [force\_conflicts](#input\_force\_conflicts) | Apply using force-conflicts flag. | `bool` | `true` | no |
| <a name="input_force_new"></a> [force\_new](#input\_force\_new) | Forces delete & create of resources if the CRD manifest changes. | `bool` | `false` | no |
| <a name="input_hide_fields"></a> [hide\_fields](#input\_hide\_fields) | Hide the diff output of terraform by marking it as sensitive. Useful for less cluttered terraform output. See https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest#sensitive-fields for details. | `list(string)` | <pre>[<br/>  "apiVersion",<br/>  "kind",<br/>  "metadata",<br/>  "spec"<br/>]</pre> | no |
| <a name="input_server_side_apply"></a> [server\_side\_apply](#input\_server\_side\_apply) | Apply using server-side-apply method. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

