# securisation-almalinux10
# Script de sécurisation AlmaLinux 10

Ce projet contient un script Bash destiné à automatiser et faciliter la mise en place d'une base de durcissement de sécurité sur les systèmes AlmaLinux 10.x.

Le script regroupe différentes mesures de sécurité visant notamment à renforcer l'authentification, le contrôle des accès, la journalisation, l'audit et la configuration générale du système. Il intervient notamment sur la politique des mots de passe, les mécanismes de verrouillage des comptes, les utilisateurs et groupes, les privilèges sudo, les règles d'audit, la configuration réseau et IPv6, SSH, le chargeur de démarrage GRUB, les options de montage définies dans `/etc/fstab`, les permissions de certains fichiers système, SELinux, certains services, certains modules du noyau ainsi que différents paramètres de sécurité du système.

L'objectif du projet est de fournir une base de durcissement cohérente et reproductible permettant de réduire certains risques liés à une configuration système insuffisamment sécurisée. Le script automatise ainsi un certain nombre de tâches qui peuvent être longues ou répétitives lorsqu'elles sont réalisées manuellement.

Le script doit être exécuté avec les privilèges administrateur :

    sudo ./Script_SecurisationAlmaLinux.sh

Il est fortement recommandé de lire le script et de comprendre les modifications qu'il effectue avant son exécution. Une sauvegarde complète du système doit également être réalisée avant toute utilisation, et le script devrait être testé sur une machine virtuelle ou un environnement de test avant d'être appliqué à un système de production.

---

## Avertissement

Ce script est fourni comme **outil d'aide à la sécurisation d'AlmaLinux**. Il constitue une **base de durcissement du système** et ne garantit en aucun cas une sécurisation complète, l'absence de vulnérabilités ou une protection contre toute forme d'attaque ou de compromission.

L'exécution du script peut modifier de manière importante le comportement du système, notamment :

- la politique des mots de passe ;
- les mécanismes de verrouillage des comptes ;
- les utilisateurs, groupes et droits sudo ;
- les règles d'audit ;
- la configuration réseau et IPv6 ;
- la configuration SSH ;
- le chargeur de démarrage GRUB ;
- les options de montage définies dans `/etc/fstab` ;
- les permissions de certains fichiers système ;
- SELinux ;
- certains services ;
- certains modules du noyau ;
- ainsi que d'autres paramètres de sécurité du système.

Certaines modifications peuvent entraîner une perte d'accès, empêcher un service de fonctionner correctement ou être incompatibles avec certains logiciels, matériels ou usages.

Une attention particulière doit être portée à la configuration SSH. Il est recommandé de conserver un accès administrateur de secours et de vérifier que l'accès au système fonctionne correctement avant de fermer la session utilisée pour exécuter le script.

---

## La sécurité ne s'arrête pas ici

La sécurité globale d'une machine dépend également de nombreux éléments qui ne sont pas entièrement contrôlés par ce script, notamment :

- le BIOS/UEFI et ses paramètres de sécurité ;
- le Secure Boot et le firmware lorsqu'ils sont disponibles ;
- le matériel et son état ;
- la sécurité physique de la machine ;
- le réseau et les équipements environnants ;
- les logiciels et services installés ultérieurement ;
- les mises à jour du système et des applications ;
- les sauvegardes ;
- la supervision et la journalisation ;
- la gestion des accès et des privilèges ;
- le comportement des utilisateurs et administrateurs.

Aucune configuration logicielle ne peut compenser entièrement une mauvaise configuration matérielle, un BIOS/UEFI non sécurisé, un système non maintenu à jour ou un comportement utilisateur dangereux.

---

## Responsabilité

L'utilisateur ou l'administrateur est responsable de vérifier que les modifications effectuées par ce script sont adaptées à son environnement.

Il est fortement recommandé de :

1. réaliser une sauvegarde avant l'exécution ;
2. tester le script sur une machine de test ou une machine virtuelle ;
3. vérifier les services critiques avant et après son exécution ;
4. conserver un accès administrateur de secours ;
5. vérifier la configuration du BIOS/UEFI et du firmware ;
6. maintenir le système et ses logiciels à jour.

---

## Modification du script

Ce fichier est fourni dans son état d'origine.

Toute modification, suppression, ajout, adaptation, copie partielle, intégration dans un autre script ou redistribution d'une version modifiée est effectuée sous la responsabilité de la personne ayant réalisé cette modification.

L'auteur du script original ne garantit pas le comportement, la sécurité ou les conséquences d'une version qui aurait été modifiée par un tiers.

Une version modifiée, forkée ou intégrée à un autre projet doit être considérée comme distincte de la version originale.

---

## Limitation de responsabilité

L'utilisation de ce script se fait sous la responsabilité de l'utilisateur ou de l'administrateur.

L'auteur ne garantit pas l'absence de :

- vulnérabilités ;
- erreurs de configuration ;
- perte ou corruption de données ;
- perte d'accès au système ;
- interruption de services ;
- incompatibilités matérielles ou logicielles ;
- incidents de sécurité ;
- ou autres conséquences résultant directement ou indirectement de l'utilisation du script.

