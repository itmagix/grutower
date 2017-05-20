$ cat init.sls 
/etc/salt/minion:
  file.managed:
    - source: salt://minion/minion
    - user: root
    - group: root
    - mode: 640
