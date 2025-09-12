terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.5.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# ---------------- Data Lookups ----------------
data "vsphere_datacenter" "dc" {
  name = var.dc_name
}

data "vsphere_host" "esxi" {
  name          = var.esxi_host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  datacenter_id = data.vsphere_datacenter.dc.id
  name          = var.template_path
}

# ---------------- DNS Server VM ----------------
resource "vsphere_virtual_machine" "dns_server" {
  name             = var.dns_hostname
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = var.dns_cpu
  memory   = var.dns_memory_mb
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  firmware = "efi"

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.dns_hostname
        domain    = var.domain_name
      }

      network_interface {
        ipv4_address = var.dns_ip
        ipv4_netmask = 24
      }

      ipv4_gateway = var.gateway
    }
  }

  # -------- Install & Configure BIND --------
  provisioner "remote-exec" {
    inline = [
      "yum install -y bind bind-utils || apt-get update && apt-get install -y bind9 dnsutils",
      "mkdir -p /etc/named/zones",
      
      # Forward zone file
      "cat > /etc/named/zones/db.${var.domain_name} <<'EOF'\n${templatefile("${path.module}/templates/forward.tpl", { domain_name = var.domain_name, dns_hostname = var.dns_hostname, hosts = var.hosts })}\nEOF",

      # Reverse zone file
      "cat > /etc/named/zones/db.${var.reverse_zone} <<'EOF'\n${templatefile("${path.module}/templates/reverse.tpl", { domain_name = var.domain_name, dns_hostname = var.dns_hostname, reverse_zone = var.reverse_zone, hosts = var.hosts })}\nEOF",

      # Update named.conf
      "cat >> /etc/named.conf <<EOC\nzone \"${var.domain_name}\" IN { type master; file \"/etc/named/zones/db.${var.domain_name}\"; allow-update { none; }; };\nzone \"${var.reverse_zone}.in-addr.arpa\" IN { type master; file \"/etc/named/zones/db.${var.reverse_zone}\"; allow-update { none; }; };\nEOC",

      "systemctl enable named || systemctl enable bind9",
      "systemctl restart named || systemctl restart bind9"
    ]
  }
}

output "dns_server_ip" {
  value = var.dns_ip
}
