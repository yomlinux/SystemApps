$TTL 1D
@   IN SOA  ${dns_hostname}.${domain_name}. root.${dns_hostname}.${domain_name}. (
                2025091101 ; serial
                1D         ; refresh
                1H         ; retry
                1W         ; expire
                3H )       ; minimum

    IN  NS   ${dns_hostname}.${domain_name}.
${dns_hostname}  IN A  ${hosts["${dns_hostname}"]}

%{ for name, ip in hosts ~}
${name} IN A ${ip}
%{ endfor }
