# Projet ESIEA Système d'Exploitation
Projet réalisé par Nathan CHEVALIER & Killian LETISSIER lors de l'année 2018-201
Ce projet consistait a créer deux scripts shell. L'un devait être un script qui permettait d'avoir des informations utiles à propos du système comme les erreurs au démarrage. Le second consistait à syncroniser un conteneur veracrypt avec un disque crypté.

## Script monitoring

## Script syncronisation
### Dépendances : 
1. cryptsetup : outil permettant notamment de ouvrir/fermer une partition crypté 
1. mount/umount : permet de monter/démonter un device
1. rsync : permet la syncronisation de deux dossiers

### Options
1. --help : Affiche l'utilisation correcte de la commande
1. --umountall : Permet de démonter les deux conteneurs
