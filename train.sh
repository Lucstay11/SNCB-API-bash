#######################################################
##############SNCB API EN BASH SCRIPT##################
#######################################################
noir2='\033[7;30m'
noir='\033[1;30m'
white='\e[1;37m'
white2='\e[7;37m'
blanc='\e[1;35m'
vert='\e[1;32m'
bleu_clair='\e[1;36m'
bleu='\e[1;34m'
bleu2='\e[7;34m'
rouge='\e[1;31m'
rouge_debut='\e[3;31m'
rouge_barrer='\e[9;31m'
rouge_d='\e[8;31m'
jaune='\e[1;33m'
rouge2='\e[2;31m'
jaune2='\e[2;33m'
bleu2='\e[7;34m'
rm .info > /dev/null 2>&1

function wifi_dispo(){
if [[ $(ping -c 1 google.fr >/dev/null 2>&1;echo $?) != 0 ]];then
clear
echo
echo -e $rouge "●●Pas de réseau●● 📵🌐"
echo
exit
fi
}

function api_dispo(){
if [[ $(curl -s https://irail.be/stations/NMBS/008812005 | grep "Server Error" > /dev/null 2>&1;echo $?) == 0 ]];then
clear
echo
echo -e $rouge "API indisponible 🌐 📈"
echo
echo -e $bleu "L'API n'accepte pas les demandes pour l'instant donc vous quitter le programme"
echo -e $vert "Cause possible =》 Surchage de requetes,beug du serveur"
echo -e $jaune "Réessayer plus tard!"
echo -e
echo
exit
fi
}


     if [[ $1 == "" && $2 == "" ]];then #Si le script prends pas d'argument alors il se lance normalement

             function recherche(){
                           clear
                         wifi_dispo
                         api_dispo
                         echo -e $bleu     "    ███████  ██████ ███    ██ ██████"
                           echo -e $bleu     "    ██      ██      ████   ██ ██   ██"
                           echo -e $bleu     "    ███████ ██      ██ ██  ██ ██████"
                           echo -e $bleu     "         ██ ██      ██  ██ ██ ██   ██"
                           echo -e $bleu   " 🚄 ███████  ██████ ██   ████ ██████ ${noir}BEL${jaune}GU${rouge}IM 🚉"
                           echo -e $white"█████████████████████████████████████████████████"
                                   echo -e $bleu2 $white2 " $noir Horaire et départ en temps réel [API] 🌐 " | toilet -f term -F border
                                   echo -e $bleu2 "  Information sur les trains et les retards 🔍" | toilet -f term -F border

   station=$(cat .nom-stations.txt | fzf --prompt [Station]: --reverse --multi --height 50% --exact)
   echo -e $white
   site_ville=$(cat -n .site-station.txt | grep $station | sed -n 1p | awk '{print $2}')
        }
        recherche

         function lister_gare_dispo(){
         clear
         echo -e $white2 "$rouge2                Gare de $bleu $station                      " | toilet -f term -F border
          nb_gare=$(curl -s $site_ville | jq | grep headsign | sed '1d' | wc -l)
             for info in headsign platform delay canceled scheduledDepartureTime routeLabel
              do
                 if [[ $info == canceled ]];then
                 curl -s $site_ville | jq | grep $info | tr -d '":,' >> .info
                 else
                 curl -s $site_ville | jq | grep $info | sed '1d' | tr -d '":,' >> .info
                 fi
               done
nb_retard=0
       for (( i=1; i<= $nb_gare; i++ ))
         do
           nom=$( cat .info | grep headsign | sed -n "$i"p | cut -c15-)
           depart1=$(cat .info | grep scheduledDepartureTime | sed -n "$i"p | awk '{print $2}' | cut -c12- | fold -b2 | sed -n 1p)
           depart2=$(cat .info | grep scheduledDepartureTime | sed -n "$i"p | awk '{print $2}' | cut -c12- | fold -b2 | sed -n 2p)
           voix=$(cat .info | grep platform | sed -n "$i"p | awk '{print $2}')
           retard=$(cat .info | grep delay | sed -n "$i"p | awk '{print $2}')
           retard=$(($retard/60))
           cancel=$(cat .info | grep canceled | sed -n "$i"p | awk '{print $2}')
           label=$(cat .info | grep routeLabel | sed -n "$i"p | awk '{print $2 $3}')
           nb_retard=$(($nb_retard+$retard))
         if [[ $retard == 0 && $cancel == 0 ]];then #condition si pas de retard et pas annuler
          echo -e $noir2 "$voix $bleu $nom $bleu_clair$depart1:$depart2 $noir $jaune Routelabel($label)" | toilet -f term -F border
         elif [[ $cancel != "0" ]];then #condition si annuler
          cancel=$(cat .info | grep canceled | sed -n "$i"p | awk '{print $2}')
          echo -e $rouge_barrer "$voix $nom $bleu_clair$depart1:$depart2 $noir $jaune Routelabel($label) $rouge ANNULER!" | toilet -f term -F border
         else #Si retard
           depart_m=$(($depart2 + $retard))
           depart_h=$(($depart1))
         if [[ $depart_m > 59 ]];then depart_h=$(($depart1+1)) && depart_m=$(($depart_m-60));fi #ajouter > 59 (format heure)
           if [[ $depart_m < 10 ]];then depart_m=$("0"$depart_m);fi #ajouter 0 < 10 (format minute)

   echo -e $noir2 "$voix $bleu $nom  $bleu_clair$depart1:$depart2 $rouge + $retard $white 🔜 $bleu_clair $depart_h : $depart_m $noir $jaune Routelabel($label)" | toilet -f term -F border
       fi
          done
       rm .info
              echo
              echo -e $white2 "$vert TOTAL $bleu $nb_gare Train" | toilet -f term -F border
              echo -e $white2 "$vert TOTAL Retard  $rouge $nb_retard min" | toilet -f term -F border
                   echo
              echo $somme
              echo -e "                        $vert Actualiser $bleu_clair ENTER 🔄  "
              printf "                         $vert Menu $rouge x ↩️ ";read -n1 -p "" r
                               if [[ $r == "" ]];then liste;elif [[ $r == "x" || $r == "X" ]];then bash $0;fi
           }
           lister_gare_dispo

       else  # Sinon il s'execute avec les arguments
       recherche_liste_station=$(cat .nom-stations.txt | grep -E ^"$1"$ | sed -n 1p)
       if [[ $1 != ""  && $2 == "" && $1 == $recherche_liste_station ]];then

    station=$(cat .nom-stations.txt | grep -E ^"$1"$ | sed -n 1p)
    site_ville=$(cat -n .site-station.txt | grep $station | sed -n 1p | awk '{print $2}')

      function arg_gare_dispo(){
         clear
         echo -e $white2 "$rouge2                Gare de $bleu $station                      " | toilet -f term -F border
          nb_gare=$(curl -s $site_ville | jq | grep headsign | sed '1d' | wc -l)
             for info in headsign platform delay canceled scheduledDepartureTime routeLabel
              do
                 if [[ $info == canceled ]];then
                 curl -s $site_ville | jq | grep $info | tr -d '":,' >> .info
                 else
                 curl -s $site_ville | jq | grep $info | sed '1d' | tr -d '":,' >> .info
                 fi
               done
nb_retard=0
       for (( i=1; i<= $nb_gare; i++ ))
         do
           nom=$( cat .info | grep headsign | sed -n "$i"p | cut -c15-)
           depart1=$(cat .info | grep scheduledDepartureTime | sed -n "$i"p | awk '{print $2}' | cut -c12- | fold -b2 | sed -n 1p)
           depart2=$(cat .info | grep scheduledDepartureTime | sed -n "$i"p | awk '{print $2}' | cut -c12- | fold -b2 | sed -n 2p)
           voix=$(cat .info | grep platform | sed -n "$i"p | awk '{print $2}')
           retard=$(cat .info | grep delay | sed -n "$i"p | awk '{print $2}')
           retard=$(($retard/60))
           cancel=$(cat .info | grep canceled | sed -n "$i"p | awk '{print $2}')
           label=$(cat .info | grep routeLabel | sed -n "$i"p | awk '{print $2 $3}')
           nb_retard=$(($nb_retard+$retard))
         if [[ $retard == 0 && $cancel == 0 ]];then #condition si pas de retard et pas annuler
          echo -e $noir2 "$voix $bleu $nom $bleu_clair$depart1:$depart2 $noir $jaune Routelabel($label)" | toilet -f term -F border
         elif [[ $cancel != "0" ]];then #condition si annuler
          cancel=$(cat .info | grep canceled | sed -n "$i"p | awk '{print $2}')
          echo -e $rouge_barrer "$voix $nom $bleu_clair$depart1:$depart2 $noir $jaune Routelabel($label) $rouge ANNULER!" | toilet -f term -F border
         else #Si retard
           depart_m=$(($depart2 + $retard))
           depart_h=$(($depart1))
         if [[ $depart_m > 59 ]];then depart_h=$(($depart1+1)) && depart_m=$(($depart_m-60));fi #ajouter > 59 (format heure)
           if [[ $depart_m < 10 ]];then depart_m=$("0"$depart_m);fi #ajouter 0 < 10 (format minute)

   echo -e $noir2 "$voix $bleu $nom  $bleu_clair$depart1:$depart2 $rouge + $retard $white 🔜 $bleu_clair $depart_h : $depart_m $noir $jaune Routelabel($label)" | toilet -f term -F border
       fi
          done
       rm .info
              echo
              echo -e $white2 "$vert TOTAL $bleu $nb_gare Train" | toilet -f term -F border
              echo -e $white2 "$vert TOTAL Retard  $rouge $nb_retard min" | toilet -f term -F border
                   echo
              echo $somme
              echo -e "                        $vert Actualiser $bleu_clair ENTER 🔄  "
              printf "                         $vert Menu $rouge x ↩️ ";read -n1 -p "" r
                               if [[ $r == "" ]];then liste;elif [[ $r == "x" || $r == "X" ]];then bash $0;fi
           }
           arg_gare_dispo

        recherche_liste_station=$(cat .nom-stations.txt | grep -E ^"$1"$ | sed -n 1p)
       elif [[ $1 == $recherche_liste_station && $2 == "info" ]];then
            echo "INFO $1"

           else
            echo -e $rouge "Aucune gare trouvée" | toilet -f term -F border
            echo -e $vert "Options Exemples"
            echo -e $bleu_clair "Liste Station:"
            echo -e $white "./ $0 $bleu Bruxelles-Nord" | toilet -f term -F border
            #echo -e $bleu_clair "Info Station:"
            #echo -e $white "./ $0 $bleu Bruxelles $jaune info" | toilet -f term -F border
       fi

   fi



