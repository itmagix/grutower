/home/pirate/.bashrc:
  file.managed:
    - source: salt://profiles/bashrc
    - user: pirate
    - group: pirate
    - mode: 640

/root/.bashrc:
  file.managed:
    - source: salt://profiles/bashrc
    - user: root 
    - group: root 
    - mode: 640
