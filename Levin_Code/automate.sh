#!/bin/bash
# ==============================================================================
# Zentrales Automationsscript fuer das Aktuelle Wertschriften-Depot
# M122 LB2 - Aufgabe D
# 
# HINWEIS: Dieses Skript wurde mit Unterstuetzung des KI-Tutors
# (Google DeepMind Antigravity) generiert, getestet und verifiziert.
# ==============================================================================

# Setup script directory to allow running from anywhere (e.g. cron)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default file paths
CONFIG_FILE="$SCRIPT_DIR/depot.cfg"
LOG_FILE=""
HISTORY_FILE=""
ZIP_FILE="$SCRIPT_DIR/data.zip"
MAIL_FILE="$SCRIPT_DIR/info.mail"

# Usage help menu
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c, --config <file>     Path to custom configuration file"
    echo "  -l, --log <file>        Path to custom log file"
    echo "  -s, --history <file>    Path to custom history CSV file"
    echo "  -h, --help              Show this help message"
    exit 0
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -s|--history)
            HISTORY_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            ;;
    esac
done

# Load configuration file
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Resolve log and history file destinations
LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/depot.log}"
HISTORY_FILE="${HISTORY_FILE:-$SCRIPT_DIR/depot_history.csv}"

# Helper function to append to log file
log_msg() {
    local level="$1"
    local msg="$2"
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$level] $msg" >> "$LOG_FILE"
}

log_msg "INFO" "Starting Wertschriften-Depot run."

# Fetch Bitcoin rate
log_msg "INFO" "Fetching Bitcoin rate from Coinbase API..."
BTC_RAW=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
if [ $? -ne 0 ] || [ -z "$BTC_RAW" ]; then
    log_msg "ERROR" "Failed to fetch Bitcoin rate."
    echo "Error: Failed to fetch Bitcoin rate." >&2
    exit 1
fi

# Fetch USD rate
log_msg "INFO" "Fetching USD rate from Coinbase API..."
USD_RAW=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/USD-CHF/spot")
if [ $? -ne 0 ] || [ -z "$USD_RAW" ]; then
    log_msg "ERROR" "Failed to fetch USD rate."
    echo "Error: Failed to fetch USD rate." >&2
    exit 1
fi

