/etc/apt/sources.list.d/kubernetes.list:
  file.managed:
    - source: salt://repos/kubernetes.list
    - user: root
    - group: root
    - mode: 640
