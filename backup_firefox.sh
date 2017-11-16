#!/bin/bash

# In diesem Skript werden alle wichtige Dateien von Firefox für ein Systemupgrade
# in die Cloud gesichert.

#TODO: checken ob dialog installiert ist
#TODO: checken ob der Ordner von Firefox überhaupt existiert
#TODO: schauen ob man das für andere Profile auch machen kann..
#TODO: Mehrfachauswahl möglich machen
#TODO: Auswahl möglich machen was kopiert werden soll
#TODO: Fehler beim Kopieren mitloggen und Fehlermeldungen ausgeben und abfangen
#TODO: Logfile schreiben

dialog --backtitle "Sicherungsmedium" --title "Auswahl" --yesno "Willst du das Backup in die Cloud sichern?" 15 60
if [[ $? == "0" ]];
then
 cloud = true
 dialog --backtitle "Verschlüsselung der Daten" --title "Verschlüsselung" --yesno "Willst du die Daten verschlüsslen?" 15 60
 if [[ $? == "0" ]]; then
    encrypt = true
 fi
 clear
 read -p "Gib bitte den vollständigen Pfad des Servers an oder Enter für github
 " serverpath
fi

#Mehrere Benutzerkonten sichern
dialog --backtitle "Konten" --title "mehr Benutzer?" --yesno "Willst du die Konten von mehreren Benutzern kopieren?" 15 60
if [[ $? == "0" ]]; then
  cut -d: -f1 /etc/passwd
  #TODO User richtig zählen und ausgeben
  dialog --checklist "Wähle alle Benutzer aus, von denen die Einstellungen gesichert werden sollen:" 15 60 3 \
  1 "jack" on \
  2 "Neo" off \
  3 "Trinity" off
fi

if [[ -d ~/.mozilla/firefox ]]; then
  echo "Firefox wurde im Standardpfad gefunden: $HOME/.mozilla/firefox"
else
  read -p "Ordner mit Firefox nicht im Standardpfad gefunden. Bitte gib den richtigen Pfad ein!" FILE
fi
  cd /tmp
  mkdir firefox_backup
  FILE=$(dialog --stdout --title "Bitte Profilordner eintippen oder Leertaste für Auswahl (in linker Spalte). Normalerweise '.dafault'" --fselect $HOME/.mozilla/firefox/ 14 48)
  clear
  echo "${FILE} wurde ausgewählt."
  echo "Kopiere Lesezeichen, Downloads und Chronik.."
  sudo cp $FILE/places.sqlite firefox_backup/
  echo "Kopiere Passwörter.."
  sudo cp $FILE/key3.db firefox_backup/
  sudo cp $FILE/logins.json firefox_backup/
  echo "Kopiere Seitenspezifische Einstellungen.."
  sudo cp $FILE/permissions.sqlite firefox_backup/
  echo "Kopiere Suchmaschinen.."
  sudo cp $FILE/search.json.mozlz4 firefox_backup/
  echo "Kopiere Such- und Formulardaten.."
  sudo cp $FILE/formhistory.sqlite firefox_backup/
  echo "Kopiere Cookies.."
  sudo cp $FILE/cookies.sqlite firefox_backup/
  echo "Kopiere Sicherheitszertifikate-Einstellungen.."
  sudo cp $FILE/cert8.db firefox_backup/
  echo "Kopiere Datei-Formate und Download-Aktionen.."
  sudo cp $FILE/handlers.json firefox_backup/
  echo "Kopiere Einstellungen für Erweiterungen.."
  sudo cp -r $FILE/extensions firefox_backup/
  echo "Kopiere Plugin-MIME Typen.."
  sudo cp $FILE/pluginreg.dat firefox_backup/
  echo "Kopiere Addon-Liste.."
  sudo cp $FILE/addons.json firefox_backup/
  echo "Archiv erzeugen und komprimieren.."
  sudo tar -czf firefox_backup.tar.gz firefox_backup/
  echo "/n Hilfe und Erläuterungen zu den einzelnen Dateine auf:
  https://support.mozilla.org/de/kb/wiederherstellen-wichtiger-daten-aus-altem-profil"

dialog --backtitle "" --title "Verschlüsselung" --yesno "Willst du die Daten verschlüsslen?" 15 60
echo "$serverpath"
