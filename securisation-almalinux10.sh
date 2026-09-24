#!/bin/bash
# =================================================================================================================================================
# Auteur      : 0rz
# Date        : 2026-06-30
# Revision    : 2026-09-24 (v1.1.0)
# Description : Script de durcissement de la sécurité AlmaLinux 10
#               Lancer avec : sudo ./Script_SecurisationAlmaLinux.sh
# Ressources Utilisées : Procédure de sécurité AlmaLinux et documentations officielles & utilisation de Claude.ai pour la structure du code et l'esthétique
# =================================================================================================================================================


# =============================================================================
#                              AVERTISSEMENT
# =============================================================================
#
#                    SCRIPT DE SÉCURISATION ALMALINUX
#
# Ce script est fourni comme OUTIL D'AIDE À LA SÉCURISATION d'AlmaLinux.
# Il constitue une BASE de durcissement du système et NE GARANTIT EN AUCUN
# CAS une sécurisation complète, une absence de vulnérabilité ou une
# protection contre toute forme d'attaque ou de compromission.
#
# =============================================================================
#                              IMPORTANT
# =============================================================================
#
# L'exécution de ce script peut modifier de manière importante le comportement
# du système, notamment :
#
#   - la politique des mots de passe ;
#   - les mécanismes de verrouillage des comptes ;
#   - les utilisateurs, groupes et droits sudo ;
#   - les règles d'audit ;
#   - la configuration réseau et IPv6 ;
#   - les paramètres SSH ;
#   - le chargeur de démarrage GRUB ;
#   - les options de montage définies dans /etc/fstab ;
#   - les permissions de certains fichiers système ;
#   - SELinux ;
#   - certains services ;
#   - certains modules du noyau ;
#   - ainsi que d'autres paramètres de sécurité du système.
#
# Certaines modifications peuvent entraîner une perte d'accès, empêcher un
# service de fonctionner correctement ou être incompatibles avec certains
# logiciels, matériels ou usages.
#
# =============================================================================
#                         LA SÉCURITÉ NE S'ARRÊTE PAS ICI
# =============================================================================
#
# La sécurité globale d'une machine dépend également de nombreux éléments qui
# ne sont PAS entièrement contrôlés par ce script, notamment :
#
#   - le BIOS/UEFI et ses paramètres de sécurité ;
#   - le Secure Boot et le firmware lorsqu'ils sont disponibles ;
#   - le matériel et son état ;
#   - la sécurité physique de la machine ;
#   - le réseau et les équipements environnants ;
#   - les logiciels et services installés ultérieurement ;
#   - les mises à jour du système et des applications ;
#   - les sauvegardes ;
#   - la supervision et la journalisation ;
#   - la gestion des accès et des privilèges ;
#   - ainsi que le comportement des utilisateurs et administrateurs.
#
# Aucune configuration logicielle ne peut compenser entièrement une mauvaise
# configuration matérielle, un BIOS/UEFI non sécurisé, un système non maintenu
# à jour ou un comportement utilisateur dangereux.
#
# =============================================================================
#                            RESPONSABILITÉ
# =============================================================================
#
# L'utilisateur ou l'administrateur est responsable de vérifier que les
# modifications effectuées par ce script sont adaptées à son environnement.
#
# Il est fortement recommandé de :
#
#   1. réaliser une sauvegarde avant l'exécution ;
#   2. tester le script sur une machine de test ou une machine virtuelle ;
#   3. vérifier les services critiques avant et après son exécution ;
#   4. conserver un accès administrateur de secours ;
#   5. vérifier la configuration du BIOS/UEFI et du firmware ;
#   6. maintenir le système et ses logiciels à jour.
#
# =============================================================================
#                         MODIFICATION DU SCRIPT
# =============================================================================
#
# Ce fichier est fourni dans son état d'origine.
#
# Toute modification, suppression, ajout, adaptation, copie partielle,
# intégration dans un autre script ou redistribution d'une version modifiée
# est effectuée sous la responsabilité de la personne ayant réalisé cette
# modification.
#
# L'auteur du script original ne garantit pas le comportement, la sécurité
# ou les conséquences d'une version qui aurait été modifiée par un tiers.
#
# Une version modifiée, forkée ou intégrée à un autre projet doit être
# considérée comme distincte de la version originale.
#
# =============================================================================
#                       LIMITATION DE RESPONSABILITÉ
# =============================================================================
#
# L'utilisation de ce script se fait sous la responsabilité de l'utilisateur
# ou de l'administrateur.
#
# L'auteur ne garantit pas l'absence de :
#
#   - vulnérabilités ;
#   - erreurs de configuration ;
#   - perte ou corruption de données ;
#   - perte d'accès au système ;
#   - interruption de services ;
#   - incompatibilités matérielles ou logicielles ;
#   - incidents de sécurité ;
#   - ou autres conséquences résultant directement ou indirectement de
#     l'utilisation du script.
#
# Ce script ne remplace pas un audit de sécurité, une politique de sécurité
# complète, une analyse de risque ou l'intervention d'un professionnel qualifié.
#
# =============================================================================
#                              VERSION
# =============================================================================
#
# Version : 1.1.0
# Cible   : AlmaLinux 10.x
#
# =============================================================================


# -----------------------------------------------------------------------------
# AIDE
# -----------------------------------------------------------------------------
case "${1:-}" in
    aide|help|-h|--help)
        echo "================================================================="
        echo " Script de securisation AlmaLinux 10"
        echo "================================================================="
        echo " Usage : sudo $0"
        echo ""
        echo " Ce script automatise :"
        echo "   1.  Politique de mots de passe"
        echo "   2.  Verrouillage de compte (faillock)"
        echo "   3.  Creation des comptes nominatifs et du groupe admin"
        echo "   4.  Regles d audit (auditd)"
        echo "   5.  Desactivation IPv6"
        echo "   6.  Banniere + Timeout de session + Protection GRUB"
        echo "   7.  Securisation et mise a jour SSH"
        echo "   8.  Options de montage des partitions (fstab)"
        echo "   9.  Durcissement complementaire (facultatif)"
        echo "   10. Modules noyau dangereux (facultatif)"
        echo "================================================================="
        exit 0
        ;;
esac

# -----------------------------------------------------------------------------
# VÉRIFICATION DE LA VERSION DU SYSTÈME (AlmaLinux 10.x)
# -----------------------------------------------------------------------------
if [ ! -f /etc/os-release ]; then
    echo "[ERREUR] /etc/os-release introuvable. Impossible de verifier la version."
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

if [ "${ID:-}" != "almalinux" ]; then
    echo "================================================================="
    echo "  ERREUR : Mauvais systeme d'exploitation"
    echo "================================================================="
    echo "  Ce script est prevu UNIQUEMENT pour AlmaLinux 10."
    echo "  Systeme detecte : ${PRETTY_NAME:-inconnu}"
    echo "  Abandon."
    echo "================================================================="
    exit 1
fi

if [ "${VERSION_ID%%.*}" != "10" ]; then
    echo "================================================================="
    echo "  ERREUR : Mauvaise version d'AlmaLinux"
    echo "================================================================="
    echo "  Ce script est prevu UNIQUEMENT pour AlmaLinux 10.x."
    echo "  Version detectee : ${VERSION_ID:-inconnue}  (${PRETTY_NAME:-inconnu})"
    echo "  Abandon."
    echo "================================================================="
    exit 1
fi

# -----------------------------------------------------------------------------
# VÉRIFICATION DES DROITS ROOT
# -----------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit etre lance avec sudo."
    echo "         Usage : sudo $0"
    exit 1
fi

# -----------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
# -----------------------------------------------------------------------------

SECTION_COURANTE=0
RELABEL_DEMANDE=0
declare -A NB_OK
declare -A NB_ERREUR

