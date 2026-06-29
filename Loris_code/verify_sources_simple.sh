#!/bin/bash

# Simple script for beginners: fetch and show BTC, USD and NOVN (Novartis) rates
# Requires: curl, jq

if ! command -v curl >/dev/null 2>&1; then
  echo "Please install curl to run this script." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Please install jq (https://stedolan.github.io/jq/) to parse JSON." >&2
  exit 1
fi

# Get Bitcoin price (BTC-CHF)
CRYPTO_JSON=$(curl -s "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
BTC_RATE=$(echo "$CRYPTO_JSON" | jq -r '.data.amount')

# Get USD->CHF rate (USD-CHF)
FIAT_JSON=$(curl -s "https://api.coinbase.com/v2/prices/USD-CHF/spot")
USD_RATE=$(echo "$FIAT_JSON" | jq -r '.data.amount')

# Get Novartis (NOVN.SW) from Yahoo Finance
EQUITY_JSON=$(curl -s -H "User-Agent: Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
# Try meta.regularMarketPrice, otherwise fall back to latest close price
NOVN_RATE=$(echo "$EQUITY_JSON" | jq -r '.chart.result[0].meta.regularMarketPrice // .chart.result[0].indicators.quote[0].close[-1]')

# Show results (plain and readable)
echo "Bitcoin Rate (CHF):  $BTC_RATE"
echo "USD Rate (CHF):      $USD_RATE"
echo "Novartis Rate (CHF):  $NOVN_RATE"

# Exit cleanly
exit 0
