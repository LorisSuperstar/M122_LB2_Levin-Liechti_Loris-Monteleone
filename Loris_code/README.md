# M122 - Aufgabe E: Live-Portfolio-Wertverfolgungssystem

Diese Lösung implementiert ein umfassendes Vermögensüberwachungs- und Bewertungssystem mittels Bash-Automatisierung. Das System ruft regelmässig Live-Marktpreise für mehrere Anlageklassen ab (Novartis-Aktienbestände, USD-Reserven und Bitcoin-Digitalanlagen), integriert Echtzeit-Wechselkursdaten über offene API-Schnittstellen, berechnet Portfolio-Bewertungen und Performance-Metriken und verwaltet persistente Transaktionsdatensätze zur Trendanalyse.

## Systemarchitektur & Übersicht

Das Automatisierungsgerüst besteht aus mehreren integrierten Modulen, entwickelt gemäss M122-Spezifikationen:

*   **Primäres Orchestrierungsmodul (`run_portfolio.sh`):** Koordiniert den gesamten Arbeitsablauf einschliesslich Datenbeschaffung, Berechnungen, Persistierung, Audit-Protokollierung, Kompression und Berichterstellung.
*   **Umgebungseinstellungen (`portfolio.cfg`):** Speichert Portfolio-Zusammensetzung, ursprüngliche Erwerbsbewertungen in CHF und Dateiverweis-Pfade.
*   **Ausführungs-Audit-Trail (`portfolio.log`):** Erfasst alle Operationen, Zeitstempel und Diagnoseinformationen zu Fehlerbehebung und Verifikation.
*   **Portfolio-Hauptbuch (`portfolio_records.csv`):** Verwaltet chronologische Transaktionsdatensätze und Bewertungen im CSV-Format zur historischen Analyse.
*   **API-Antwort-Cache (`source_data.zip`):** Archiviert Roh-JSON-Responses von externen Datenquellen zur Verifikation und Audit-Zwecken.
*   **Systembericht (`report.mail`):** Generiert formatierte Zusammenfassungsberichte, die administrative Benachrichtigungen simulieren.
*   **Integrationstestsuite (`verify_sources.sh`):** Validierungs- und Debug-Utility zur Überprüfung von API-Konnektivität und Datenanalyse.

---

## Datenquellen von Dritten (öffentlich zugänglich, keine Authentifizierung erforderlich)

1.  **Kryptowährungs-Marktpreise (BTC/CHF):** `https://api.coinbase.com/v2/prices/BTC-CHF/spot`
2.  **Währungswechselkurse (USD/CHF):** `https://api.coinbase.com/v2/prices/USD-CHF/spot`
3.  **Wertpapierpreise (NOVN.SW, CHF):** Yahoo Finance REST API (`https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d`)

---

## Initialsetup & Anpassung

Die Vermögensbestände werden in der Konfigurationsdatei `portfolio.cfg` definiert:

```bash
# Novartis-Aktienposition und ursprüngliche Kostenbasis
EQUITY_UNITS=10
EQUITY_ORIG_CHF=850.00

# Fiat-Währungsreserve und ursprüngliche Kostenbasis
FIAT_UNITS=3000
FIAT_ORIG_CHF=2750.00

# Digitale Währung und ursprüngliche Kostenbasis
CRYPTO_UNITS=0.1
CRYPTO_ORIG_CHF=4500.00
```

---

## Runtime-Optionen & Ausführung

Die Automatisierung kann interaktiv oder zeitgesteuert ausgeführt werden. Unterstützte Befehlszeilenparameter:

```bash
# Dokumentation anzeigen
bash run_portfolio.sh --help

# Standardausführung (lädt portfolio.cfg aus aktuellem Verzeichnis)
bash run_portfolio.sh

# Alternative Konfigurationsquelle angeben
bash run_portfolio.sh --config /pfad/zur/benutzerdefiniert.cfg

# Log-Datei und Daten-Ledger-Ziele überschreiben
bash run_portfolio.sh --log /pfad/zum/audit.log --history /pfad/zum/ledger.csv
```

---

## Zeitgesteuerte Ausführung (Cron-Integration)

Um kontinuierliche Portfolio-Überwachung (beispielsweise zweimal täglich automatische Snapshots) zu implementieren:

1.  Öffnen Sie den Crontab-Editor:
     ```bash
     crontab -e
     ```
2.  Fügen Sie einen Planungseintrag ein (passen Sie Pfade für Ihr System an):
     ```bash
     0 */12 * * * /bin/bash /pfad/zu/Loris_code/run_portfolio.sh
     ```

---

## KI-Assistent-Bestätigung

Entwicklung, Tests und Optimierung dieser Lösung erfolgten in Zusammenarbeit mit KI-gestützten Tools. Weitere Details zur KI-Nutzung finden Sie in `KI_VERWENDUNG.md`.

*   **Implementierung & Verfeinerung:** Grundlegende Architektur, Steuerungsflusslogik und Datentransformations-Pipelines wurden kollaborativ entwickelt.
*   **Qualitätssicherung:** Datenquellen-Validierung, JSON-Parsing-Robustheit und Performance-Profiling wurden mittels umfassender Tests und Diagnose-Tools verifiziert.
