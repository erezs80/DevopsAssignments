output "traffic_fqdn" {
    value = module.trafficmanager.traffic_fqdn
}

output "tls_private_key" {
     value = tls_private_key.ssh.private_key_pem
}