Ce script ne remplace pas un audit de sécurité, une politique de sécurité complète, une analyse de risque ou l'intervention d'un professionnel qualifié.

---

## Version

**Version :** 1.1.0  
**Cible :** AlmaLinux 10.x  
**Auteur :** 0rz  
**Date initiale :** 2026-06-30  
**Dernière révision :** 2026-09-24

---

## Ressources

Le développement du script s'appuie notamment sur :

- les procédures de sécurité applicables à AlmaLinux ;
- la documentation officielle d'AlmaLinux et des composants utilisés ;
- les documentations officielles Linux ;
- les bonnes pratiques d'administration système et de durcissement de sécurité.

Claude.ai a également été utilisé comme outil d'assistance pour la structure du code, l'organisation du script et certains éléments de présentation et d'esthétique.

---

# AlmaLinux 10 Security Hardening Script

This project contains a Bash script designed to automate and facilitate the implementation of a security hardening baseline on AlmaLinux 10.x systems.

The script brings together various security measures intended to strengthen authentication, access control, logging, auditing, and the overall system configuration. It addresses areas including password policies, account lockout mechanisms, users and groups, sudo privileges, audit rules, network and IPv6 configuration, SSH, the GRUB bootloader, mount options defined in `/etc/fstab`, permissions on selected system files, SELinux, selected services, selected kernel modules, and other system security settings.

The purpose of the project is to provide a consistent and reproducible hardening baseline that can help reduce certain risks associated with insufficiently secured system configurations. The script automates a number of tasks that can otherwise be time-consuming or repetitive when performed manually.

The script should be executed with administrative privileges:

    sudo ./Script_SecurisationAlmaLinux.sh

It is strongly recommended to read the script and understand the changes it performs before executing it. A complete system backup should also be created before use, and the script should be tested on a virtual machine or dedicated test environment before being deployed on a production system.

---

## Warning

This script is provided as a **security hardening tool for AlmaLinux**. It constitutes a **system hardening baseline** and does not guarantee complete security, the absence of vulnerabilities, or protection against every form of attack or compromise.

Running the script may significantly modify system behavior, including:

- password policies;
- account lockout mechanisms;
- users, groups, and sudo privileges;
- audit rules;
- network and IPv6 configuration;
- SSH configuration;
- the GRUB bootloader;
- mount options defined in `/etc/fstab`;
- permissions on selected system files;
- SELinux;
- selected services;
- selected kernel modules;
- and other system security settings.

Some changes may result in loss of access, prevent a service from functioning correctly, or be incompatible with specific software, hardware, or use cases.

Particular attention should be paid to SSH configuration. Maintaining emergency administrative access and verifying that system access remains functional before closing the session used to execute the script is strongly recommended.

---

## Security Does Not Stop Here

Overall system security also depends on many elements that are not fully controlled by this script, including:

- BIOS/UEFI and its security settings;
- Secure Boot and firmware when available;
- hardware and its condition;
- physical security;
- the network and surrounding infrastructure;
- software and services installed later;
- system and application updates;
- backups;
- monitoring and logging;
- access and privilege management;
- user and administrator behavior.

No software configuration can fully compensate for insecure hardware configuration, an improperly secured BIOS/UEFI, an unmaintained system, or unsafe user behavior.

---

## Responsibility

The user or system administrator is responsible for verifying that the changes made by this script are appropriate for their environment.

It is strongly recommended to:

1. create a backup before execution;
2. test the script on a test system or virtual machine;
3. verify critical services before and after execution;
4. maintain emergency administrative access;
5. verify BIOS/UEFI and firmware security settings;
6. keep the system and its software up to date.

---

## Script Modification

This file is provided in its original form.

Any modification, removal, addition, adaptation, partial copying, integration into another script, or redistribution of a modified version is performed under the responsibility of the person making the modification.

The original author does not guarantee the behavior, security, or consequences of a version modified by a third party.

A modified, forked, or integrated version should be considered distinct from the original version.

---

## Disclaimer

Use of this script is performed under the responsibility of the user or system administrator.

The author does not guarantee the absence of:

- vulnerabilities;
- configuration errors;
- data loss or corruption;
- loss of system access;
- service interruptions;
- hardware or software incompatibilities;
- security incidents;
- or other consequences resulting directly or indirectly from the use of this script.

This script does not replace a security audit, a complete security policy, a risk assessment, or the involvement of a qualified security professional.

---

## Version

**Version:** 1.1.0  
**Target:** AlmaLinux 10.x  
**Author:** 0rz  
**Initial date:** 2026-06-30  
**Last revision:** 2026-09-24

---

## Resources

The development of this script is based in particular on:

- AlmaLinux security procedures;
- official AlmaLinux and component documentation;
- official Linux documentation;
- system administration and security hardening best practices.

Claude.ai was also used as an assistance tool for code structure, script organization, and selected presentation and aesthetic elements.
