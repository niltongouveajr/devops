#cloud-config

apt:
  conf: |
    Acquire::Retries "60";
    DPkg::Lock::Timeout "60";

package_update: true

packages:
  - bc
  - curl
  - figlet
  - git-core
  - locales
  - net-tools
  - toilet
  - tree
  - tzdata
  - unzip
  - zip

runcmd:
  - locale-gen en_US.UTF-8
  - ln -snf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && echo "America/Sao_Paulo" > /etc/timezone
  - update-locale LANG=en_US.UTF-8 
  - update-locale LC_ALL=en_US.UTF-8
  - rm /etc/issue.net
  - ln -s /etc/issue /etc/issue.net
  - figlet -w 44 -c -f standard DevOps > /etc/issue
  - sed -i "s|^|   |g" /etc/issue
  - echo "\nThis system is  restricted solely to authorized users\nfor  legitimate business purposes only. The actual or\nattempted  unauthorized  access, use or modifications\nof this system is  strictly  prohibited. Unauthorized\nusers  are subject to company disciplinary procedures\nand  or  criminal  and  civil  penalties under state,\nfederal or other applicable domestic and foreign laws.\n\nThe use of this  system may be monitored/recorded for\nadministrative and security reasons. Anyone accessing\nthis system expressly consents to such monitoring and\nrecording, and is advised that if it reveals possible\nevidence of  criminal  activity, the evidence of such\nactivity may be provided to law enforcement officials.\n\nAll users must comply with all corporate instructions\nregarding the protection of information assets.\n\nRegards,\nDevOps Team\n" >> /etc/issue
  - sed -i "s|ENABLED=1|ENABLED=0|g" /etc/default/motd-news
  - chmod -x /etc/update-motd.d/*
  - echo -n > /etc/legal
  - echo -n > /home/devops/.hushlogin

write_files:
  - path: /etc/ssh/sshd_config
    owner: root:root
    permissions: '0644'
    content: |
      Port 2233
      Protocol 2
      HostKey /etc/ssh/ssh_host_rsa_key
      HostKey /etc/ssh/ssh_host_dsa_key
      HostKey /etc/ssh/ssh_host_ecdsa_key
      HostKey /etc/ssh/ssh_host_ed25519_key
      SyslogFacility AUTH
      LogLevel INFO
      LoginGraceTime 120
      PermitRootLogin no
      StrictModes yes
      PubkeyAuthentication yes
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      ChallengeResponseAuthentication no
      X11Forwarding yes
      X11DisplayOffset 10
      PrintMotd no
      PrintLastLog no
      TCPKeepAlive yes
      Banner /etc/issue.net
      AcceptEnv LANG LC_*
      Subsystem sftp /usr/lib/openssh/sftp-server
      UsePAM yes
      UseDNS no
      GSSAPIAuthentication no
      ClientAliveInterval 1200
      ClientAliveCountMax 3
  - path: /etc/sysctl.conf
    owner: root:root
    permissions: '0644'
    content: |
      #
      # /etc/sysctl.conf - Configuration file for setting system variables
      # See /etc/sysctl.d/ for additional system variables.
      # See sysctl.conf (5) for information.
      #
      
      # IP Spoofing protection
      net.ipv4.conf.all.rp_filter = 1
      net.ipv4.conf.default.rp_filter = 1
      
      # Ignore ICMP broadcast requests
      net.ipv4.icmp_echo_ignore_broadcasts = 1
      
      # Disable source packet routing
      net.ipv4.conf.all.accept_source_route = 0
      net.ipv6.conf.all.accept_source_route = 0 
      net.ipv4.conf.default.accept_source_route = 0
      net.ipv6.conf.default.accept_source_route = 0
      
      # Ignore send redirects
      net.ipv4.conf.all.send_redirects = 0
      net.ipv4.conf.default.send_redirects = 0
      
      # Block SYN attacks
      net.ipv4.tcp_syncookies = 1
      net.ipv4.tcp_max_syn_backlog = 2048
      net.ipv4.tcp_synack_retries = 2
      net.ipv4.tcp_syn_retries = 5
      
      # Log Martians
      net.ipv4.conf.all.log_martians = 1
      net.ipv4.icmp_ignore_bogus_error_responses = 1
      
      # Ignore ICMP redirects
      net.ipv4.conf.all.accept_redirects = 0
      net.ipv6.conf.all.accept_redirects = 0
      net.ipv4.conf.default.accept_redirects = 0 
      net.ipv6.conf.default.accept_redirects = 0
      
      # Ignore Directed pings
      #net.ipv4.icmp_echo_ignore_all = 1
      
      # Fix some known problems
      fs.inotify.max_user_watches=524288
      net.netfilter.nf_conntrack_max = 131072
      vm.max_map_count = 262144
