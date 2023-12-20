terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "./tf_key.json"
  folder_id                = var.folder
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "ydtfpntwrk" {}

resource "yandex_vpc_subnet" "ydtfpsbnt" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ydtfpntwrk.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

locals {
  service-accounts = toset([
    "ydtfp-sa", 
    "ydtfp-ig-sa",
    ])
  ydtfp-sa-roles = toset([
    "container-registry.images.puller", 
    "monitoring.editor",
    ])
  ydtfp-ig-sa-roles = toset([
    "compute.editor", 
    "iam.serviceAccounts.user", 
    "load-balancer.admin", 
    "vpc.publicAdmin", 
    "vpc.user",
    ])
}

resource "yandex_iam_service_account" "sa" {
  for_each = local.service-accounts
  name = each.key
}

resource "yandex_resourcemanager_folder_iam_member" "ydtfp-roles" {
  for_each = local.ydtfp-sa-roles
  folder_id = var.folder
  member = "serviceAccount:${yandex_iam_service_account.sa["ydtfp-sa"].id}"
  role = each.key
}

resource "yandex_resourcemanager_folder_iam_member" "ydtfp-ig-roles" {
  for_each = local.ydtfp-ig-sa-roles
  folder_id = var.folder
  member = "serviceAccount:${yandex_iam_service_account.sa["ydtfp-ig-sa"].id}"
  role = each.key
}

resource "yandex_compute_instance_group" "ydtfp" {
  name                = "ydtfp-ig"
  folder_id           = var.folder
  service_account_id  = yandex_iam_service_account.sa["ydtfp-ig-sa"].id
  depends_on = [ yandex_resourcemanager_folder_iam_member.ydtfp-ig-roles ]
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  instance_template {
    platform_id = "standard-v3"
    service_account_id = yandex_iam_service_account.sa["ydtfp-sa"].id
    resources {
      cores  = 2
      memory = 2
      core_fraction = 20
    }
    boot_disk {
      initialize_params {
        size = 18
        image_id = "fd89cudngj3s2osr228p"
      }
    }
    network_interface {
      network_id = yandex_vpc_network.ydtfpntwrk.id
      subnet_ids = ["${yandex_vpc_subnet.ydtfpsbnt.id}"]
      nat = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/devops_training.pub")}"
      user-data = file("${path.module}/cloud-config.yaml")
    }
  }
  deploy_policy {
    max_expansion   = 1
    max_unavailable = 1
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  load_balancer {
    target_group_name = "ydtfp"
  }
}

resource "yandex_lb_network_load_balancer" "lb-ydtfp" {
  name = "ydtfp"
  listener {
    name = "ydtfp-listener"
    port = 80
    target_port = 17534
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ydtfp.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 17534
        path = "/ping"
      }
    }
  }
}

resource "yandex_compute_instance" "postgres" {
  name = "postgres"
  platform_id = "standard-v3"
  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      size = "18"
      image_id = "fd89cudngj3s2osr228p"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.ydtfpsbnt.id}"
    nat = true
  }
  metadata = {
    user-data = file("${path.module}/cloud-config.yaml")
    ssh-keys = "ubuntu:${file("~/.ssh/devops_training.pub")}"
  }
}
