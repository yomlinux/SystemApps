terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"  # Updated to a broader compatible version
    }
  }
}

provider "null" {}

resource "null_resource" "nfs_setup" {
  connection {
    type     = "ssh"
    host     = "10.0.0.134"
    user     = "root"
    password = ""
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      # Update system
      "yum update -y",

      # Install NFS server
      "yum install -y nfs-utils",

      # Enable and start NFS services
      "systemctl enable nfs-server",
      "systemctl start nfs-server",

      # Create directories for Kubernetes
      "mkdir -p /data/app1 /data/app2",

      # Set permissions (Kubernetes pods can write)
      "chmod 777 /data/app1 /data/app2",

      # Configure NFS exports
      "echo '/data/app1 *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports",
      "echo '/data/app2 *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports",

      # Reload exports
      "exportfs -ra",

      # Restart NFS service to apply changes
      "systemctl restart nfs-server"
    ]
  }
}
