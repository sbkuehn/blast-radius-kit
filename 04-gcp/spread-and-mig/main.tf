# 04-gcp/spread-and-mig: the rack layer and the building layer.
# A spread placement policy puts instances in one zone across isolated
# availability domains (up to 8). A regional managed instance group spreads
# instances across zones.
# Docs: https://docs.cloud.google.com/compute/docs/instances/placement-policies-overview

locals {
  labels = {
    project = "blast-radius-kit"
  }
}

resource "google_compute_network" "this" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.prefix}-subnet"
  network       = google_compute_network.this.id
  region        = var.region
  ip_cidr_range = "10.43.1.0/24"
}

# Rack layer --------------------------------------------------------------

resource "google_compute_resource_policy" "spread" {
  name   = "${var.prefix}-spread"
  region = var.region

  group_placement_policy {
    availability_domain_count = var.availability_domain_count
  }
}

resource "google_compute_instance" "spread" {
  count             = var.spread_instance_count
  name              = "${var.prefix}-spread-${count.index}"
  zone              = var.spread_zone
  machine_type      = var.instance_size
  resource_policies = [google_compute_resource_policy.spread.id]
  labels            = merge(local.labels, { layer = "rack" })

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.this.id
  }
}

# Building layer ----------------------------------------------------------

resource "google_compute_instance_template" "mig" {
  name_prefix  = "${var.prefix}-mig-"
  machine_type = var.instance_size
  labels       = merge(local.labels, { layer = "building" })

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.this.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${var.prefix}-mig"
  region             = var.region
  base_instance_name = "${var.prefix}-mig"
  target_size        = var.instance_count

  distribution_policy_zones        = var.zones
  distribution_policy_target_shape = "EVEN"

  version {
    instance_template = google_compute_instance_template.mig.id
  }
}