# Fetch Novartis rate
log_msg "INFO" "Fetching Novartis rate from Yahoo Finance..."
NOVN_RAW=$(curl -s -H "User-Agent: Mozilla/5.0" --connect-timeout 10 --max-time 15 "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
if [ $? -ne 0 ] || [ -z "$NOVN_RAW" ]; then
    log_msg "ERROR" "Failed to fetch Novartis rate."
    echo "Error: Failed to fetch Novartis rate." >&2
    exit 1
fi

# Pack raw files to data.zip using python zipfile module (since zip package is not installed)
TEMP_DIR=$(mktemp -d)
echo "$BTC_RAW" > "$TEMP_DIR/btc.raw"
echo "$USD_RAW" > "$TEMP_DIR/usd.raw"
echo "$NOVN_RAW" > "$TEMP_DIR/novn.raw"
python3 -c "import zipfile; z = zipfile.ZipFile('$ZIP_FILE', 'w'); z.write('$TEMP_DIR/btc.raw', 'btc.raw'); z.write('$TEMP_DIR/usd.raw', 'usd.raw'); z.write('$TEMP_DIR/novn.raw', 'novn.raw'); z.close()"
rm -rf "$TEMP_DIR"
log_msg "INFO" "Raw data zipped to $ZIP_FILE"

# Export values to OS environment for safe access inside Python block
export BTC_RAW USD_RAW NOVN_RAW
export STOCK_QTY STOCK_HIST_CHF USD_QTY USD_HIST_CHF BTC_QTY BTC_HIST_CHF

# Run calculations in Python to handle JSON parsing and floating-point arithmetic accurately
CALC_RESULTS=$(python3 -c "
import os, sys, json
try:
    btc = json.loads(os.environ['BTC_RAW'])
    usd = json.loads(os.environ['USD_RAW'])
    novn = json.loads(os.environ['NOVN_RAW'])

    btc_p = float(btc['data']['amount'])
    usd_p = float(usd['data']['amount'])

    meta = novn['chart']['result'][0]['meta']
    novn_p = meta.get('regularMarketPrice')
    if novn_p is None:
        novn_p = novn['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    novn_p = float(novn_p)

    stock_q = float(os.environ['STOCK_QTY'])
    usd_q = float(os.environ['USD_QTY'])
    btc_q = float(os.environ['BTC_QTY'])

    stock_h = float(os.environ['STOCK_HIST_CHF'])
    usd_h = float(os.environ['USD_HIST_CHF'])
    btc_h = float(os.environ['BTC_HIST_CHF'])

    stock_v = stock_q * novn_p
    usd_v = usd_q * usd_p
    btc_v = btc_q * btc_p

    curr_total = stock_v + usd_v + btc_v
    hist_total = stock_h + usd_h + btc_h
    p_l = curr_total - hist_total
    pct = (p_l / hist_total) * 100 if hist_total != 0 else 0.0

    print(f'{btc_p:.2f} {usd_p:.4f} {novn_p:.2f} {stock_v:.2f} {usd_v:.2f} {btc_v:.2f} {curr_total:.2f} {hist_total:.2f} {p_l:.2f} {pct:.2f}')
except Exception as e:
    print('ERROR:', e, file=sys.stderr)
    sys.exit(1)
" 2>>"$LOG_FILE")

if [ $? -ne 0 ] || [ -z "$CALC_RESULTS" ]; then
    log_msg "ERROR" "Failed to parse API data or run calculations."
    echo "Error: Calculation failed. See $LOG_FILE for details." >&2
    exit 1
fi

# Read calculated values into Bash variables
read -r btc_price usd_price novn_price stock_val usd_val btc_val curr_total hist_total profit_loss pct_change <<< "$CALC_RESULTS"

log_msg "INFO" "Calculation successful. Total: $curr_total CHF, Profit: $profit_loss CHF ($pct_change%)"

# Write history to CSV (creates file and header if not present)
if [ ! -f "$HISTORY_FILE" ]; then
    echo "Date,Time,BTC_Price_CHF,USD_Price_CHF,NOVN_Price_CHF,STOCK_Val_CHF,USD_Val_CHF,BTC_Val_CHF,Total_Current_Val_CHF,Total_Hist_Val_CHF,Profit_Loss_CHF,Pct_Change" > "$HISTORY_FILE"
fi
DATE_STR=$(date +"%Y-%m-%d")
TIME_STR=$(date +"%H:%M:%S")
echo "$DATE_STR,$TIME_STR,$btc_price,$usd_price,$novn_price,$stock_val,$usd_val,$btc_val,$curr_total,$hist_total,$profit_loss,$pct_change" >> "$HISTORY_FILE"

# Determine prefix sign for display
if [[ "$profit_loss" == -* ]]; then
    SIGN=""
else
    SIGN="+"
fi

# Write mock email report to admin (info.mail)
cat <<EOF > "$MAIL_FILE"
To: admin@company.com
Subject: Depot Status Update ($DATE_STR $TIME_STR)

Depot Status Report:
- Current Value: $curr_total CHF
- Historical Cost: $hist_total CHF
- Net Performance: $SIGN$profit_loss CHF ($SIGN$pct_change%)

Breakdown:
- Novartis Stock (10 Shares): $stock_val CHF (Price: $novn_price CHF)
- USD Cash (3000 USD): $usd_val CHF (Price: $usd_price CHF)
- Bitcoin (0.1 BTC): $btc_val CHF (Price: $btc_price CHF)

Log file and CSV history updated.
EOF
log_msg "INFO" "Mock email updated in $MAIL_FILE"

# Print beautiful terminal summary
echo "=================================================="
echo "WERT-DEPOT TRACKER SUMMARY ($DATE_STR $TIME_STR)"
echo "=================================================="
printf "%-15s | %-9s | %-13s | %-12s\n" "Asset Class" "Qty" "Price (CHF)" "Value (CHF)"
echo "----------------+-----------+---------------+------------"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Novartis Stock" "$STOCK_QTY" "$novn_price" "$stock_val"
printf "%-15s | %-9g | %-13.4f | %-12.2f\n" "USD Cash" "$USD_QTY" "$usd_price" "$usd_val"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Bitcoin Crypto" "$BTC_QTY" "$btc_price" "$btc_val"
echo "----------------+-----------+---------------+------------"
printf "Current Portfolio Value:  %12.2f CHF\n" "$curr_total"
printf "Historical Purchase Cost: %12.2f CHF\n" "$hist_total"
printf "Net Profit/Loss:         %12.2f CHF (%s%.2f%%)\n" "$profit_loss" "$SIGN" "$pct_change"
echo "=================================================="
