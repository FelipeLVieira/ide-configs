# Shitcoin Bot - Project Instructions

## Project Overview
Polymarket trading bot that copies trades from successful whale wallets using Kelly Criterion position sizing. Runs through VPN to bypass geo-restrictions.

## Tech Stack
- **Language**: Python 3.14+ with uv
- **APIs**: Polymarket API, Polygon blockchain
- **VPN**: NordVPN (SOCKS5 proxy)
- **Research**: Grok (x.com/i/grok) for market intelligence

## Architecture
- Copy trading from verified whale wallets
- Kelly Criterion position sizing (25% fractional)
- Automated position sync and tracking
- VPN proxy for geo-restriction bypass

## Key Files
- `src/run_bots.py` - Main entry point
- `src/services/whale_tracker.py` - Whale wallet definitions
- `src/strategies/copy_trading.py` - Kelly Criterion sizing
- `src/services/position_sync.py` - Position fetching
- `run_with_vpn.sh` - VPN proxy wrapper

## Personas
- **Trading Strategist**: Kelly sizing, risk management, whale analysis
- **Python Developer**: Bot logic, API integration, error handling
- **Market Analyst**: Crypto/politics/sports market research

## Key Principles
- VPN REQUIRED for trading (US IPs blocked)
- Use Grok for market research (saves Claude credits)
- Conservative Kelly (25% fractional)
- Verify whale win rates before copying
- Monitor for geo-block errors

## Risk Management
- Copy trading: 25% Kelly fraction
- Politics: 1.0x multiplier
- Sports: 0.7x multiplier
- Crypto: 0.5x multiplier (high variance)

## Key Commands
```bash
# Start with VPN
nohup ./run_with_vpn.sh > nohup.out 2>&1 &

# Check status
ps aux | grep run_bots

# View logs
tail -100 nohup.out | strings

# Check positions
uv run python -c "from src.services.position_sync import PositionSyncService; ..."

# Restart
pkill -f "python.*src.run_bots" && nohup ./run_with_vpn.sh > nohup.out 2>&1 &
```

## Port Assignment
- 5000-5099: Reserved for shitcoin-bot web interfaces (if needed)
