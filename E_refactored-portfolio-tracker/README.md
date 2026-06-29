# M122 - Task E: Live Asset Portfolio Monitor

This solution implements a comprehensive asset monitoring and valuation system using Bash automation. It periodically retrieves live market prices for multiple asset classes (Novartis equity holdings, USD reserves, and Bitcoin digital assets), integrates real-time exchange rate data through open API endpoints, computes portfolio valuations and performance metrics, and maintains persistent transaction records for trend analysis.

## Architecture & System Overview

The automation framework consists of several integrated modules designed according to M122 specifications:

*   **Primary Orchestration Module (`run_portfolio.sh`):** Orchestrates the entire workflow including data retrieval, computations, persistence, audit logging, compression, and notification generation.
*   **Environment Settings (`portfolio.cfg`):** Stores portfolio composition, initial acquisition valuations in CHF, and file reference paths.
*   **Execution Audit Trail (`portfolio.log`):** Records all operations, timestamps, and diagnostic information for troubleshooting and verification.
*   **Portfolio Ledger (`portfolio_records.csv`):** Maintains chronological transaction records and valuations in CSV format for historical analysis.
*   **API Response Cache (`source_data.zip`):** Archives raw JSON responses from external data sources for verification and audit purposes.
*   **System Report (`report.mail`):** Generates formatted summary reports simulating administrative notifications.
*   **Integration Test Suite (`verify_sources.sh`):** Validation and debugging utility for API connectivity and data parsing.

---

## Third-Party Data Sources (Public Access, No Authentication)

1.  **Cryptocurrency Market Rates (BTC/CHF):** `https://api.coinbase.com/v2/prices/BTC-CHF/spot`
2.  **Currency Exchange Rates (USD/CHF):** `https://api.coinbase.com/v2/prices/USD-CHF/spot`
3.  **Equity Securities Pricing (NOVN.SW, CHF):** Yahoo Finance REST API (`https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d`)

---

## Initial Setup & Customization

Asset composition is configured in the `portfolio.cfg` manifest:

```bash
# Novartis equity position and original cost basis
EQUITY_UNITS=10
EQUITY_ORIG_CHF=850.00

# Fiat currency reserve and original cost basis
FIAT_UNITS=3000
FIAT_ORIG_CHF=2750.00

# Digital currency holding and original cost basis
CRYPTO_UNITS=0.1
CRYPTO_ORIG_CHF=4500.00
```

---

## Runtime Options & Invocation

The automation can be executed interactively or scheduled. Supported command-line parameters:

```bash
# Display documentation
bash run_portfolio.sh --help

# Standard execution (loads portfolio.cfg from current directory)
bash run_portfolio.sh

# Specify alternate configuration source
bash run_portfolio.sh --config /alternate/path/custom.cfg

# Override log file and data ledger destinations
bash run_portfolio.sh --log /alternate/audit.log --history /alternate/ledger.csv
```

---

## Scheduled Execution (Cron Integration)

To implement continuous portfolio monitoring (for example, twice daily automated snapshots):

1.  Access the crontab editor:
     ```bash
     crontab -e
     ```
2.  Insert a schedule entry (adjust paths for your system):
     ```bash
     0 */12 * * * /bin/bash /path/to/E_refactored-portfolio-tracker/run_portfolio.sh
     ```

---

## AI Assistant Acknowledgment

Development, testing, and optimization of this solution involved collaboration with machine learning-assisted tools.
*   **Implementation & Refinement:** Fundamental architecture, control flow logic, and data transformation pipelines were collaboratively designed.
*   **Quality Assurance:** Data source validation, JSON parsing robustness, and performance profiling were verified through comprehensive testing and diagnostic tooling.
