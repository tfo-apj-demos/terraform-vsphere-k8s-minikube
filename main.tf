data "hcp_packer_image" "docker-ubuntu-2204" {
  bucket_name    = "docker-ubuntu-2204"
  channel        = "latest"
  cloud_provider = "vsphere"
  region         = "Datacenter"
}

module "vm" {
  source = "github.com/tfo-apj-demos/terraform-vsphere-virtual-machine"

  template          = data.hcp_packer_image.docker-ubuntu-2204.cloud_image_id
  hostname          = var.hostname
  num_cpus          = local.sizes[var.size].cpu
  memory            = local.sizes[var.size].memory
  cluster           = local.environments[var.environment]
  datacenter        = local.sites[var.site]
  primary_datastore = local.storage_profile[var.storage_profile]
  resource_pool     = local.tiers[var.tier]
  tags = {
    environment      = var.environment
    site             = var.site
    backup_policy    = var.backup_policy
    tier             = var.tier
    storage_profile  = var.storage_profile
    security_profile = var.security_profile
  }
  folder_path = var.folder_path
  disk_0_size = 200

  networks = {
    "seg-general" = "dhcp"
  }

  userdata = templatefile("${path.module}/templates/userdata.yaml.tmpl", {
    hostname    = var.hostname
    sshkey  = var.sshkey
    github_token = var.github_token
  })

  metadata = templatefile("${path.module}/templates/metadata.yaml.tmpl", {
    dhcp     = true
    hostname = var.hostname
  })
}