titre() {
    local texte="$1"
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local ligne=""
    local i=0
    while [ $i -lt "$cols" ]; do
        ligne="${ligne}="
        i=$(( i + 1 ))
    done
    local longueur=${#texte}
    local padding=$(( (cols - longueur) / 2 ))
    [ "$padding" -lt 0 ] && padding=0
    local espaces=""
    local j=0
    while [ $j -lt "$padding" ]; do
        espaces="${espaces} "
        j=$(( j + 1 ))
    done
    # Memorise le numero de section ("3/10 - ..." -> 3) pour le rapport final
    if [[ "$texte" =~ ^([0-9]+)/ ]]; then
        SECTION_COURANTE="${BASH_REMATCH[1]}"
    fi
    echo ""
    echo "$ligne"
    echo "${espaces}${texte}"
    echo "$ligne"
}

# ok / erreur alimentent le rapport final ; info / avertir / saisie_invalide non.
ok() {
    echo "  [OK]     $1"
    NB_OK[$SECTION_COURANTE]=$(( ${NB_OK[$SECTION_COURANTE]:-0} + 1 ))
}
info()    { echo "  [INFO]   $1"; }
avertir() { echo "  [ATTENTION] $1"; }
erreur() {
    echo "  [ERREUR] $1"
    NB_ERREUR[$SECTION_COURANTE]=$(( ${NB_ERREUR[$SECTION_COURANTE]:-0} + 1 ))
}
# Erreur de saisie utilisateur (l'utilisateur recommence) : n'impacte pas le rapport
saisie_invalide() { echo "  [ERREUR] $1"; }

statut_section() {
    local n="$1"
    local o="${NB_OK[$n]:-0}"
    local e="${NB_ERREUR[$n]:-0}"
    if [ "$e" -gt 0 ] && [ "$o" -gt 0 ]; then
        echo "PARTIEL"
    elif [ "$e" -gt 0 ]; then
        echo "ERREUR"
    elif [ "$o" -gt 0 ]; then
        echo "OK"
    else
        echo "IGNORE"
    fi
}

afficher_progression() {
    # Pas de barre si la sortie n'est pas un terminal
    [ -t 1 ] || return 0
    local etape=$1
    local total=$2
    local largeur=40
    local pct=$(( etape * 100 / total ))
    local rempli=$(( etape * largeur / total ))
    local barre=""
    local i=0
    while [ $i -lt $rempli ]; do barre="${barre}█"; i=$(( i + 1 )); done
    while [ $i -lt $largeur ]; do barre="${barre}░"; i=$(( i + 1 )); done
    local cols rows
    cols=$(tput cols  2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)
    local suffix="]  ${pct}%  (${etape}/${total})"
    local longueur_totale=$(( 1 + largeur + ${#suffix} ))
    local padding=$(( (cols - longueur_totale) / 2 ))
    [ "$padding" -lt 0 ] && padding=0
    local espaces=""
    local j=0
    while [ $j -lt "$padding" ]; do espaces="${espaces} "; j=$(( j + 1 )); done
    tput sc 2>/dev/null
    tput cup $(( rows - 2 )) 0 2>/dev/null
    printf '\033[2K'
    printf '%s[%s%s' "$espaces" "$barre" "$suffix"
    tput rc 2>/dev/null
}

# Normalise un prenom/nom en ASCII minuscule pour former un login.
# LC_ALL=C.UTF-8 : sed manipule des caracteres (et non des octets) meme si la
# session tourne en locale C. Les majuscules accentuees sont traitees
# directement dans le sed (tr GNU ne sait pas les convertir).
normaliser() {
    printf '%s\n' "$1" \
        | LC_ALL=C.UTF-8 sed -E '
            s/[àáâãäåÀÁÂÃÄÅ]/a/g; s/[èéêëÈÉÊË]/e/g; s/[ìíîïÌÍÎÏ]/i/g;
            s/[òóôõöÒÓÔÕÖ]/o/g;   s/[ùúûüÙÚÛÜ]/u/g;   s/[ýÿÝ]/y/g;
            s/[çÇ]/c/g;           s/[ñÑ]/n/g;         s/[œŒ]/oe/g;
            s/[æÆ]/ae/g;          s/ß/ss/g;           s/[ğĞ]/g/g;
            s/[şŞšŠśŚ]/s/g;       s/[ıİ]/i/g;         s/[łŁ]/l/g;
            s/[øØ]/o/g;           s/[žŽźŹżŻ]/z/g;     s/[čČćĆ]/c/g;
            s/[řŘ]/r/g;           s/[ěĚęĘ]/e/g;       s/[ąĄ]/a/g;
            s/[ńŃ]/n/g' \
        | LC_ALL=C tr 'A-Z' 'a-z' \
        | LC_ALL=C tr -cd 'a-z0-9-'
}

TOTAL_ETAPES=22
ETAPE_COURANTE=0
avancer() {
    ETAPE_COURANTE=$(( ETAPE_COURANTE + 1 ))
    afficher_progression "$ETAPE_COURANTE" "$TOTAL_ETAPES"
}

centrer() {
    local texte="$1"
    local cols_c
    cols_c=$(tput cols 2>/dev/null || echo 80)
    local lon=${#texte}
    local pad=$(( (cols_c - lon) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    local sp=""
    local k=0
    while [ $k -lt "$pad" ]; do sp="${sp} "; k=$(( k + 1 )); done
    echo "${sp}${texte}"
}

rapport() {
    local texte="$1"
    local statut="$2"
    local cols_r
    cols_r=$(tput cols 2>/dev/null || echo 80)
    local prefixe="  [+] "
    local suffixe="  ${statut}  "
    local lon_disponible=$(( cols_r - ${#prefixe} - ${#texte} - ${#suffixe} ))
    local points=""
    local p=0
    while [ $p -lt "$lon_disponible" ]; do points="${points}."; p=$(( p + 1 )); done
    echo "${prefixe}${texte}${points}${suffixe}"
}

# Sauvegarde horodatee (ne jamais ecraser une sauvegarde precedente).
# Le chemin de la sauvegarde est place dans la variable BACKUP_PATH.
sauvegarder() {
    BACKUP_PATH="${1}.bak.$(date +%Y%m%d-%H%M%S)"
    cp -p "$1" "$BACKUP_PATH"
}

# /etc/login.defs : remplace la directive ACTIVE, sinon l'ajoute en fin de fichier.
# (Les lignes commentees sont ignorees : login.defs contient des commentaires
#  qui citent PASS_MAX_DAYS & co en debut de ligne.)
definir_login_defs() {
    local cle="$1"
    local valeur="$2"
    local f="/etc/login.defs"
    if grep -qE "^[[:space:]]*${cle}[[:space:]]" "$f"; then
        sed -i -E "s|^[[:space:]]*${cle}[[:space:]].*|${cle}   ${valeur}|" "$f"
    else
        printf '%s   %s\n' "$cle" "$valeur" >> "$f"
    fi
}

# Fichiers au format "cle = valeur" (pwquality, pwhistory, faillock) :
# remplace la ligne (commentee ou non), sinon l'ajoute en fin de fichier.
definir_cle_conf() {
    local f="$1"
    local cle="$2"
    local valeur="$3"
    if grep -qE "^#?[[:space:]]*${cle}[[:space:]]*=" "$f"; then
        sed -i -E "s|^#?[[:space:]]*${cle}[[:space:]]*=.*|${cle} = ${valeur}|" "$f"
    else
        printf '%s = %s\n' "$cle" "$valeur" >> "$f"
    fi
}

# Les fichiers faillock.conf / pwhistory.conf ne sont lus que si la feature
# correspondante est active dans le profil authselect.
activer_feature_authselect() {
    local feat="$1"
    local courant profil
    if ! command -v authselect > /dev/null 2>&1; then
        avertir "authselect absent : verifiez manuellement que ${feat} est actif dans la pile PAM."
        return 0
    fi
    if ! courant=$(authselect current 2>/dev/null); then
        avertir "Aucun profil authselect detecte : verifiez manuellement que ${feat} est actif dans PAM."
        return 0
    fi
    if echo "$courant" | grep -qE "^-[[:space:]]+${feat}[[:space:]]*$"; then
        info "authselect : ${feat} deja actif"
        return 0
    fi
    profil=$(echo "$courant" | awk '/^Profile ID:/ {print $3; exit}')
    if authselect list-features "$profil" 2>/dev/null | grep -qx "$feat"; then
        if authselect enable-feature "$feat" > /dev/null 2>&1; then
            ok "authselect : feature ${feat} activee (profil ${profil})"
        else
            erreur "authselect enable-feature ${feat} a echoue. Activez-la manuellement."
        fi
    else
        avertir "Feature ${feat} absente du profil '${profil}' : configurez PAM manuellement."
    fi
}

# --- Audit : regle "watch" sur le chemin REEL d'un binaire --------------------
# Un watch pose sur un lien symbolique (ex: /usr/sbin/reboot -> systemctl,
# /usr/bin/dnf -> dnf-3) ne se declenche pas : on resout le chemin reel.
regle_watch_binaire() {
    local chemin="$1"
    local cle="$2"
    local reel
    reel=$(readlink -f "$chemin" 2>/dev/null)
    if [ -n "$reel" ] && [ -e "$reel" ]; then
        echo "-w ${reel} -p x -k ${cle}"
    else
        info "Binaire introuvable, regle d'audit ignoree : $chemin" >&2
    fi
}

# --- SSH ----------------------------------------------------------------------
# Ajoute (ou remplace) une directive dans le drop-in 00-securisation.conf.
# 00- est lu en premier et, pour sshd, la PREMIERE valeur rencontree gagne.
appliquer_ssh() {
    local cle="$1"
    local valeur="$2"
    sed -i -E "/^${cle}[[:space:]]/Id" "$SSH_DROPIN"
    echo "${cle} ${valeur}" >> "$SSH_DROPIN"
}

# Compare une valeur EFFECTIVE (sshd -T, deja stocke dans $SSHD_T) a la valeur voulue.
verifier_ssh() {
    local cle="$1"
    local attendu="$2"
    local reel
    reel=$(printf '%s\n' "$SSHD_T" | awk -v k="$cle" '$1 == k {print $2; exit}')
    if [ "$reel" = "$attendu" ]; then
        ok "sshd applique : ${cle} = ${reel}"
    else
        erreur "sshd applique ${cle} = ${reel:-?} (attendu : ${attendu}) : une autre directive prend le dessus (voir /etc/ssh/sshd_config.d/)."
    fi
}

# Demande une liste de logins/groupes, valide chaque element, l'ecrit dans le
# drop-in. Resultat (liste validee) dans LISTE_RESULTAT.
demander_liste_ssh() {
    local directive="$1"
    local libelle="$2"
    local type="$3"          # user | group
    local saisie motif item
    local -a items=()
    LISTE_RESULTAT=""
    echo ""
    info "${libelle}. Laissez vide pour ignorer."
    read -rp "  ${directive} : " saisie
    if [ "$type" = "user" ]; then
        motif='^[a-z][a-z0-9._-]{0,31}$'
    else
        motif='^[a-z][a-z0-9_-]{0,31}$'
    fi
    # read -a : pas d'expansion de jokers (contrairement a "for x in $saisie")
    read -ra items <<< "$saisie"
    for item in "${items[@]}"; do
        if printf '%s\n' "$item" | grep -qE "$motif"; then
            LISTE_RESULTAT="${LISTE_RESULTAT:+$LISTE_RESULTAT }${item}"
        else
            saisie_invalide "Valeur ignoree (format invalide) : $item"
        fi
    done
    if [ -n "$LISTE_RESULTAT" ]; then
        appliquer_ssh "$directive" "$LISTE_RESULTAT"
        ok "${directive} : ${LISTE_RESULTAT}"
    else
        info "${directive} ignore."
    fi
}

# Previent si la session en cours risque de ne plus pouvoir se reconnecter.
avertir_acces_ssh() {
    local courant="${SUDO_USER:-root}"
    local g trouve=0
    if [ "$courant" = "root" ]; then
        avertir "Vous etes root : PermitRootLogin no interdit la connexion SSH directe de root. Utilisez un compte admin."
    fi
    if [ -n "$SSH_ALLOW_USERS" ] && [[ " $SSH_ALLOW_USERS " != *" $courant "* ]]; then
        avertir "'$courant' n'est pas dans AllowUsers : il ne pourra plus se connecter en SSH."
    fi
    if [ -n "$SSH_ALLOW_GROUPS" ]; then
        for g in $(id -nG "$courant" 2>/dev/null); do
            if [[ " $SSH_ALLOW_GROUPS " == *" $g "* ]]; then trouve=1; fi
        done
        if [ "$trouve" -eq 0 ]; then
            avertir "'$courant' n'appartient a aucun groupe de AllowGroups : connexion SSH impossible."
        fi
    fi
    if [ -n "$SSH_DENY_USERS" ] && [[ " $SSH_DENY_USERS " == *" $courant "* ]]; then
        avertir "'$courant' est dans DenyUsers : connexion SSH impossible."
    fi
    if [ -n "$SSH_DENY_GROUPS" ]; then
        for g in $(id -nG "$courant" 2>/dev/null); do
            if [[ " $SSH_DENY_GROUPS " == *" $g "* ]]; then
                avertir "'$courant' appartient au groupe '$g' (DenyGroups) : connexion SSH impossible."
            fi
        done
    fi
}

# --- fstab --------------------------------------------------------------------
# Numero de ligne ACTIVE (non commentee) dont le 2e champ est exactement $1.
ligne_fstab() {
    awk -v p="$1" '$1 !~ /^#/ && NF >= 4 && $2 == p {print NR; exit}' "$FSTAB"
}

# Ajoute une option au 4e champ (options) de la ligne du point de montage.
ajouter_option_montage() {
    local point="$1"
    local option="$2"
    local lineno opts tmp
    lineno=$(ligne_fstab "$point")
    [ -z "$lineno" ] && return 1
    opts=$(awk -v n="$lineno" 'NR == n {print $4}' "$FSTAB")
    if printf ',%s,\n' "$opts" | grep -qF ",${option},"; then
        info "'${option}' deja present pour ${point}"
        return 0
    fi
    tmp=$(mktemp)
    awk -v n="$lineno" -v o="$option" 'NR == n {$4 = $4 "," o} {print}' "$FSTAB" > "$tmp" \
        && cat "$tmp" > "$FSTAB"
    rm -f "$tmp"
    ok "'${option}' ajoute pour ${point}"
}

durcir_montage() {
    local point="$1"
    shift
    local opt
    if [ -z "$(ligne_fstab "$point")" ]; then
        info "${point} : pas de partition dediee dans le fstab, ignore."
        return 0
    fi
    for opt in "$@"; do
        ajouter_option_montage "$point" "$opt"
    done
}

# --- umask --------------------------------------------------------------------
ajouter_umask() {
    local f="$1"
    if [ ! -f "$f" ]; then
        info "$f absent, ignore."
        return 0
    fi
    if grep -qE '^[[:space:]]*umask[[:space:]]+027[[:space:]]*$' "$f"; then
        info "umask 027 deja present dans $f"
    else
        {
            echo ""
            echo "# Restriction permissions par defaut (securisation)"
            echo "umask 027"
        } >> "$f"
        ok "umask 027 ajoute dans $f"
    fi
}


# -----------------------------------------------------------------------------
# BANNIÈRE DE DÉMARRAGE
# Si le terminal est trop petit (< 170 col), l'ASCII art ne s'affiche pas :
# un message indique qu'il sera visible au prochain lancement dans un
# terminal suffisamment grand. L'art lui-meme n'est pas modifie (169 col).
# -----------------------------------------------------------------------------
LARGEUR_TERMINAL=$(tput cols 2>/dev/null || echo 80)
clear 2>/dev/null

if [ "$LARGEUR_TERMINAL" -ge 170 ]; then

cat << 'BANNER'
 ____                                                        __                            ______   ___                            __                                    
/\  _`\                                 __                  /\ \__  __                    /\  _  \ /\_ \                          /\ \       __                          
\ \,\L\_\     __    ___   __  __  _ __ /\_\    ____     __  \ \ ,_\/\_\    ___     ___    \ \ \L\ \\//\ \     ___ ___      __     \ \ \     /\_\    ___   __  __  __  _  
 \/_\__ \   /'__`\ /'___\/\ \/\ \/\`'__\/\ \  /',__\  /'__`\ \ \ \/\/\ \  / __`\ /' _ `\   \ \  __ \ \ \ \  /' __` __`\  /'__`\    \ \ \  __\/\ \ /' _ `\/\ \/\ \/\ \/'\ 
   /\ \L\ \/\  __//\ \__/\ \ \_\ \ \ \/ \ \ \/\__, `\/\ \L\.\_\ \ \_\ \ \/\ \L\ \/\ \/\ \   \ \ \/\ \ \_\ \_/\ \/\ \/\ \/\ \L\.\_   \ \ \L\ \\ \ \/\ \/\ \ \ \_\ \/>  </ 
   \ `\____\ \____\ \____\\ \____/\ \_\  \ \_\/\____/\ \__/.\_\\ \__\\ \_\ \____/\ \_\ \_\   \ \_\ \_\/\____\ \_\ \_\ \_\ \__/.\_\   \ \____/ \ \_\ \_\ \_\ \____//\_/\_\
    \/_____/\/____/\/____/ \/___/  \/_/   \/_/\/___/  \/__/\/_/ \/__/ \/_/\/___/  \/_/\/_/    \/_/\/_/\/____/\/_/\/_/\/_/\/__/\/_/    \/___/   \/_/\/_/\/_/\/___/ \//\/_/
BANNER

    echo ""
    centrer "Bienvenue sur le script de securisation AlmaLinux 10"
    centrer "Made by 0rz"

else
    # Terminal trop etroit : l'ASCII art sera visible au prochain lancement
    # dans un terminal d'au moins 170 colonnes.
    echo ""
    echo ""
    # Marge calculee UNE fois pour tout l'encadre (sinon l'alignement depend de la
    # locale : ${#texte} compte des octets en locale C et des caracteres en UTF-8).
    BOX_PAD=$(( (LARGEUR_TERMINAL - 78) / 2 ))
    [ "$BOX_PAD" -lt 0 ] && BOX_PAD=0
    boite() { printf '%*s%s\n' "$BOX_PAD" "" "$1"; }
    boite "┌────────────────────────────────────────────────────────────────────────────┐"
    boite "│                                                                            │"
    boite "│             Le titre ASCII sera affiche au prochain demarrage.             │"
    boite "│                                                                            │"
    boite "│                      Votre terminal est trop petit !                       │"
    boite "│               Agrandissez-le à 170+ colonnes pour le voir :)               │"
    boite "│                                                                            │"
    boite "│                   AlmaLinux 10 - Script de securisation                    │"
    boite "│                                                                            │"
    boite "│                                Made by 0rz                                 │"
    boite "│                                                                            │"
    boite "└────────────────────────────────────────────────────────────────────────────┘"
    echo ""
fi

echo ""
centrer "Bienvenue. Appuyez sur ENTREE pour demarrer..."
read -r

# =============================================================================
# 1. POLITIQUE DE MOTS DE PASSE
# =============================================================================
titre "1/10 - Politique de mots de passe"

info "Configuration de /etc/login.defs ..."
if [ ! -f /etc/login.defs ]; then
    erreur "/etc/login.defs introuvable. Etape ignoree."
else
    # PASS_MIN_LEN n'existe plus dans login.defs (RHEL) : la longueur minimale
    # est geree par pam_pwquality (minlen, ci-dessous).
    definir_login_defs PASS_MAX_DAYS 90
    definir_login_defs PASS_MIN_DAYS 7
    definir_login_defs PASS_WARN_AGE 14
    ok "/etc/login.defs : MAX_DAYS=90, MIN_DAYS=7, WARN_AGE=14 (longueur minimale geree par pwquality)"
fi
avancer


info "Configuration de /etc/security/pwquality.conf ..."
if [ ! -f /etc/security/pwquality.conf ]; then
    erreur "/etc/security/pwquality.conf introuvable. Etape ignoree."
else
    definir_cle_conf /etc/security/pwquality.conf enforcing 1
    definir_cle_conf /etc/security/pwquality.conf minlen    14
    definir_cle_conf /etc/security/pwquality.conf minclass  3
    definir_cle_conf /etc/security/pwquality.conf usercheck 1
    ok "/etc/security/pwquality.conf : enforcing=1, minlen=14, minclass=3, usercheck=1"
fi
avancer

info "Configuration de /etc/security/pwhistory.conf ..."
if [ ! -f /etc/security/pwhistory.conf ]; then
    erreur "/etc/security/pwhistory.conf introuvable. Etape ignoree."
else
    definir_cle_conf /etc/security/pwhistory.conf remember 24
    ok "/etc/security/pwhistory.conf : remember=24"
    # Sans la feature authselect, pam_pwhistory n'est pas dans la pile PAM
    activer_feature_authselect with-pwhistory
fi
avancer

# =============================================================================
# 2. VERROUILLAGE DE COMPTE (faillock)
# =============================================================================
titre "2/10 - Verrouillage de compte (faillock)"

if [ ! -f /etc/security/faillock.conf ]; then
    erreur "/etc/security/faillock.conf introuvable. Etape ignoree."
else
    definir_cle_conf /etc/security/faillock.conf deny        6
    definir_cle_conf /etc/security/faillock.conf unlock_time 1800
    ok "/etc/security/faillock.conf : deny=6, unlock_time=1800s (30 min)"
    # Sans la feature authselect, pam_faillock n'est pas dans la pile PAM
    activer_feature_authselect with-faillock
fi
avancer

# =============================================================================
# 3. CRÉATION DU GROUPE ADMIN ET DES COMPTES NOMINATIFS
# =============================================================================
titre "3/10 - Creation du groupe admin et des comptes utilisateurs"

if ! getent group admin > /dev/null 2>&1; then
    groupadd admin
    ok "Groupe 'admin' cree"
else
    info "Le groupe 'admin' existe deja"
fi

# On ecrit dans /etc/sudoers.d/admin (jamais dans /etc/sudoers directement),
# apres validation par visudo.
# Verification : sudo cat /etc/sudoers.d/admin
SUDOERS_ADMIN="/etc/sudoers.d/admin"
if [ -f "$SUDOERS_ADMIN" ] || grep -q "^%admin" /etc/sudoers 2>/dev/null; then
    info "Le groupe 'admin' est deja configure dans sudoers"
else
    tmp_sudoers=$(mktemp)
    echo "%admin ALL=(ALL:ALL) ALL" > "$tmp_sudoers"
    if visudo -cf "$tmp_sudoers" > /dev/null 2>&1 \
        && install -o root -g root -m 440 "$tmp_sudoers" "$SUDOERS_ADMIN"; then
        ok "Groupe 'admin' configure dans $SUDOERS_ADMIN"
    else
        erreur "Impossible d'ecrire une regle sudoers valide pour le groupe 'admin'."
    fi
    rm -f "$tmp_sudoers"
fi
avancer

echo ""
info "Creation des comptes nominatifs des administrateurs."
info "Format du login : premiere_lettre_prenom.nom  (ex: Jean Dupont -> j.dupont)"
echo ""

continuer="o"
while [ "$continuer" = "o" ] || [ "$continuer" = "oui" ]; do

    while true; do
        read -rp "  Prenom de l'administrateur : " prenom_brut
        if [ -z "$prenom_brut" ]; then
            saisie_invalide "Le prenom ne peut pas etre vide."
        elif printf '%s\n' "$prenom_brut" | LC_ALL=C.UTF-8 grep -qP '^[\p{L}-]+$'; then
            break
        else
            saisie_invalide "Le prenom ne doit contenir que des lettres (tiret autorise)."
        fi
    done

    while true; do
        read -rp "  Nom de l'administrateur   : " nom_brut
        if [ -z "$nom_brut" ]; then
            saisie_invalide "Le nom ne peut pas etre vide."
        elif printf '%s\n' "$nom_brut" | LC_ALL=C.UTF-8 grep -qP '^[\p{L}-]+$'; then
            break
        else
            saisie_invalide "Le nom ne doit contenir que des lettres (tiret autorise)."
        fi
    done

    prenom_norm=$(normaliser "$prenom_brut")
    nom_norm=$(normaliser "$nom_brut")
    premiere_lettre="${prenom_norm:0:1}"

    if [[ ! "$premiere_lettre" =~ ^[a-z]$ ]] || [ -z "$nom_norm" ]; then
        saisie_invalide "Impossible de former un login valide avec ce prenom/nom. Recommencez."
        continue
    fi

    login="${premiere_lettre}.${nom_norm}"

    if [ "${#login}" -gt 32 ]; then
        saisie_invalide "Login trop long (${#login} car., 32 maximum) : '$login'. Recommencez."
        continue
    fi

    echo ""
    info "Login qui sera cree : $login"
    echo ""

    if id "$login" > /dev/null 2>&1; then
        avertir "L'utilisateur '$login' existe deja, il sera ignore."
    else
        info "Definissez le mot de passe pour '$login' :"
        info "  - 14 caracteres minimum"
        info "  - Au moins 3 types : MAJuscule, minuscule, chiffre, symbole"
        info "  - Ne doit contenir ni le login ni le nom de famille"
        echo ""

        mdp_valide=""
        while true; do
            read -rsp "  Mot de passe           : " mdp1
            echo ""
            read -rsp "  Confirmation           : " mdp2
            echo ""

            if [ "$mdp1" != "$mdp2" ]; then
                saisie_invalide "Les mots de passe ne correspondent pas. Recommencez."
                echo ""
                continue
            fi

            if [ "${#mdp1}" -lt 14 ]; then
                saisie_invalide "Trop court : ${#mdp1} caractere(s), 14 minimum. Recommencez."
                echo ""
                continue
            fi

            types=0
            printf '%s\n' "$mdp1" | LC_ALL=C grep -q '[A-Z]'        && types=$(( types + 1 ))
            printf '%s\n' "$mdp1" | LC_ALL=C grep -q '[a-z]'        && types=$(( types + 1 ))
            printf '%s\n' "$mdp1" | LC_ALL=C grep -q '[0-9]'        && types=$(( types + 1 ))
            printf '%s\n' "$mdp1" | LC_ALL=C grep -q '[^A-Za-z0-9]' && types=$(( types + 1 ))
            if [ "$types" -lt 3 ]; then
                saisie_invalide "Trop simple : $types type(s)/3 requis (MAJ, min, chiffre, symbole)."
                echo ""
                continue
            fi

            # printf + grep -F : pas d'interpretation de "-", ni de "." comme joker
            if printf '%s\n' "$mdp1" | LC_ALL=C grep -qiF -- "$login"; then
                saisie_invalide "Le mot de passe contient le nom d'utilisateur. Recommencez."
                echo ""
                continue
            fi
            if [ "${#nom_norm}" -ge 3 ] && printf '%s\n' "$mdp1" | LC_ALL=C grep -qiF -- "$nom_norm"; then
                saisie_invalide "Le mot de passe contient le nom de famille. Recommencez."
                echo ""
                continue
            fi

            mdp_valide="$mdp1"
            ok "Mot de passe valide."
            break
        done

        if ! useradd -m -s /bin/bash -c "${prenom_brut} ${nom_brut}" "$login"; then
            erreur "Impossible de creer '$login'."
            unset mdp1 mdp2 mdp_valide
            echo ""
            read -rp "  Creer un autre utilisateur ? [o/N] : " continuer
            continuer=$(echo "$continuer" | tr '[:upper:]' '[:lower:]')
            continue
        fi
        ok "Utilisateur '$login' cree (repertoire : /home/$login)"

        printf '%s:%s\n' "$login" "$mdp_valide" | chpasswd 2>/dev/null
        rc_chpasswd=$?
        # Ne pas garder les mots de passe en memoire plus longtemps que necessaire
        unset mdp1 mdp2 mdp_valide
        if [ "$rc_chpasswd" -ne 0 ]; then
            erreur "Echec chpasswd. Suppression de '$login' et recommencement."
            userdel -r "$login" 2>/dev/null
            echo ""
            continue
        fi
        ok "Mot de passe applique pour '$login'"

        usermod -aG admin "$login"
        ok "Utilisateur '$login' ajoute au groupe 'admin'"

        chmod 700 "/home/$login"
        ok "Permissions /home/$login restreintes a 700"
    fi

    echo ""
    read -rp "  Voulez-vous creer un autre utilisateur ? [o/N] : " continuer
    continuer=$(echo "$continuer" | tr '[:upper:]' '[:lower:]')
    echo ""
done

ok "Creation des utilisateurs terminee."
avancer

# =============================================================================
# 4. RÈGLES D'AUDIT (auditd)
# =============================================================================
titre "4/10 - Regles d'audit (auditd)"

# On ne touche PAS /etc/audit/rules.d/audit.rules (directives -D / -b / -f /
# --backlog_wait_time). On cree un fichier dedie. Note : "99-..." est trie
# AVANT "audit.rules", mais augenrules remonte lui-meme -D/-b/-f en tete du
# fichier genere : l'ordre n'a donc pas d'incidence.
AUDIT_CUSTOM="/etc/audit/rules.d/99-securisation.rules"

if ! command -v auditctl > /dev/null 2>&1; then
    erreur "auditd non installe. Installez-le avec : dnf install audit"
else
    systemctl enable auditd > /dev/null 2>&1
    systemctl start  auditd > /dev/null 2>&1
    info "Ecriture de $AUDIT_CUSTOM ..."

    cat > "$AUDIT_CUSTOM" << 'EOF'
## Regles d'audit - Securisation AlmaLinux 10

## Montage/démontage de partition :
-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount

## Tâches planifiées
# Surveille les modifications de la liste blanche des utilisateurs autorisés à utiliser cron
-w /etc/cron.allow -p wa -k cron
# Surveille les modifications de la liste noire des utilisateurs interdits de cron
-w /etc/cron.deny -p wa -k cron
# Surveille les modifications des tâches cron personnalisées
-w /etc/cron.d/ -p wa -k cron
# Surveille les modifications des tâches cron quotidiennes
-w /etc/cron.daily/ -p wa -k cron
# Surveille les modifications des tâches cron horaires
-w /etc/cron.hourly/ -p wa -k cron
# Surveille les modifications des tâches cron mensuelles
-w /etc/cron.monthly/ -p wa -k cron
# Surveille les modifications des tâches cron hebdomadaires
-w /etc/cron.weekly/ -p wa -k cron
# Surveille les modifications du fichier crontab principal
-w /etc/crontab -p wa -k cron
# Surveille les modifications des crontabs utilisateurs
-w /var/spool/cron/ -p wa -k cron

## Connexions et déconnexions :
# Surveille les modifications de la configuration des connexions (umask, limites, etc.)
-w /etc/login.defs -p wa -k login
# Surveille les modifications des terminaux autorisés pour root (obsolète sur AlmaLinux 10 mais accepté)
-w /etc/securetty -p wa -k login
# Surveille les modifications du journal des échecs de connexion
-w /var/log/faillog -p wa -k login
# Surveille les modifications du journal des dernières connexions
-w /var/log/lastlog -p wa -k login
# Surveille les modifications du compteur de tentatives échouées (obsolète sur AlmaLinux 10 mais accepté)
-w /var/log/tallylog -p wa -k login

## SSH :
# Surveille les modifications de la configuration principale du serveur SSH
-w /etc/ssh/sshd_config -p wa -k sshd
# Surveille les modifications des fichiers de configuration SSH additionnels
-w /etc/ssh/sshd_config.d -p wa -k sshd
# Surveille les modifications des clés SSH du compte root
-w /root/.ssh -p wa -k rootkey

## Gestions des journaux :
# Surveille les modifications des logs d'audit (wa : "r" generait du bruit a chaque lecture, ausearch/aureport inclus)
-w /var/log/audit/ -p wa -k auditlog
# Idem sur le chemin alternatif (accepté par auditd même si inexistant)
-w /var/audit/ -p wa -k auditlog

## SELINUX :
# Surveille les modifications de la politique SELinux (contrôle d'accès obligatoire)
-w /etc/selinux/ -p wa -k mac_policy

## Systemd :
# Surveille les modifications de la configuration des services systemd
-w /etc/systemd/ -p wa -k systemd
# Surveille les modifications des fichiers unités systemd système
-w /usr/lib/systemd -p wa -k systemd

## Changer le hostname :
# Enregistre tout changement de nom d'hôte ou de domaine au niveau système
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications

## Autres fichiers :
# Surveille les modifications du fichier hosts (résolution DNS locale)
-w /etc/hosts -p wa -k network_modifications
# Surveille les modifications de la configuration réseau globale
-w /etc/sysconfig/network -p wa -k network_modifications
# Surveille les modifications des scripts d'interface réseau
-w /etc/sysconfig/network-scripts -p wa -k network_modifications
# Surveille les modifications du dossier réseau legacy
-w /etc/network/ -p wa -k network
# Surveille les modifications de la configuration NetworkManager
-a always,exit -F dir=/etc/NetworkManager/ -F perm=wa -k network_modifications

## Gestions des comptes :
# Surveille les modifications du fichier des groupes
-w /etc/group -p wa -k etcgroup
# Surveille les modifications du fichier des utilisateurs
-w /etc/passwd -p wa -k etcpasswd
# Surveille les modifications des mots de passe chiffrés des groupes
-w /etc/gshadow -p wa -k etcgroup
# Surveille les modifications des mots de passe chiffrés des utilisateurs
-w /etc/shadow -p wa -k etcpasswd
# Surveille les modifications des anciens mots de passe (historique)
-w /etc/security/opasswd -p wa -k opasswd

## Elévations de privilèges :
# Surveille les modifications des droits sudo des utilisateurs
-w /etc/sudoers -p wa -k actions
# Surveille les modifications des règles sudo additionnelles
-w /etc/sudoers.d/ -p wa -k actions
EOF

    # Binaires critiques : chemins REELS (dnf -> dnf-3, shutdown/reboot/poweroff/halt -> systemctl).
    # Les extinctions/redemarrages sont donc journalises sous la cle "systemd".
    {
        echo ""
        echo "## Binaires critiques (chemins reels resolus par le script)"
        regle_watch_binaire /usr/bin/dnf       dnf
        regle_watch_binaire /usr/bin/rpm       rpm
        regle_watch_binaire /usr/bin/systemctl systemd
        regle_watch_binaire /usr/bin/passwd    passwd_modification
    } >> "$AUDIT_CUSTOM"

    # Regles optionnelles tres verbeuses
    echo ""
    info "Journalisation de TOUTES les connexions reseau sortantes (connect IPv4/IPv6)."
    info "Tres verbeux : gros volume de logs, peut ralentir un serveur charge."
    read -rp "  Activer ? [o/N] : " choix_connect
    choix_connect=$(echo "$choix_connect" | tr '[:upper:]' '[:lower:]')
    if [ "$choix_connect" = "o" ] || [ "$choix_connect" = "oui" ]; then
        cat >> "$AUDIT_CUSTOM" << 'EOF'

## Connexion IPV4 :
# Enregistre toutes les connexions réseau IPv4 réussies (a2=16 = taille sockaddr IPv4)
-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4

## Connexion IPV6 :
# Enregistre toutes les connexions réseau IPv6 réussies (a2=28 = taille sockaddr IPv6)
-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6
EOF
        ok "Regles connect IPv4/IPv6 activees"
    else
        info "Regles connect IPv4/IPv6 : ignorees."
    fi

    # Nettoyage des espaces en fin de ligne
    sed -i 's/[[:space:]]*$//' "$AUDIT_CUSTOM"
    chmod 640 "$AUDIT_CUSTOM"
    ok "$AUDIT_CUSTOM ecrit"
fi
avancer   # sous-etape : regles ecrites (toujours compte, meme si auditd absent)


if command -v auditctl > /dev/null 2>&1; then
    if [ "$(auditctl -s 2>/dev/null | awk '$1 == "enabled" {print $2}')" = "2" ]; then
        avertir "Audit en mode immuable (-e 2) : les nouvelles regles ne seront chargees qu'apres redemarrage."
    fi
    if sortie_audit=$(augenrules --load 2>&1); then
        ok "Regles d'audit rechargees (augenrules --load)"
    else
        erreur "augenrules --load echoue ($(echo "$sortie_audit" | tail -n 2 | tr '\n' ' ')). Verifiez : augenrules --check"
    fi
fi
avancer

# =============================================================================
# 5. DÉSACTIVATION IPv6
# =============================================================================
titre "5/10 - Desactivation IPv6"

cat > /etc/sysctl.d/99-disable-ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6     = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6      = 1
EOF

sysctl --system > /dev/null 2>&1
if [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)" = "1" ]; then
    ok "IPv6 desactive (effectif immediatement ; persistant via /etc/sysctl.d/99-disable-ipv6.conf)"
else
    erreur "IPv6 toujours actif apres sysctl --system. Verifiez /etc/sysctl.d/99-disable-ipv6.conf"
fi
avancer

# =============================================================================
# 6. ACCÈS PHYSIQUE : BANNIÈRE + TIMEOUT + GRUB
# =============================================================================
titre "6/10 - Acces physique (banniere, timeout, GRUB)"

cat > /etc/issue << 'EOF'
**********************************************************************************
*                                                                                *
*           ACCÈS STRICTEMENT RÉSERVÉ AU PERSONNEL AUTORISÉ                      *
*                                                                                *
*                                                                                *
*      En poursuivant, vous acceptez de vous conformer aux politiques            *
*      de sécurité en vigueur et aux réglementations applicables.                *
*                                                                                *
*      Toute utilisation non autorisée peut faire l’objet de                     *
*             poursuites disciplinaires et/ou pénales.                           *
*                                                                                *
*                                                                                *
*                                                                                *
*             Sécurité • Confidentialité • Traçabilité                           *
*                                                                                *
**********************************************************************************
EOF
# /etc/issue = console locale ; /etc/issue.net = banniere SSH (directive Banner)
cat /etc/issue > /etc/issue.net
ok "/etc/issue et /etc/issue.net mis a jour"
avancer

cat > /etc/profile.d/50-tmout.sh << 'EOF'
TMOUT=600
readonly TMOUT
export TMOUT
EOF
chmod 644 /etc/profile.d/50-tmout.sh
ok "TMOUT=600 configure dans /etc/profile.d/50-tmout.sh"
avancer

# Protection GRUB : boucle jusqu'a saisie valide
# - Longueur >= 14 caracteres verifiee avant de hasher
# - Confirmation verifiee : si les deux entrees different -> on recommence
# - Hash PBKDF2/SHA512 via grub2-mkpasswd-pbkdf2 -> /boot/grub2/user.cfg
info "Protection GRUB par mot de passe (min 14 caracteres)."
echo ""

if ! command -v grub2-mkpasswd-pbkdf2 > /dev/null 2>&1; then
    erreur "grub2-mkpasswd-pbkdf2 introuvable. Installez grub2-tools."
elif [ ! -d /boot/grub2 ]; then
    erreur "/boot/grub2 introuvable. Protection GRUB non configuree."
else
    while true; do

        read -rsp "  Mot de passe GRUB (min 14 car.) : " grub_pass1
        echo ""

        if [ "${#grub_pass1}" -lt 14 ]; then
            saisie_invalide "Trop court (${#grub_pass1} car.), 14 minimum. Recommencez."
            echo ""
            continue
        fi

        read -rsp "  Confirmation                   : " grub_pass2
        echo ""

        if [ "$grub_pass1" != "$grub_pass2" ]; then
            saisie_invalide "Les mots de passe ne correspondent pas. Recommencez."
            echo ""
            continue
        fi

        grub_hash=$(printf '%s\n%s\n' "$grub_pass1" "$grub_pass1" \
            | grub2-mkpasswd-pbkdf2 2>/dev/null \
            | grep "grub.pbkdf2" \
            | sed 's/.* //')
        unset grub_pass1 grub_pass2

        if [ -z "$grub_hash" ]; then
            saisie_invalide "Echec du hachage GRUB. Recommencez."
            echo ""
            continue
        fi

        echo "GRUB2_PASSWORD=${grub_hash}" > /boot/grub2/user.cfg
        chmod 600 /boot/grub2/user.cfg
        unset grub_hash
        ok "Mot de passe GRUB configure (/boot/grub2/user.cfg)"
        break

    done
fi
avancer

# =============================================================================
# 7. SÉCURISATION SSH + MISE À JOUR OPENSSH
# =============================================================================
titre "7/10 - Securisation et mise a jour SSH"

SSH_CONF="/etc/ssh/sshd_config"
SSH_DROPIN_DIR="/etc/ssh/sshd_config.d"
SSH_DROPIN="${SSH_DROPIN_DIR}/00-securisation.conf"

# --- 7a. Mise a jour d'OpenSSH (AVANT la configuration : un seul redemarrage de sshd)
echo ""
info "Verification des depots pour la mise a jour d'OpenSSH ..."
ssh_pkgs=()
for p in openssh openssh-server openssh-clients; do
    if rpm -q --quiet "$p"; then ssh_pkgs+=("$p"); fi
done

if [ "${#ssh_pkgs[@]}" -eq 0 ]; then
    erreur "Aucun paquet OpenSSH installe : mise a jour ignoree."
elif dnf -q --setopt=timeout=15 --setopt=retries=1 makecache > /dev/null 2>&1; then
    if dnf -y update "${ssh_pkgs[@]}" > /dev/null 2>&1; then
        ok "OpenSSH a jour via dnf (${ssh_pkgs[*]})"
    else
        erreur "Echec mise a jour OpenSSH."
    fi
else
    info "Depots injoignables. Chemin vers les RPM OpenSSH (vide pour ignorer) :"
    read -rp "  Chemin RPM : " rpm_path
    if [ -z "$rpm_path" ]; then
        info "Mise a jour OpenSSH ignoree."
    elif [ ! -d "$rpm_path" ]; then
        erreur "Repertoire '$rpm_path' introuvable."
    else
        shopt -s nullglob
        rpms=("$rpm_path"/*.rpm)
        shopt -u nullglob
        if [ "${#rpms[@]}" -eq 0 ]; then
            erreur "Aucun .rpm dans '$rpm_path'."
        elif dnf -y install "${rpms[@]}" > /dev/null 2>&1; then
            ok "OpenSSH mis a jour (${#rpms[@]} RPM)"
        else
            erreur "Echec installation RPM. Verifiez les dependances."
        fi
    fi
fi
avancer

# --- 7b. Configuration dans un drop-in (lu AVANT sshd_config.d/50-*.conf & co)
# Sur RHEL, sshd_config commence par "Include sshd_config.d/*.conf" et, pour
# sshd, la premiere valeur rencontree l'emporte : un drop-in existant pourrait
# annuler nos reglages s'ils etaient ecrits dans sshd_config.
mkdir -p "$SSH_DROPIN_DIR"

SSH_DROPIN_BAK=""
if [ -f "$SSH_DROPIN" ]; then
    sauvegarder "$SSH_DROPIN"
    SSH_DROPIN_BAK="$BACKUP_PATH"
    ok "Sauvegarde : $SSH_DROPIN_BAK"
fi

SSH_CONF_BAK=""
if ! grep -qE '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/' "$SSH_CONF"; then
    sauvegarder "$SSH_CONF"
    SSH_CONF_BAK="$BACKUP_PATH"
    sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' "$SSH_CONF"
    ok "Include sshd_config.d ajoute en tete de $SSH_CONF (sauvegarde : $SSH_CONF_BAK)"
fi

{
    echo "# Genere par Script_SecurisationAlmaLinux.sh"
    echo "# 00- : lu en premier ; pour sshd la premiere valeur rencontree s'applique."
} > "$SSH_DROPIN"
chmod 600 "$SSH_DROPIN"

# Protocol 2 retire intentionnellement : supprime depuis OpenSSH 7.4,
# provoque l'echec de "sshd -t" sur AlmaLinux 10 (OpenSSH 9.x).
appliquer_ssh "PermitRootLogin" "no"
appliquer_ssh "LoginGraceTime"  "30"
appliquer_ssh "MaxAuthTries"    "3"
appliquer_ssh "MaxSessions"     "2"
appliquer_ssh "MaxStartups"     "3:50:10"
appliquer_ssh "Banner"          "/etc/issue.net"
ok "Parametres SSH ecrits dans $SSH_DROPIN"
info "MaxAuthTries 3 : echec possible si l'agent SSH presente plusieurs cles (utilisez -o IdentitiesOnly=yes)."
info "MaxSessions 2  : limite le multiplexage SSH (ControlMaster), VS Code Remote, Ansible..."
avancer

# --- 7c. Restrictions d'acces (facultatives)
demander_liste_ssh "AllowUsers"  "Logins autorises en SSH"   user
SSH_ALLOW_USERS="$LISTE_RESULTAT"
demander_liste_ssh "DenyUsers"   "Logins interdits de SSH"   user
SSH_DENY_USERS="$LISTE_RESULTAT"
demander_liste_ssh "AllowGroups" "Groupes autorises en SSH"  group
SSH_ALLOW_GROUPS="$LISTE_RESULTAT"
demander_liste_ssh "DenyGroups"  "Groupes interdits de SSH"  group
SSH_DENY_GROUPS="$LISTE_RESULTAT"

echo ""
avertir_acces_ssh

# --- 7d. Validation, verification des valeurs effectives, redemarrage
if sshd_err=$(sshd -t 2>&1); then
    SSHD_T=$(sshd -T 2>/dev/null)
    verifier_ssh "permitrootlogin" "no"
    verifier_ssh "logingracetime"  "30"
    verifier_ssh "maxauthtries"    "3"
    verifier_ssh "maxsessions"     "2"
    verifier_ssh "maxstartups"     "3:50:10"
    systemctl enable sshd > /dev/null 2>&1
    if systemctl restart sshd; then
        ok "Service sshd active et redemarre"
    else
        erreur "Echec redemarrage sshd."
    fi
    avertir "Gardez cette session ouverte et testez une NOUVELLE connexion SSH avant de vous deconnecter."
else
    erreur "Config SSH invalide : $(echo "$sshd_err" | head -n 2 | tr '\n' ' ')"
    erreur "Restauration de la configuration precedente."
    if [ -n "$SSH_DROPIN_BAK" ]; then
        cat "$SSH_DROPIN_BAK" > "$SSH_DROPIN"
    else
        rm -f "$SSH_DROPIN"
    fi
    if [ -n "$SSH_CONF_BAK" ]; then
        cat "$SSH_CONF_BAK" > "$SSH_CONF"
    fi
    erreur "Corrigez la configuration puis : sshd -t && systemctl restart sshd"
fi
avancer

# =============================================================================
# 8. OPTIONS DE MONTAGE DES PARTITIONS (/etc/fstab)
# =============================================================================
titre "8/10 - Options de montage des partitions (/etc/fstab)"

FSTAB="/etc/fstab"
sauvegarder "$FSTAB"
FSTAB_BAK="$BACKUP_PATH"
ok "Sauvegarde : $FSTAB_BAK"

# Nombre d'erreurs findmnt AVANT modification (pour ne restaurer que si on aggrave)
erreurs_fstab_avant=$(findmnt --verify --tab-file "$FSTAB" 2>&1 | grep -c '\[E\]')

# /dev/shm n'est generalement PAS dans le fstab (monte par systemd) :
# sans ligne dediee, aucune option ne peut etre ajoutee -> on la cree.
if [ -z "$(ligne_fstab /dev/shm)" ]; then
    echo "tmpfs /dev/shm tmpfs defaults,nosuid,nodev,noexec 0 0" >> "$FSTAB"
    ok "Ligne /dev/shm ajoutee au fstab (absente par defaut)"
fi

# Seuls les points de montage presents dans le fstab (lignes actives) sont modifies.
# /var n'est volontairement PAS en noexec (conteneurs, services, /var/lib...).
durcir_montage "/boot"          nosuid nodev noexec
durcir_montage "/tmp"           nosuid nodev noexec
durcir_montage "/home"          nosuid nodev
durcir_montage "/var"           nosuid nodev
durcir_montage "/var/tmp"       nosuid nodev noexec
durcir_montage "/var/log"       nosuid nodev noexec
durcir_montage "/var/log/audit" nosuid nodev noexec
durcir_montage "/dev/shm"       nosuid nodev noexec

erreurs_fstab_apres=$(findmnt --verify --tab-file "$FSTAB" 2>&1 | grep -c '\[E\]')
if [ "$erreurs_fstab_apres" -gt "$erreurs_fstab_avant" ]; then
    erreur "fstab invalide apres modification (findmnt --verify). Restauration de $FSTAB_BAK"
    cat "$FSTAB_BAK" > "$FSTAB"
else
    systemctl daemon-reload > /dev/null 2>&1
    ok "/etc/fstab mis a jour et verifie (findmnt --verify)"
fi
avancer

if mount -o remount /dev/shm > /dev/null 2>&1 \
    && findmnt -no OPTIONS /dev/shm | grep -q 'noexec'; then
    ok "/dev/shm remonte immediatement : $(findmnt -no OPTIONS /dev/shm)"
else
    info "/dev/shm : options actives au prochain redemarrage."
fi
info "Autres points de montage : actifs au prochain redemarrage."
info "Si dnf echoue avec un code 126 sur un scriptlet apres reboot : verifiez le noexec de /var/tmp et /tmp."
avancer

# =============================================================================
# 9. DURCISSEMENT COMPLÉMENTAIRE (FACULTATIF - NON DANS LA PROCÉDURE)
# =============================================================================
titre "9/10 - Durcissement complementaire (facultatif)"

echo ""
info "Les mesures suivantes NE SONT PAS dans la procedure officielle."
info "Chaque mesure est proposee avec une explication de son impact."
echo ""

# 9a. SELinux
echo "---------------------------------------------------------------"
info "SELinux en mode Enforcing"
info "Ce que ca fait : applique les politiques de controle d'acces"
info "obligatoire (MAC). Peut bloquer des applications mal etiquetees."
info "Si SELinux est actuellement desactive : relabel complet au prochain"
info "demarrage (le boot sera plus long)."
read -rp "  Appliquer ? [o/N] : " choix
choix=$(echo "$choix" | tr '[:upper:]' '[:lower:]')
if [ "$choix" = "o" ] || [ "$choix" = "oui" ]; then
    if command -v getenforce > /dev/null 2>&1; then
        etat_selinux=$(getenforce 2>/dev/null)
        if [ -f /etc/selinux/config ]; then
            sed -i -E 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
        fi
        case "$etat_selinux" in
            Enforcing)
                ok "SELinux deja en mode Enforcing (persistant via /etc/selinux/config)"
                ;;
            Permissive)
                if setenforce 1 > /dev/null 2>&1; then
                    ok "SELinux passe en Enforcing (immediat + persistant)"
                else
                    erreur "setenforce 1 a echoue. Le mode persistant sera applique au prochain demarrage."
                fi
                ;;
            Disabled)
                if grep -qw 'selinux=0' /proc/cmdline; then
                    erreur "SELinux est desactive par le noyau (selinux=0). Retirez-le : grubby --update-kernel=ALL --remove-args=\"selinux=0\" puis redemarrez."
                else
                    touch /.autorelabel
                    RELABEL_DEMANDE=1
                    ok "SELinux : Enforcing au prochain demarrage (relabel complet programme via /.autorelabel)"
                fi
                ;;
            *)
                erreur "Etat SELinux inconnu : ${etat_selinux:-?}"
                ;;
        esac
    else
        erreur "SELinux non disponible."
    fi
else
    info "SELinux : ignore."
fi
avancer

# 9b. Permissions fichiers sensibles
echo ""
echo "---------------------------------------------------------------"
info "Permissions strictes sur /etc/shadow et /etc/gshadow"
info "Ce que ca fait : passe shadow et gshadow a 000 (valeur d'origine"
info "sur RHEL). Root y accede toujours (il contourne les droits) ; les"
info "autres comptes n'y ont aucun acces. passwd et group restent a 644."
info "Peut perturber des outils tiers qui lisent shadow sans etre root."
read -rp "  Appliquer ? [o/N] : " choix
choix=$(echo "$choix" | tr '[:upper:]' '[:lower:]')
if [ "$choix" = "o" ] || [ "$choix" = "oui" ]; then
    chmod 644 /etc/passwd  && chown root:root /etc/passwd  && ok "/etc/passwd  -> 644"
    chmod 000 /etc/shadow  && chown root:root /etc/shadow  && ok "/etc/shadow  -> 000"
    chmod 644 /etc/group   && chown root:root /etc/group   && ok "/etc/group   -> 644"
    chmod 000 /etc/gshadow && chown root:root /etc/gshadow && ok "/etc/gshadow -> 000"
else
    info "Permissions : ignorees."
fi
avancer

# 9c. Services protocoles non securises
# (mentionnes dans la procedure : "SSH a la place de telnet, SFTP a la place de FTP")
echo ""
echo "---------------------------------------------------------------"
info "Desactivation des services a protocole non securise"
info "Ce que ca fait : arrete, desactive et masque telnet, rsh,"
info "rlogin, rexec et vsftpd (FTP). Ces services transmettent"
info "les mots de passe en clair sur le reseau."
info "Procedure officielle : utiliser SSH / SFTP / HTTPS a la place."
read -rp "  Appliquer ? [o/N] : " choix
choix=$(echo "$choix" | tr '[:upper:]' '[:lower:]')
if [ "$choix" = "o" ] || [ "$choix" = "oui" ]; then
    unites_installees=$(systemctl list-unit-files --no-legend 2>/dev/null | awk '{print $1}')
    for service in telnet rsh rlogin rexec vsftpd; do
        # Unites exactes (service, socket, modeles "@") : pas de correspondance par prefixe
        unites=$(printf '%s\n' "$unites_installees" | grep -E "^${service}@?\.(service|socket)$")
        if [ -n "$unites" ]; then
            for unite in $unites; do
                systemctl stop    "$unite" > /dev/null 2>&1
                systemctl disable "$unite" > /dev/null 2>&1
                systemctl mask    "$unite" > /dev/null 2>&1
            done
            ok "Service '$service' arrete, desactive et masque (${unites//$'\n'/ })"
        else
            info "Service '$service' absent (rien a faire)"
        fi
    done
else
    info "Services non securises : ignore."
fi
avancer

# 9d. umask 027
echo ""
echo "---------------------------------------------------------------"
info "umask 027 par defaut"
info "Ce que ca fait : les nouveaux fichiers crees par les utilisateurs"
info "auront par defaut les droits 640 (fichiers) et 750 (repertoires)."
info "Ajoute umask 027 dans /etc/profile ET /etc/bashrc (RHEL y redefinit"
info "l'umask apres /etc/profile) + UMASK 027 dans /etc/login.defs."
info "Les autres utilisateurs n'auront aucun acces. Peut gener"
info "des logiciels qui s'attendent a un umask 022."
read -rp "  Appliquer ? [o/N] : " choix
choix=$(echo "$choix" | tr '[:upper:]' '[:lower:]')
if [ "$choix" = "o" ] || [ "$choix" = "oui" ]; then
    ajouter_umask /etc/profile
    ajouter_umask /etc/bashrc
    if [ -f /etc/login.defs ]; then
        definir_login_defs UMASK 027
        ok "UMASK 027 defini dans /etc/login.defs"
    fi
else
    info "umask 027 : ignore."
fi
avancer

# =============================================================================
# 10. DÉSACTIVATION DE MODULES NOYAU (PROCÉDURE OFFICIELLE)
# =============================================================================
titre "10/10 - Desactivation modules noyau (procedure officielle)"

echo ""
info "Ces 6 modules font partie de la procedure officielle de securisation."
info "Chaque module reste propose individuellement avec son impact avant"
info "desactivation, car l'un d'eux (usb-storage) est nettement plus"
info "susceptible de gener l'usage quotidien que les 5 autres."
echo ""


au_moins_un=0

while IFS="|" read -r module description <&3; do
    [ -z "$module" ] && continue
    fichier_conf="/etc/modprobe.d/disabled-${module}.conf"
    echo ""
    echo "---------------------------------------------------------------"
    info "Module : $module"
    info "Impact : $description"
    if [ -f "$fichier_conf" ]; then
        info "Deja blackliste. Rien a faire."
        continue
    fi
    read -rp "  Desactiver ce module ? [o/N] : " choix_module
    choix_module=$(echo "$choix_module" | tr '[:upper:]' '[:lower:]')
    if [ "$choix_module" = "o" ] || [ "$choix_module" = "oui" ]; then
        echo "blacklist ${module}"          >  "$fichier_conf"
        echo "install ${module} /bin/false" >> "$fichier_conf"
        ok "Module '$module' blackliste -> $fichier_conf"
        au_moins_un=1
    else
        info "Module '$module' conserve actif."
    fi
done 3<< 'MODULES_LIST'
cramfs|Systeme de fichiers compresse ROM. Rare en entreprise, aucun impact prevu.
freevxfs|Systeme de fichiers Veritas. Tres rare en entreprise, aucun impact prevu.
hfs|Systeme de fichiers Apple HFS (vieux Mac). Empeche la lecture de disques HFS.
hfsplus|Systeme de fichiers Apple HFS+ (Mac modernes). Empeche la lecture de disques Mac.
jffs2|Systeme de fichiers flash embarque. Inutile sur serveur standard, aucun impact.
usb-storage|ATTENTION - IMPACT ELEVE : bloque TOUTES les cles USB et disques durs externes branches en USB, pour tous les utilisateurs et a chaque demarrage. C'est le seul des 6 modules de cette liste susceptible de gener concretement l'usage quotidien. Verifiez que personne n'a besoin de brancher une cle USB avant de confirmer.
MODULES_LIST

avancer

if [ "$au_moins_un" -eq 1 ]; then
    info "Regeneration initramfs (dracut -f) pour les blacklists ..."
    if command -v dracut > /dev/null 2>&1; then
        if dracut -f > /dev/null 2>&1; then
            ok "initramfs regenere"
        else
            erreur "dracut -f echoue. Relancez manuellement."
        fi
    else
        erreur "dracut introuvable : dnf install dracut"
    fi
else
    info "Aucun module blackliste, initramfs non modifie."
fi

# =============================================================================
# FIN DU SCRIPT
# =============================================================================
tput cup $(( $(tput lines 2>/dev/null || echo 24) - 1 )) 0 2>/dev/null
echo ""
echo ""

titre "RAPPORT D'EXECUTION - 10 SECTIONS"
echo ""
# Statuts reels : OK / PARTIEL / ERREUR / IGNORE (aucune action realisee)
rapport "Politique de mots de passe (login.defs, pwquality)"   "$(statut_section 1)"
rapport "Verrouillage de compte (faillock : 6 essais/30 min)"  "$(statut_section 2)"
rapport "Groupe admin + comptes nominatifs (sudoers.d)"        "$(statut_section 3)"
rapport "Regles d'audit (99-securisation.rules)"               "$(statut_section 4)"
rapport "Desactivation IPv6 (sysctl)"                          "$(statut_section 5)"
rapport "Banniere /etc/issue + TMOUT 600 + GRUB"               "$(statut_section 6)"
rapport "Securisation SSH + mise a jour OpenSSH"               "$(statut_section 7)"
rapport "Options de montage fstab (nosuid/nodev/noexec)"       "$(statut_section 8)"
rapport "Durcissement complementaire (facultatif)"             "$(statut_section 9)"
rapport "Modules noyau (cramfs, hfs, jffs2, usb-storage...)"   "$(statut_section 10)"
echo ""


titre "ACTIONS REQUISES APRES REDEMARRAGE"
echo ""
centrer "[!] Options fstab    ->  effectives apres reboot (sauf /dev/shm)"
centrer "[!] Protection GRUB  ->  effective apres reboot"
centrer "[!] Modules noyau    ->  effectifs apres reboot (si blacklistes)"
if [ "$RELABEL_DEMANDE" -eq 1 ]; then
    centrer "[!] SELinux          ->  relabel complet au prochain boot (plus long)"
fi
centrer "[!] SSH              ->  testez une NOUVELLE connexion avant de fermer cette session"
echo ""


read -rp "  Redemarrer maintenant ? [o/N] : " reboot_choix
reboot_choix=$(echo "$reboot_choix" | tr '[:upper:]' '[:lower:]')

if [ "$reboot_choix" = "o" ] || [ "$reboot_choix" = "oui" ]; then
    echo ""
    centrer "Redemarrage dans 5 secondes..."
    sleep 5
    reboot
else
    echo ""
    centrer "Pensez a redemarrer le systeme des que possible."
    echo ""
fi

exit 0