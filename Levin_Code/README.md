# M122 - Aufgabe D: Aktuelles Wertschriften-Depot

Dieses Projekt implementiert einen automatisierten Wertschriften-Depot-Tracker in Bash. Es erfasst den Wert eines fiktiven Portfolios (Novartis-Aktien, USD-Bargeld und Bitcoins), holt aktuelle Kursdaten über schlüssellose Online-APIs ab, berechnet die historische und aktuelle Wertentwicklung und zeichnet diese über die Zeit hinweg auf.

## Systemdesign & Struktur

Das System wurde gemäss den Vorgaben des Moduls M122 entwickelt und enthält folgende Komponenten:

*   **Zentrales Automationsskript (`automate.sh`):** Führt den gesamten Ablauf aus (Abfragen, Berechnen, Loggen, Zippen, Mail-Generierung).
*   **Konfiguration (`depot.cfg`):** Definiert die Depotbestände und historischen Kaufpreise in CHF.
*   **Protokollierung (`depot.log`):** Laufende Protokollierung der Ausführung und eventueller Fehler mit Zeitangabe.
*   **Zeitschreibung (`depot_history.csv`):** Datenbank im CSV-Format, welche die historische Entwicklung der Depotwerte protokolliert.
*   **Rohdaten-Archiv (`data.zip`):** Zipt die originalen JSON-Antworten der APIs zur Dokumentation und Übermittlung.
*   **Admin-Benachrichtigung (`info.mail`):** Simuliert den E-Mail-Versand an den Administrator mit einem Bericht im E-Mail-Format.
*   **Testskript (`test_fetch.sh`):** Test- und Verifikationsskript für die API-Schnittstellen.

---

## Verwendete APIs (ohne Authentifizierung)

1.  **Bitcoin-Kurs (BTC/CHF):** `https://api.coinbase.com/v2/prices/BTC-CHF/spot`
2.  **USD-Wechselkurs (USD/CHF):** `https://api.coinbase.com/v2/prices/USD-CHF/spot`
3.  **Novartis Aktie (NOVN.SW in CHF):** Yahoo Finance Chart API (`https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d`)

---

## Installation & Konfiguration

Die Konfiguration der Assets erfolgt in `depot.cfg`:

```bash
# Novartis Aktienbestand und Kaufpreis in CHF
STOCK_QTY=10
STOCK_HIST_CHF=850.00

# USD-Bestand und Kaufpreis in CHF
USD_QTY=3000
USD_HIST_CHF=2750.00

# Bitcoin-Bestand und Kaufpreis in CHF
BTC_QTY=0.1
BTC_HIST_CHF=4500.00
```

---

## Ausführung & Parameter

Das Skript kann manuell oder automatisiert gestartet werden. Es unterstützt folgende Parameter:

```bash
# Hilfe anzeigen
bash automate.sh --help

# Standardausführung (nutzt depot.cfg im selben Ordner)
bash automate.sh

# Ausführung mit benutzerdefinierter Konfiguration
bash automate.sh --config /pfad/zu/meiner.cfg

# Ausführung mit benutzerdefiniertem Log- und History-Pfad
bash automate.sh --log /pfad/zu/run.log --history /pfad/zu/history.csv
```

---

## Automatisierung (CronJob)

Um das Depot regelmässig (z. B. alle 12 Stunden) zu überwachen, kann ein CronJob eingerichtet werden:

1.  Öffnen Sie die Crontab-Konfiguration:
    ```bash
    crontab -e
    ```
2.  Fügen Sie folgende Zeile hinzu (passen Sie den Pfad an Ihr System an):
    ```bash
    0 */12 * * * /bin/bash /pfad/zu/D_aktuelles-wertschriften-depot/automate.sh
    ```

---

## KI-Tutor Deklaration

Dieses Projekt wurde in Zusammenarbeit mit dem KI-Tutor (Google DeepMind Antigravity) entwickelt.
*   **Code-Generierung & Strukturierung:** Alle Skriptstrukturen, Parameter-Parser und Berechnungslogiken wurden gemeinsam entworfen.
*   **Verifikation:** Die API-Kopplung und JSON-Auswertung wurden mittels Testskripten (`test_fetch.sh`) und Log-Dateien überprüft.
