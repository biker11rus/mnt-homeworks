---
all:
  hosts:
%{ for index, vms in vm-names ~}
    ${vms}:
      ansible_host: ${public-ip[index]}
      local_ip: ${private-ip[index]}
%{ endfor ~}
  vars:
    ansible_connection: ssh
    ansible_user: ${ssh_user}

%{ for indexgp, group in ansible-group ~}
${group}:
  hosts:
    ${vm-names[indexgp]}:
%{ endfor ~}