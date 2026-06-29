#!/bin/bash
# ==============================================================================
# Data Source Connectivity and Parsing Verification Suite
# M122 LB2 - Specification E (Diagnostics & Testing)
# 
# Developed with machine learning-assisted code generation and validation.
# ==============================================================================

# Retrieve Bitcoin rate snapshot
CRYPTO_MARKET=$(curl -s "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
CRYPTO_RATE=$(echo "$CRYPTO_MARKET" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Retrieve USD exchange rate snapshot
FIAT_MARKET=$(curl -s "https://api.coinbase.com/v2/prices/USD-CHF/spot")
FIAT_RATE=$(echo "$FIAT_MARKET" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Retrieve Novartis equity rate snapshot
EQUITY_MARKET=$(curl -s -H "User-Agent: Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
EQUITY_RATE=$(echo "$EQUITY_MARKET" | python3 -c "
import sys, json
try:
    payload = json.load(sys.stdin)
    meta = payload['chart']['result'][0]['meta']
    rate = meta.get('regularMarketPrice')
    if rate is None:
        rate = payload['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    print(rate)
except Exception as e:
    print('Parsing Error:', e)
")

echo "Bitcoin Rate (CHF):     $CRYPTO_RATE"
echo "Exchange Rate (CHF):    $FIAT_RATE"
echo "Novartis Rate (CHF):    $EQUITY_RATE"
