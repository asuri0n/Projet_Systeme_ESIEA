#!/bin/bash
#
# Projet Système ESIEA 3A CFA 2018
# Fait par Nathan CHEVALIER et Killian LETISSIER
#
# Script permettant du monitoring sur des machines Linux
#

clear
NOMLOGICIEL="Monitoring"
VERSION="V.1.0.01"
tab="######################################################################"

# Couleurs
rougefonce='\e[0;31m'
vertclair='\e[1;32m'
neutre='\e[0;m'

#Fonction d'aide
function help {
	echo -e "Script de monitoring pour votre machine Linux"
	echo -e "Vous avez ${vertclair}6 options ${neutre}au choix :"
	echo -e "${vertclair}-h${neutre} pour afficher l'aide"
	echo -e "${vertclair}-a${neutre} pour afficher l'ensemble des informations de la machine"
	echo -e "${vertclair}-c${neutre} pour afficher les informations du PC"
	echo -e "${vertclair}-p${neutre} pour éteindre la machine"
	echo -e "${vertclair}-r${neutre} pour afficher les ressources utilisées"
	echo -e "${vertclair}-s${neutre} pour mettre en veille la machine"
	echo -e "${vertclair}-u${neutre} pour afficher les informations sur l'utilisateur ou les utilisateurs"

}

#Fonction permettant de generer des titres
function title {
	echo -e "${vertclair}$tab"
	printf  "\n%*s\n\n" $(((${#tab}+$1)/2)) "$1"
	echo -e "$tab${neutre}\n"
}



#Fonction affichant les informations des utilisateurs 
function user {
	echo -e "${vertclair}USER : ${neutre} $USER"
	echo -e "${vertclair}UID : ${neutre}$(id -u)"
	echo -e "${vertclair}Groups : ${neutre}$(id -g)"
	echo -e "${vertclair}Utilisateur(s) connecté(s): ${neutre}"
	who
	echo -e "\n\n"
}

# Fonction affichant les informations du pc : os, processeur, noyau, IP externe, log de demarrage ...
function computer {
	echo -e "${vertclair}OS : ${neutre}$(lsb_release -d | cut -f2)"
	echo -e "${vertclair}Noyau : ${neutre}$(uname -r)"
	echo -e "${vertclair}Hostname : ${neutre}$HOSTNAME"
	echo -e "${vertclair}Type de processeur: ${neutre}$(uname -m)"
	echo -e "${vertlair}IP externe : ${neutre}$(curl -s ifconfig.co 2> /dev/null || echo "Impossible d'accéder à internet, veuillez installer curl ou vérifier votre connexion internet")"
    echo -e "${vertclair}CPU utilisation : ${neutre}$(grep 'cpu ' /proc/stat | awk '{utilisation=($2+$4)*100/($2+$4+$5)} END {print utilisation}' | grep -Eo "^....") %"

    #Log du demmarage
	cErrBoot=$(cat /var/log/syslog | grep -i "CRITICAL" | tail -5)
	if [ $($cErrBoot| wc -l) -ne 0 ]; then
		echo -e "$(rougefonce)Il y a des erreurs : "
		echo $cErrBoot
	else
		echo -e "${vertclair}Pas d'erreur ${neutre}lors du démarage du système depuis$(uptime | cut -dp -f2 | cut -d, -f1)" 
	fi
	echo -e "\n\n"

}

#Fonction affichant les ressources de stockage et l'arborescence de la machine
function ressources {
	echo -e "\n${vertclair}Ressources de stockage: ${neutre}\n"
	if dfc 2> /dev/null; then # dans le cas où l'utilisateur n'a pas installé dfc
		echo ""
    else
    	echo "$(df -h)"
    fi
	echo -e "\n${vertclair}Ressource de la mémoire :${neutre}\n"
	free -h 
	echo -e "\n\n${vertclair}Architecture du disque et des partitions:${neutre}\n"
	echo "$(lsblk)"
	echo -e "\n\n${vertclair}Top 5 des processus en cours:${neutre}\n"
	echo "$(top | head -n 2 | tail -n 1)"
	echo "$(top -n 1 | grep -A5 "PID")"
}

# Fonction affichant l'ensemble des informations à savoir sur le système
function all {
	# Interface de démarage
	tailleTerminal=$(tput cols)
	date=$(date -u)
	echo -e "${vertclair}"
	printf  "\n%*s\n\n" $(((${#tab}+$tailleTerminal)/2)) "$tab"
	printf  "%*s\n" $(((${#NOMLOGICIEL}+$tailleTerminal)/2)) "$NOMLOGICIEL"
	printf  "%*s\n\n" $(((${#VERSION}+$tailleTerminal)/2)) "$VERSION"
	printf  "%*s\n\n" $(((${#date}+$tailleTerminal)/2)) "$date"
	printf  "%*s\n\n\n\n\n" $(((${#tab}+$tailleTerminal)/2)) "$tab"
	echo -e "${neutre}"

	# Informations sur les utilisateurs
	title "USERS"
	user
	# Informations sur le système
	title "COMPUTER"
    computer
    # Informations sur les ressources
	title "RESSOURCES"
    ressources

}



# Gestion des arguments lors de l'appel du script
if [[ $1 == "" ]]; then	# Si il y a aucun paramètre on affiche tout les informations de la machine
	all
	exit;
else
	while getopts "acprsuh" options; do
  		case "${options}" in
    	a)	# Affiche toutes les informations
      		all
      		;;
     	c)	# Affiche les informations du pc
     		title "COMPUTER"
     		computer
     		;;
    	p) # Eteind la machine
		    poweroff
        	;;
        r) # Affiche les informations des ressources de la machine
     		title "RESSOURCES"
     		ressources
     		;;
     	
        s) # Mets en veille la machine
			systemctl suspend
			;;
    	u) # Affiche les informations des utilisateurs
     		title "UTILISATEURS"
     		user
     		;;
    	
    	h) # Affiche l'aide
      		help
      		;;
    	\?) # Argument invalide lors de l'appel du script
      		echo "Veuillez vous référer à l'aide -h"
      		exit 1
      		;;
  		esac
	done
fi
