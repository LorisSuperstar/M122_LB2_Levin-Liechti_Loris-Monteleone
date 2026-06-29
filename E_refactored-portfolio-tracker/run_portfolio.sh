#!/bin/bash
# ==============================================================================
# Portfolio Asset Monitoring and Valuation Orchestration System
# M122 LB2 - Specification E
# 
# Developed with machine learning-assisted code generation and validation.
# ==============================================================================

SCRIPT_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PORTFOLIO_SETTINGS="$SCRIPT_LOCATION/portfolio.cfg"
AUDIT_LOG=""
RECORDS_LEDGER=""
CACHE_ARCHIVE="$SCRIPT_LOCATION/source_data.zip"
NOTIFICATION_REPORT="$SCRIPT_LOCATION/report.mail"

show_documentation() {
    echo "Usage: $0 [parameters]"
    echo "Parameters:"
    echo "  -c, --config <path>     Alternate configuration file location"
    echo "  -l, --log <path>        Alternate audit log file location"
    echo "  -s, --history <path>    Alternate records ledger CSV path"
    echo "  -h, --help              Display this documentation"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            PORTFOLIO_SETTINGS="$2"
            shift 2
            ;;
        -l|--log)
            AUDIT_LOG="$2"
            shift 2
            ;;
        -s|--history)
            RECORDS_LEDGER="$2"
            shift 2
            ;;
        -h|--help)
            show_documentation
            ;;
        *)
            echo "Unrecognized parameter: $1" >&2
            show_documentation
            ;;
    esac
done

if [ -f "$PORTFOLIO_SETTINGS" ]; then
    source "$PORTFOLIO_SETTINGS"
else
    echo "Error: Settings file unavailable at $PORTFOLIO_SETTINGS" >&2
    exit 1
fi

AUDIT_LOG="${AUDIT_LOG:-$SCRIPT_LOCATION/portfolio.log}"
RECORDS_LEDGER="${RECORDS_LEDGER:-$SCRIPT_LOCATION/portfolio_records.csv}"

record_event() {
    local event_category="$1"
    local event_details="$2"
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$event_category] $event_details" >> "$AUDIT_LOG"
}

record_event "INIT" "Portfolio monitoring session commencing."

# Acquire Bitcoin valuation
record_event "FETCH" "Retrieving Bitcoin market data from Coinbase..."
CRYPTO_MARKET=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
if [ $? -ne 0 ] || [ -z "$CRYPTO_MARKET" ]; then
    record_event "FAIL" "Unable to retrieve cryptocurrency pricing."
    echo "Error: Cryptocurrency data retrieval failed." >&2
    exit 1
fi

# Acquire foreign currency exchange rates
record_event "FETCH" "Retrieving currency exchange data from Coinbase..."
FIAT_MARKET=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/USD-CHF/spot")
if [ $? -ne 0 ] || [ -z "$FIAT_MARKET" ]; then
    record_event "FAIL" "Unable to retrieve exchange rate data."
    echo "Error: Exchange rate retrieval failed." >&2
    exit 1
fi

