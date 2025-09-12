$TTL 1D
@   IN SOA  ${dns_hostname}.${domain_name}. root.${dns_hostname}.${domain_name}. (
                2025091101 ; serial
                1D         ; refresh
                1H         ; retry
                1W         ; expire
                3H )       ; minimum

    IN  NS   ${dns_hostname}.${domain_name}.

%{ for name, ip in hosts ~}
${split(".", ip)[3]}  IN PTR  ${name}.${domain_name}.
%{ endfor }
