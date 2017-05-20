/etc/hosts:
  file.managed:
    - source: salt://system/hosts
    - user: root
    - group: root
    - mode: 640

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://system/sshd_config
    - user: root
    - group: root
    - mode: 640

/home/pirate/.ssh:
  file.directory:
    - user: pirate
    - group: pirate
    - mode: 700
    - makedirs: True

/home/pirate/.ssh/authorized_keys:
  file.managed:
    - source: salt://system/authorized_keys
    - user: pirate
    - group: pirate
    - mode: 600
