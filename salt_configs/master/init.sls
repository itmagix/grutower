/etc/salt/master:
  file.managed:
    - source: salt://master/master
    - user: root
    - group: root
    - mode: 640
