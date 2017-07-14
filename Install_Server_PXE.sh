#!/bin/bash
############################################################################
############################################################################
#
#
#
#                     Install_Server_PXE.sh
#                          Version 1.0.2
#                    sidney jacques sidjack972@gmail.com
#
#
############################################################################
# Définition: Script d'installation d'un serveur DHCP et PXE 
#
###########################################################################
# VERSION:  1.0.2 25/05/17 Améloiration visuel du script et teste de la 
#                          présence des dossier et fichier 
#            
#           1.0.1 18/04/17 Améloiration visuel du script
#           1.0 14/04/17 Création du script
#           
#
##########################################################################
##########################################################################
#
#
##########################################################################
##########################################################################
#==================== Informations =======================================
echo -e "\033[1;33m"
echo "==================================================================="
echo "==================================================================="
echo " Ce script installe tous les composants nécéssaires "
echo " Composants : "
echo " isc-dhcp-server tftpd-hpa pxelinux syslinux "
echo " Paramètre :"
echo "  DHCP : dhcp ==> eth1 "
echo "      Plage adresse IP 192.168.2.100  192.168.2.200"
echo " Adresse IP :"
echo "  eth0 :  192.168.1.23"
echo "          255.255.255.0"
echo "          192.168.1.1"
echo "  eth1 :  192.168.2.1"
echo "          255.255.255.0"
echo "==================================================================="
echo "==================================================================="
echo -e "\033[0m\n"

#==================== Variables globale ==================================
nombreCarteEthernet=0
# Fichier image ISO à telecharger
clonezillaVersion="2.5.0-25" # Vession Stable Clonezilla
ubcdVersion="537"

#=========================== DEBUT DU SCRIPT =============================

#====================== Verification que l'utilisateur soit bien root ====
i=$(id -u)
if [ $? -ne 0 ]
then exit 1
fi
if [ "$i" -ne 0 ]
then
echo -e "\033[1;31mL'installation doit se faire sous root\033[0m" >&2
exit 2
fi

#====================== verification Nombre carte réseau ===================
for var in 0 1 2 3 4 
do
    ifconfig eth$var>>/dev/null
    if [ $? -eq 0 ] 
    then
        nombreCarteEthernet=$(expr $nombreCarteEthernet + 1)
    elif [ $? -eq 1 ]
    then
        if [ $nombreCarteEthernet -lt 2 ]
        then
            echo " Vous avez $nombreCarteEthernet carte(s) réseau(x) ">&2
            echo " Vous avez moins 2 carte reseau sur votre machine !!!!">&2
            echo " Vous devez ajouter une autre carte reseau sur machine avant executer le script">&2
            exit 2
        fi
        break 
    fi
done 
#=========================== DOSSIERS ======================================
mkdir /tmp/tmpDownLoad
# Dossier logInstall
if [ -d "/var/log/logInstall" ]
then 
    # Fichier ServerPXE.log
    if [ ! -f "/var/log/Log_Install/ServerPXE.log" ] 
    then
        touch /var/log/logInstall/ServerPXE.log
    else
        echo "======================================================================">>/var/log/logInstall/ServerPXE.log
        echo "======================================================================">>/var/log/logInstall/ServerPXE.log
        echo "======================================================================">>/var/log/logInstall/ServerPXE.log
        echo "======================================================================">>/var/log/logInstall/ServerPXE.log
        echo "########## $(date +%a%d/%m/%y%t===========%t%T%t===========)##########">>/var/log/logInstall/ServerPXE.log
          
    fi
else
 mkdir /var/log/logInstall
 touch /var/log/logInstall/ServerPXE.log
fi

# Dossier tftpboot ISO pxelinux.cfg
if [ ! -d "/tftpboot" ]
then
    mkdir /tftpboot
    mkdir /tftpboot/pxelinux.cfg
fi

if [ ! -d "/tftpboot/ISO" ]
then
    mkdir /tftpboot/ISO
fi

if [ ! -d "/tftpboot/pxelinux.cfg" ]
then
    mkdir /tftpboot/pxelinux.cfg
fi

# Redirection Globale erreur et resultat vers ServerPXE.log
## exec 2>/var/log/logInstall/Erreur_ServerPXE.log

#=========================== Variables ===================================

jour=" ====== $(date +%a%d/%m/%y%t==============%t%T%t===========)"
# Cartes reseau eth0 eth1 
# Carte eth0
ipEth0=192.168.1.23                 # IP carte reseau eth0
netmskEth0=255.255.255.0            # Masque sous-reseau eth0
gtwayEth0=192.168.1.1               # Passerelle par defaut eth0
# Carte eth1
ipEth1=192.168.2.1                  # IP carte reseau eth1
netmskEth1=255.255.255.0            # Masque sous-reseau eth1

