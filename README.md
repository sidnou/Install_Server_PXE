# Install_Server_PXE
Script pour installer un SERVEUR PXE sur Debian ou Ubuntu

Les Postes clients minimum 2Go RAM 
Certain ISO font environ 1Go  

ISO:
Clonezilla
Ultimate Boot CD



Installation des services 
isc-dhcp-server tftpd-hpa pxelinux syslinux  


Les adresse IP
eth0 :                  192.168.1.23
Masque sous-réseau :    255.255.255.0
Passerelle :            192.168.1.1
eth1 :                  192.168.2.1
Masque sous-réseau :    255.255.255.0

Plage adressage IP du DHCP 
192.168.2.100 à 192.168.2.200


