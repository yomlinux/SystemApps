# -------- vSphere Credentials --------
variable "vsphere_user"     { default = "administrator@dnixx.comm" }
variable "vsphere_password" { sensitive = true }
variable "vsphere_server"   { default = "10.0.0.120" }

variable "dc_name"          { default = "DNIXX" }
variable "esxi_host_name"   { default = "10.0.0.121" }
variable "datastore_name"   { default = "proddata1" }
variable "network_name"     { default = "VM Network" }
variable "template_path"    { default = "/DNIXX/vm/test" }

# -------- DNS Server Config --------
variable "dns_hostname" { default = "dns101" }
variable "dns_ip"       { default = "10.0.0.122" }
variable "gateway"      { default = "10.0.0.1" }
variable "domain_name"  { default = "dnixx.comm" }
variable "reverse_zone" { default = "0.0.10" } # for 10.0.0.x network

variable "dns_cpu"      { default = 2 }
variable "dns_memory_mb"{ default = 4096 }

# -------- DNS Host Entries --------
variable "hosts" {
  type = map(string)
  default = {
    "prodvcenter" = "10.0.0.120"
    "prodesxi101" = "10.0.0.121"
    "dns101"      = "10.0.0.122"
    "k8smaster1"  = "10.0.0.131"
    "k8smaster2"  = "10.0.0.132"
    "k8sworker1"  = "10.0.0.133"
    "k8sworker2"  = "10.0.0.134"
    "knfs"        = "10.0.0.135"
  }
}