# Acquire equity market valuation
record_event "FETCH" "Retrieving equity pricing from Yahoo Finance..."
EQUITY_MARKET=$(curl -s -H "User-Agent: Mozilla/5.0" --connect-timeout 10 --max-time 15 "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
if [ $? -ne 0 ] || [ -z "$EQUITY_MARKET" ]; then
    record_event "FAIL" "Unable to retrieve security pricing."
    echo "Error: Equity data retrieval failed." >&2
    exit 1
fi

# Compress and persist API payloads using Python (cross-platform)
TEMP_WORKSPACE=$(mktemp -d)
echo "$CRYPTO_MARKET" > "$TEMP_WORKSPACE/crypto.json"
echo "$FIAT_MARKET" > "$TEMP_WORKSPACE/fiat.json"
echo "$EQUITY_MARKET" > "$TEMP_WORKSPACE/equity.json"
python3 -c "import zipfile; z = zipfile.ZipFile('$CACHE_ARCHIVE', 'w'); z.write('$TEMP_WORKSPACE/crypto.json', 'crypto.json'); z.write('$TEMP_WORKSPACE/fiat.json', 'fiat.json'); z.write('$TEMP_WORKSPACE/equity.json', 'equity.json'); z.close()"
rm -rf "$TEMP_WORKSPACE"
record_event "STORE" "API responses archived to $CACHE_ARCHIVE"

# Export to environment for Python computation
export CRYPTO_MARKET FIAT_MARKET EQUITY_MARKET
export EQUITY_UNITS EQUITY_ORIG_CHF FIAT_UNITS FIAT_ORIG_CHF CRYPTO_UNITS CRYPTO_ORIG_CHF

# Perform numerical calculations via Python (JSON parsing, arithmetic precision)
COMPUTATION_OUTPUT=$(python3 -c "
import os, sys, json
try:
    crypto = json.loads(os.environ['CRYPTO_MARKET'])
    fiat = json.loads(os.environ['FIAT_MARKET'])
    equity = json.loads(os.environ['EQUITY_MARKET'])

    crypto_rate = float(crypto['data']['amount'])
    fiat_rate = float(fiat['data']['amount'])

    metadata = equity['chart']['result'][0]['meta']
    equity_rate = metadata.get('regularMarketPrice')
    if equity_rate is None:
        equity_rate = equity['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    equity_rate = float(equity_rate)

    eq_qty = float(os.environ['EQUITY_UNITS'])
    fi_qty = float(os.environ['FIAT_UNITS'])
    cr_qty = float(os.environ['CRYPTO_UNITS'])

    eq_orig = float(os.environ['EQUITY_ORIG_CHF'])
    fi_orig = float(os.environ['FIAT_ORIG_CHF'])
    cr_orig = float(os.environ['CRYPTO_ORIG_CHF'])

    eq_val = eq_qty * equity_rate
    fi_val = fi_qty * fiat_rate
    cr_val = cr_qty * crypto_rate

    portfolio_current = eq_val + fi_val + cr_val
    portfolio_basis = eq_orig + fi_orig + cr_orig
    return_value = portfolio_current - portfolio_basis
    return_pct = (return_value / portfolio_basis) * 100 if portfolio_basis != 0 else 0.0

    print(f'{crypto_rate:.2f} {fiat_rate:.4f} {equity_rate:.2f} {eq_val:.2f} {fi_val:.2f} {cr_val:.2f} {portfolio_current:.2f} {portfolio_basis:.2f} {return_value:.2f} {return_pct:.2f}')
except Exception as e:
    print('ERROR:', e, file=sys.stderr)
    sys.exit(1)
" 2>>"$AUDIT_LOG")

if [ $? -ne 0 ] || [ -z "$COMPUTATION_OUTPUT" ]; then
    record_event "FAIL" "Calculation or data parsing failure."
    echo "Error: Computation failure. Review $AUDIT_LOG for diagnostics." >&2
    exit 1
fi

# Unpack computed metrics into variables
read -r crypto_rate fiat_rate equity_rate eq_val fi_val cr_val portfolio_current portfolio_basis return_value return_pct <<< "$COMPUTATION_OUTPUT"

record_event "SUCCESS" "Valuation computed. Portfolio: $portfolio_current CHF, Performance: $return_value CHF ($return_pct%)"

# Append valuations to historical ledger
if [ ! -f "$RECORDS_LEDGER" ]; then
    echo "Date,Time,BTC_Rate_CHF,USD_Rate_CHF,NOVN_Rate_CHF,Equity_Val_CHF,Fiat_Val_CHF,Crypto_Val_CHF,Portfolio_Current_CHF,Portfolio_Basis_CHF,Return_CHF,Return_Pct" > "$RECORDS_LEDGER"
fi
SNAPSHOT_DATE=$(date +"%Y-%m-%d")
SNAPSHOT_TIME=$(date +"%H:%M:%S")
echo "$SNAPSHOT_DATE,$SNAPSHOT_TIME,$crypto_rate,$fiat_rate,$equity_rate,$eq_val,$fi_val,$cr_val,$portfolio_current,$portfolio_basis,$return_value,$return_pct" >> "$RECORDS_LEDGER"

# Establish display formatting
if [[ "$return_value" == -* ]]; then
    PREFIX=""
else
    PREFIX="+"
fi

# Generate administrative notification
cat <<EOF > "$NOTIFICATION_REPORT"
To: admin@company.com
Subject: Portfolio Valuation Summary ($SNAPSHOT_DATE $SNAPSHOT_TIME)

Asset Portfolio Assessment:
- Aggregate Market Value: $portfolio_current CHF
- Total Cost Basis: $portfolio_basis CHF
- Net Return: $PREFIX$return_value CHF ($PREFIX$return_pct%)

Asset Composition:
- Novartis Equity (10 Shares): $eq_val CHF (Current Rate: $equity_rate CHF)
- USD Reserves (3000 USD): $fi_val CHF (Current Rate: $fiat_rate CHF)
- Bitcoin Holdings (0.1 BTC): $cr_val CHF (Current Rate: $crypto_rate CHF)

Data persistence and logging completed.
EOF
record_event "NOTIFY" "Administrative notification generated in $NOTIFICATION_REPORT"

# Generate formatted terminal output
echo "=================================================="
echo "PORTFOLIO VALUATION SNAPSHOT ($SNAPSHOT_DATE $SNAPSHOT_TIME)"
echo "=================================================="
printf "%-15s | %-9s | %-13s | %-12s\n" "Asset Category" "Quantity" "Rate (CHF)" "Position (CHF)"
echo "----------------+-----------+---------------+------------"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Novartis Equity" "$EQUITY_UNITS" "$equity_rate" "$eq_val"
printf "%-15s | %-9g | %-13.4f | %-12.2f\n" "USD Reserves" "$FIAT_UNITS" "$fiat_rate" "$fi_val"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Bitcoin Digital" "$CRYPTO_UNITS" "$crypto_rate" "$cr_val"
echo "----------------+-----------+---------------+------------"
printf "Current Market Value: %22.2f CHF\n" "$portfolio_current"
printf "Original Cost Basis:  %22.2f CHF\n" "$portfolio_basis"
printf "Net Gain/Loss:        %22.2f CHF (%s%.2f%%)\n" "$return_value" "$PREFIX" "$return_pct"
echo "=================================================="