# DHCP
adressReseauIp=192.168.2.0          # Adresse reseaux 
plageIpDebut=192.168.2.100          # Plage de debut adressage IP 
plageIpFin=192.168.2.200            # Plage de fin adressage IP
masqSsreseau=255.255.255.0          # Masque sous-reseaux de plage adressage IP 
adresseSrvDns1="192.168.1.1"        # Adresse IP serveur DNS 1
adresseSrvDns2="192.168.2.1"        # Adresse IP serveur DNS 2 
domaine="teste.fr"                  # Domaine 
tempBailDefault=86400               # Bail par defaut (en seconde)
tempBailMax=691200                  # Bail Max (en seconde)



#=========================== FONCTIONS ====================================
function DownloadIso {
    # Creation fichier Temp 
    touch /tmp/tmpDownLoad/DownloadIso.sh
    cd /tmp/tmpDownLoad
    chmod +x DownloadIso.sh
    cat <<FICHIERDOWNLOADISO>DownloadIso.sh
    #!/bin/bash
    wget http://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/$clonezillaVersion/clonezilla-live-$clonezillaVersion-amd64.iso >&1 && mv clonezilla-live-$clonezillaVersion-amd64.iso /tftpboot/ISO/clonezilla-live-amd64.iso
    echo -e "ISO CLONEZILLA [\033[1;32m OK \033[0m]"
    wget http://ubcd.winsoftware-forum.de/ubcd$ubcdVersion.iso && echo $# && mv ubcd$ubcdVersion.iso /tftpboot/ISO/ubcd$ubcdVersion.iso
    echo -e "ISO ULTIMATE BOOT CD [\033[1;32m OK \033[0m]"
    wget http://rescuedisk.kaspersky-labs.com/rescuedisk/updatable/kav_rescue_10.iso && mv kav_rescue_10.iso /tftpboot/ISO/
    echo -e "ISO KASPERSKY RESCUE [\033[1;32m OK \033[0m]"
    wget http://www.hirensbootcd.es/download/Hirens.BootCD.15.2.zip && unzip Hirens.BootCD.15.2.zip && mv "Hiren's.BootCD.15.2.iso" /tftpboot/ISO/HirenSBootCD.iso
    echo -e "ISO HIRENs Boot CD 15.2 [\033[1;32m OK \033[0m]"

FICHIERDOWNLOADISO
    echo " Téléchargement ISO en-cours ...."
}

#=========================== Mise à jour du système ======================
echo -e "\033[1;32m"
echo "+---------------------------------------------------------+"
echo ":          DEBUT Mise à jour du système                   :" 
echo "+---------------------------------------------------------+"
echo -e "\033[0m"
echo $jour
apt-get update && apt-get dist-upgrade -y && echo -e "Mise a jour [\033[1;32m OK \033[0m]" || ping -c 4 8.8.4.4 || echo -en '\33[31m Problème de connexion a internet \33[0m'
#=========================== Configuration des Cartes reseaux ============
# Sauvegarde configuration des cartes reseaux
cp /etc/network/interfaces /etc/network/interfaces.original 
# Configuration cartes reseaux
cat <<FICHIERNET>/etc/network/interfaces
##########################################
#                                        #
#            Cartes Reseaux              #
#                                        #
##########################################
# loopback
auto lo 
iface lo inet loopback

# Premiere carte reseau eth0
auto eth0
  iface eth0 inet static
  address $ipEth0
  netmask $netmskEth0
  gateway $gtwayEth0

# Deuxieme carte reseau eth1
auto eth1
  iface eth1 inet static
  address $ipEth1
  netmask $netmskEth1
    
FICHIERNET

echo -e "Configuration des cartes reseau   [\033[1;32m OK \033[0m]"
echo -e "\033[1;32m"
echo "+---------------------------------------------------------+"
echo ":         DEBUT l'installation des services               :"
echo "+---------------------------------------------------------+"
echo -e "\033[0m"
#============================= Installation des Services et des Fichiers ========================================
# verification du service isc-dhcp-server
echo -e "\033[1;32m======= INSTALLATION SERVER DHCP =======\033[0m"
service isc-dhcp-server status >>/dev/null
if [ $? -ne 0 ]; then
    apt-get install isc-dhcp-server >>/dev/null && echo -e "Installation Server DHCP [\033[1;32m OK \033[0m]"
else
    service isc-dhcp-server stop >>/dev/null
    echo -e "\033[1;33mSERVICE ISC-DHCP-SERVER \033[1;31mARRETE\033[0m"
fi
# Verification du service Tftpd-hpa 
echo -e "\033[1;32m======= INSTALLATION SERVER TFTP =======\033[0m"
service tftpd-hpa status >>/dev/null
if [ $? -ne 0 ]; then
    apt-get install tftpd-hpa -y >>/dev/null && echo -e "Installation Server TFTP [\033[1;32m OK \033[0m]"
else
    service tftpd-hpa stop >>/dev/null
    echo -e "\033[1;33mSERVICE TFTPD-HPA \033[1;31mARRETE\033[0m"
fi
# Vérification du fichier pxelinux et syslinux
echo -e "\033[1;32m======= INSTALLATION SYSLINUX =======\033[0m"
if [ ! -d "/usr/lib/syslinux" ]; then
    apt-get install syslinux -y >>/dev/null && echo -e "Installation Syslinux[\033[1;32m OK \033[0m]"
