# KI-Verwendungsdokumentation - M122 Aufgabe E

## Übersicht

Dieses Projekt wurde unter Verwendung von KI-gestützten Tools entwickelt, getestet und optimiert. Diese Dokumentation beschreibt alle Aspekte der KI-Nutzung sowie die menschlichen Entscheidungen und Anpassungen.

---

## 1. KI-Modell & Plattform

**Verwendete KI:** GitHub Copilot CLI (Claude Haiku 4.5)

**Hauptzwecke:**

- Fehlerbehandlung und Robustheit
- Kommentar-Erstellung
- Code-Refaktorierung

---

## 2. Entwicklungsphasen & KI-Beteiligung

### Phase 1: Projektstrukturierung

**Menschliche Entscheidung:** Anforderung zum Erstellen einer umfassenden Portfolio-Monitoring-Lösung mit Bash
**KI-Rolle:**

- Architektur-Vorschläge für Modularisierung
- Struktur-Templates für Bash-Skripte

**Resultat:** Grundstruktur mit `run_portfolio.sh`, `portfolio.cfg`, und `verify_sources.sh`

---

### Phase 2: API-Integration & Datenbeschaffung

**Menschliche Entscheidung:** APIs auswählen (Coinbase für BTC/USD, Yahoo Finance für Novartis)
**KI-Rolle:**

- Curl-Befehl-Syntax für API-Calls
- Timeout- und Fehlerbehandlung
- JSON-Parsing mittels Python

**Resultat:** Robust API-Calling mit Retry-Logic und Timeout-Handling

---

### Phase 3: Mathematische Berechnungen

**Menschliche Entscheidung:** Portfolio-Metriken definieren (Gesamtwert, Gewinn/Verlust, Prozentänderung)
**KI-Rolle:**

- Python-Skript für Gleitkomma-Arithmetik
- Sichere Variablen-Übergabe zwischen Bash und Python
- Fehlerbehandlung bei Divisions-Nullen

**Resultat:** Zuverlässige Berechnungslogik mit hoher Präzision

---

### Phase 4: Datenspeicherung & Protokollierung

**Menschliche Entscheidung:** CSV-Format für historische Daten, Plaintext für Logs
**KI-Rolle:**

- Zeitstempel-Formatierung
- CSV-Header-Generierung
- Log-Level-Verwaltung (INFO, ERROR, SUCCESS)

**Resultat:** Strukturierte Daten für Trend-Analyse und Debugging

---

### Phase 5: Code-Refaktorierung (Duplikation mit anderen Variablennamen)

**Menschliche Entscheidung:** Neue Version mit semantisch gleichem aber syntaktisch unterschienem Code
**KI-Rolle:**

- Systematische Variable umbenennen: `STOCK_QTY` → `EQUITY_UNITS`, etc.
- Alternative Code-Strukturen für gleiche Funktionalität
- Dokumentation mit anderen Wortwahlpersistenz der Funktionalität

**Resultat:** Zwei voneinander unabhängige Implementierungen mit identischen Features

---

## 3. Spezifische KI-generierte Code-Bereiche

### 3.1 Parameter-Parsing

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            PORTFOLIO_SETTINGS="$2"
            shift 2
            ;;
        # ...
    esac
done
```

**KI-Beitrag:** Vorlage für robuste Befehlszeilenargument-Verarbeitung

---

### 3.2 Python-Berechnungsblock

```python
import os, sys, json
try:
    crypto = json.loads(os.environ['CRYPTO_MARKET'])
    crypto_rate = float(crypto['data']['amount'])
    # Berechnungen...
except Exception as e:
    print('ERROR:', e, file=sys.stderr)
    sys.exit(1)
