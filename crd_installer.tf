data "kubectl_server_version" "current" {}

data "helm_template" "charts" {
  for_each                   = { for chart, params in local.charts_merged : chart => params if params.enabled }
  name                       = each.key
  chart                      = each.key
  repository                 = each.value.repository
  version                    = each.value.version
  dependency_update          = true
  skip_tests                 = true
  include_crds               = true
  disable_openapi_validation = true
  render_subchart_notes      = false
  kube_version               = data.kubectl_server_version.current.version
  values                     = each.value.values
  dynamic "set" {
    for_each = { for param in each.value.set : param.name => {
      value = param.value
      type  = param.type
    } }
    content {
      name  = set.key
      value = set.value.value
      type  = set.value.type
    }
  }
  dynamic "set_list" {
    for_each = { for param in each.value.set_list : param.name => param.value }
    content {
      name  = set_list.key
      value = set_list.value
    }
  }
  dynamic "set_sensitive" {
    for_each = { for param in each.value.set_sensitive : param.name => {
      value = param.value
      type  = param.type
    } }
    content {
      name  = set_sensitive.key
      value = set_sensitive.value.value
      type  = set_sensitive.value.type
    }
  }
}

data "kubectl_file_documents" "manifests" {
  content = join("\n---\n", values(data.helm_template.charts)[*].manifest)
}

resource "kubectl_manifest" "crds" {
  for_each          = { for name, resource in data.kubectl_file_documents.manifests.manifests : name => resource if strcontains(resource, "kind: CustomResourceDefinition") }
  yaml_body         = each.value
  server_side_apply = var.server_side_apply
  apply_only        = var.apply_only
  force_new         = var.force_new
  force_conflicts   = var.force_conflicts
  sensitive_fields  = var.hide_fields
}