else 
    echo -e "\033[1;33mDossier SYSLINUX existe déja !!!\033[0m"
fi
echo -e "\033[1;32m======= INSTALLATION PXELINUX =======\033[0m"
if [ ! -d "/usr/lib/PXELINUX" ]; then
    apt-get install pxelinux -y >>/dev/null && echo -e "Installation PXELINUX [\033[1;32m OK \033[0m]"
else
    echo -e "\033[1;33mDossier PXELINUX existe déja !!!\033[0m"
fi
# vérication du logiciel unzip 
echo -e "\033[1;32m======= INSTALLATION UNZIP =======\033[0m"
 unzip >>/dev/null
if [ $? -ne 0 ]; then
    apt-get install unzip && echo -e "Installation UNZIP [\033[1;32m OK \033[0m]"
else
    echo -e " \033[1;33mUnzip déja Installer\033[0m [\033[1;32m OK \033[0m] "
fi
#=========================== Configuration du Service DHCP ===================
# Sauvegarde du fichier de configuration original
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.original
# Configuration du service DHCP
cat > /etc/dhcp/dhcpd.conf << FICHIERDHCP
#################################################
#                                               #
#   Configuration simple ISC DHCP pour Debian   #
#                                               #
#################################################

# DHCP autoritaire
authoritative;       

ddns-update-style none;
# Option 
option routers $ipEth1;
# Addresse serveur DNS et domaine
option domain-name-servers $adresseSrvDns1, $adresseSrvDns2; 
option domain-name "$domaine";
# Bail
default-lease-time $tempBailDefault;       # Bail en (s)  1 jour 
max-lease-time $tempBailMax;          # Bail max en (s)  8 jours

log-facility local7;

# Distrubition adresse IP 
subnet $adressReseauIp netmask $masqSsreseau {
    # Plage adresse IP
    range $plageIpDebut $plageIpFin;
    
    
}
next-server $ipEth1;
filename "pxelinux.0";

FICHIERDHCP
# Activé NAT sur SERVER PXE à chaque démarrage du serveur 
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Configuration des Interfaces reseaux d'ecoute
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.original
sed -i 's/INTERFACES=""/INTERFACES="eth1"/' /etc/default/isc-dhcp-server
sed -i "/exit/i\/sbin/iptables -P FORWARD ACCEPT\n" /etc/rc.local
sed -i "/exit/i\/sbin/iptables --table nat -A POSTROUTING -o eth0 -j MASQUERADE" /etc/rc.local
#================== Copie des fichiers nécessaire pour PXE ===================
cp -R /usr/lib/syslinux/* /usr/lib/PXELINUX/* /tftpboot
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /tftpboot
#====================== Configuration du service TFPT ===================
cp /etc/default/tftpd-hpa /etc/default/tftpd-hpa.original
cat > /etc/default/tftpd-hpa << FICHIERTFTP 
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
FICHIERTFTP

#=============================== MENU PXE ===============================
cat > /tftpboot/pxelinux.cfg/default << MENUPXE
MENU TITLE SERVEUR PXE
PATH /modules/bios/
default menu.c32
prompt 0
noescape 1
timeout 300
LABEL 1
MENU LABEL Demarrer sur le premier disque dur
COM32 chain.c32
APPEND hd0

LABEL 2
MENU LABEL CLONEZILLA 64 BITS
LINUX memdisk
INITRD /ISO/clonezilla-live-amd64.iso
APPEND iso

LABEL 3
MENU LABEL Ultimate Boot CD
LINUX memdisk
INITRD /ISO/ubcd$ubcdVersion.iso 
APPEND iso

LABEL 4
MENU LABEL KASPERSKY RESCURE DISK 10
LINUX memdisk
INITRD /ISO/kav_rescue_10.iso 
APPEND iso raw

LABEL 5
MENU LABEL HIREN S BOOT CD 15.2
LINUX memdisk
INITRD /ISO/HirenSBootCD.iso
APPEND iso raw

LABEL 10
MENU LABEL Redemarrer 
COM32 reboot.c32
MENUPXE

# Redemarrage des services
echo "+----------------------------------------------------------------+" 
echo ":     Appliquer les modification sur les cartes reseaux          :"
echo "+----------------------------------------------------------------+"
/etc/init.d/networking restart 
echo "+----------------------------------------------------------------+" 
echo ":                Démmarrage du service DHCP                      :"
echo "+----------------------------------------------------------------+"
/etc/init.d/isc-dhcp-server restart 
echo "+----------------------------------------------------------------+" 
echo ":                Démmarrage du service TFTP                      :"
echo "+----------------------------------------------------------------+"
/etc/init.d/tftpd-hpa restart 
#=========================== TELECHAGEMENT ISO ===============================
DownloadIso
cd /tmp/tmpDownLoad/
./DownloadIso.sh
echo "Téléchargement finis"
rm DownloadIso.sh
# Effacement du dossier temporaire de téléchargement ISO
rm -R /tmp/tmpDownLoad
exit 0