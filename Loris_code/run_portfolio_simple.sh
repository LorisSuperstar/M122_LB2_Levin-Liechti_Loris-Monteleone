#!/bin/bash

# Beginner-friendly portfolio snapshot script
# Requirements: curl, jq, awk
# This script uses simple defaults. You can create a portfolio.cfg to override any variable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG_FILE="$SCRIPT_DIR/portfolio.cfg"
LEDGER="$SCRIPT_DIR/portfolio_records_simple.csv"

# Defaults (simple values for demo)
EQUITY_UNITS=10
EQUITY_ORIG_CHF=1000
FIAT_UNITS=3000
FIAT_ORIG_CHF=3000
CRYPTO_UNITS=0.1
CRYPTO_ORIG_CHF=500

# If user provided a cfg file, source it (it should set the same variables)
if [ -f "$CFG_FILE" ]; then
  # cfg should be safe: KEY=VALUE lines
  source "$CFG_FILE"
fi

# Check tools
for tool in curl jq awk; do
  if ! command -v $tool >/dev/null 2>&1; then
    echo "Please install $tool to run this script." >&2
    exit 1
  fi
done

# Fetch rates
CRYPTO_JSON=$(curl -s "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
BTC_RATE=$(echo "$CRYPTO_JSON" | jq -r '.data.amount')

FIAT_JSON=$(curl -s "https://api.coinbase.com/v2/prices/USD-CHF/spot")
USD_RATE=$(echo "$FIAT_JSON" | jq -r '.data.amount')

EQUITY_JSON=$(curl -s -H "User-Agent: Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
NOVN_RATE=$(echo "$EQUITY_JSON" | jq -r '.chart.result[0].meta.regularMarketPrice // .chart.result[0].indicators.quote[0].close[-1]')

# Simple arithmetic using awk (handles floating point)
read EQ_VAL FI_VAL CR_VAL PORTF_CUR PORTF_BASIS RETURN CHF_PCT <<< $(awk -v equ="$EQUITY_UNITS" -v eqr="$NOVN_RATE" -v fiu="$FIAT_UNITS" -v fir="$USD_RATE" -v cru="$CRYPTO_UNITS" -v crr="$BTC_RATE" -v eqo="$EQUITY_ORIG_CHF" -v fio="$FIAT_ORIG_CHF" -v cro="$CRYPTO_ORIG_CHF" '
BEGIN {
  eq_val = equ * eqr;
  fi_val = fiu * fir;
  cr_val = cru * crr;
  port_cur = eq_val + fi_val + cr_val;
  port_basis = eqo + fio + cro;
  ret = port_cur - port_basis;
  ret_pct = (port_basis==0)?0:ret/port_basis*100;
  printf("%.2f %.2f %.2f %.2f %.2f %.2f", eq_val, fi_val, cr_val, port_cur, port_basis, ret);
}')

# Write header if ledger not present
if [ ! -f "$LEDGER" ]; then
  echo "Date,Time,BTC_Rate_CHF,USD_Rate_CHF,NOVN_Rate_CHF,Equity_Val_CHF,Fiat_Val_CHF,Crypto_Val_CHF,Portfolio_Current_CHF,Portfolio_Basis_CHF,Return_CHF" > "$LEDGER"
fi

DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
echo "$DATE,$TIME,$BTC_RATE,$USD_RATE,$NOVN_RATE,$EQ_VAL,$FI_VAL,$CR_VAL,$PORTF_CUR,$PORTF_BASIS,$RETURN" >> "$LEDGER"

# Simple terminal summary
printf "Portfolio snapshot (%s %s)\n" "$DATE" "$TIME"
printf "  Novartis: %s units @ %s CHF => %.2f CHF\n" "$EQUITY_UNITS" "$NOVN_RATE" "$EQ_VAL"
printf "  USD:      %s units @ %s CHF => %.2f CHF\n" "$FIAT_UNITS" "$USD_RATE" "$FI_VAL"
printf "  Bitcoin:  %s units @ %s CHF => %.2f CHF\n" "$CRYPTO_UNITS" "$BTC_RATE" "$CR_VAL"
printf "  Current Market Value: %.2f CHF\n" "$PORTF_CUR"
printf "  Original Cost Basis:  %.2f CHF\n" "$PORTF_BASIS"
printf "  Net Return:            %.2f CHF\n" "$RETURN"

exit 0
