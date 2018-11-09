# Projet ESIEA Système d'Exploitation
Projet réalisé par Nathan CHEVALIER & Killian LETISSIER lors de l'année 2018-2019
Ce projet consistait à créer deux scripts Shell. L'un devait être un script qui permettait d'avoir des informations utiles à propos du système (Script monitoring) comme les erreurs au démarrage, mais aussi de multiples caractérique de la machine. Le second consistait à synchroniser un conteneur veracrypt avec un disque crypté.

## Script monitoring
### Dépendances : 
1. curl : permets de faire des requêtes à un serveur supporté
1. dfc : commande améliorée de la commande df

### Options
1. -h : Affiche l'aide
1. -a : Affiche l'ensemble des informations de la machine
1. -c : Affiche les informations du PC
1. -p : Eteint la machine
1. -r : Affiche les ressources utilisées
1. -s : Mets en veille la machine
1. -u : Affiche les informations sur l'utilisateur ou les utisateurs


## Script synchronisation
### Dépendances : 
1. cryptsetup : outil permettant notamment d’ouvrir/fermer une partition crypté 
1. mount/umount : permets de monter/démonter un device
1. rsync : permets la synchronisation de deux dossiers

### Options
1. --help : Affiche l'utilisation correcte de la commande
1. --umountall : Permets de démonter les deux conteneurs

Pour utiliser les scripts de monitoring et de synchronisation, veuillez installer les dépendances sur votre machine.
