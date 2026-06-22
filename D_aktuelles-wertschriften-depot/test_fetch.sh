#!/bin/bash
# ==============================================================================
# Testskript fuer die Kursdaten-APIs (BTC, USD, NOVN)
# M122 LB2 - Aufgabe D (Verifikation)
# 
# HINWEIS: Dieses Skript wurde mit Unterstuetzung des KI-Tutors
# (Google DeepMind Antigravity) generiert, getestet und verifiziert.
# ==============================================================================

# Fetch BTC-CHF
BTC_RAW=$(curl -s "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
BTC_PRICE=$(echo "$BTC_RAW" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Fetch USD-CHF
USD_RAW=$(curl -s "https://api.coinbase.com/v2/prices/USD-CHF/spot")
USD_PRICE=$(echo "$USD_RAW" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Fetch NOVN.SW (Novartis on SIX)
NOVN_RAW=$(curl -s -H "User-Agent: Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
NOVN_PRICE=$(echo "$NOVN_RAW" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    meta = data['chart']['result'][0]['meta']
    # If regularMarketPrice is missing, try chart.result[0].indicators.quote[0].close[-1]
    price = meta.get('regularMarketPrice')
    if price is None:
        price = data['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    print(price)
except Exception as e:
    print('Error:', e)
")

echo "BTC/CHF: $BTC_PRICE"
echo "USD/CHF: $USD_PRICE"
echo "NOVN/CHF: $NOVN_PRICE"