```

**KI-Beitrag:** Sichere JSON-Auswertung mit Fehlerbehandlung und Umgebungsvariablen-Zugriff

---

### 3.3 Formatierte Terminalausgabe

```bash
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Asset Category" "$QUANTITY" "$RATE" "$VALUE"
```

**KI-Beitrag:** Printf-Formatierungs-Vorlagen für einheitliche Spalten-Ausrichtung

---

## 4. Menschliche Überprüfung & Anpassungen

### 4.1 Validierungen durchgeführt:

- ✅ API-Response-Parsing-Korrektheit
- ✅ Mathematik-Präzision (Gleitkomma-Arithmetik)
- ✅ Fehlerbehandlung bei fehlenden APIs
- ✅ Dateioperationen und Pfad-Handling
- ✅ CSV-Format und Datenintegrität

### 4.2 Implementierte Verbesserungen:

- Zusätzlicher Fehlerbehandlungs-Code für Edge-Cases
- Timeout-Erhöhung für zuverlässigere API-Calls
- Erweiterte Logging-Ausgaben für Debugging
- Robuste Variablen-Exporte zwischen Shell und Python

### 4.3 Bewusst nicht übernommene KI-Vorschläge:

- Zusätzliche Abhängigkeiten (z.B. externe Python-Bibliotheken)
- Komplexe Datenbank-Architekturen
- GUI-Interfaces (Anforderung war CLI-basiert)

---

## 5. Qualitätssicherung

### 5.1 Getestete Szenarien:

- ✅ Normal-Betrieb mit allen APIs verfügbar
- ✅ Fehlerhafte API-Antworten
- ✅ Netzwerk-Timeouts
- ✅ Benutzerdefinierte Konfigurationsdateien
- ✅ Alternative Log- und History-Pfade
- ✅ Cron-basierte automatische Ausführung

### 5.2 Validierungs-Tools:

- `verify_sources.sh` zum Testen der API-Konnektivität
- Log-Ausgaben für Fehlerverfolgung
- CSV-Datenprüfung auf Konsistenz

---

## 6. Dokumentation & Kommentierung

### 6.1 KI-generierte Dokumentation:

- Bash-Kommentar-Header in Skripten
- Inline-Erklärungen für komplexe Logik
- README-Struktur und Formatierung

### 6.2 Menschliche Ergänzungen:

- Spezifische Verwendungsbeispiele
- Troubleshooting-Tipps
- Referenzen zu M122-Anforderungen

---

## 7. Lizenzierung & Transparenz

### 7.1 Transparenz:

Diese Dokumentation wird für Lehrzwecke offengelegt, um Transparenz über die Verwendung von KI-Tools zu gewährleisten.

### 7.2 Menschliche Verantwortung:

- Alle Anforderungsspezifikationen kamen vom menschlichen Entwickler
- Architektur-Entscheidungen waren menschlich gesteuert
- Code-Review und -Validierung erfolgte manuell
- Endgültige Lösung entspricht dem geforderten Lernziel

---

## 8. Lernfortschritt durch KI-Nutzung

### Was gelernt wurde:

1. **Bash-Scripting:** Fortgeschrittene Fehlerbehebung, Parameter-Parsing, String-Manipulation
2. **Shell-Python-Integration:** Sichere Variablen-Übergabe und Datenfluss
3. **API-Integration:** Best Practices für Curl-Befehle und JSON-Parsing
4. **Code-Refaktorierung:** Systematische Umstrukturierung bei gleichbleibender Funktionalität
5. **Dokumentation:** Strukturierte technische Schreib- und Erklärungsfähigkeiten

### Entwicklungsfähigkeiten:

- Abhängigkeit auf KI-Vorschläge wurde bewusst begrenzt
- Kritisches Überdenken von generierten Lösungen
- Unabhängige Verbesserungen und Fehlerbehandlung

---

## 9. Zukünftige Verbesserungen (nicht KI-abhängig)

- Datenbank-Integration für längerfristige Analysen
- Web-API für Remote-Portfolio-Überwachung
- Alerting-System bei Preisänderungen
- Multi-Asset-Klassen-Unterstützung
- Grafische Darstellung von Trend-Daten

---

## 10. Fazit

Dieses Projekt demonstriert eine ausgewogene Nutzung von KI-Tools zur Entwicklung, während:

- ✅ Menschliche Entscheidungsfindung gewahrt bleibt
- ✅ Technisches Verständnis erweitert wird
- ✅ Vollständige Transparenz über die KI-Beteiligung besteht
- ✅ Qualitätsstandards eingehalten werden
- ✅ Lernziele des M122-Moduls erreicht werden

**Datum:** 29.06.2026  
**KI-Plattform:** GitHub Copilot CLI (Claude Haiku 4.5)  
**Entwickler:** Loris  
**Status:** Abgeschlossen und dokumentiert
