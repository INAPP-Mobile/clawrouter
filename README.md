# ClawRouter — Agent-Native LLM Router

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/clawrouter)

The LLM router built for autonomous agents. Agents can't sign up for accounts, enter credit cards, or manage API keys. ClawRouter is the only LLM router that lets agents operate independently — wallet-based auth, x402 USDC micropayments, 71+ models, 5 free forever.

## Features

- **71+ Models** — Claude, GPT, Gemini, Grok, Kimi, DeepSeek, and more
- **Smart Routing** — 15-dimension weighted scorer picks the best model per request
- **5 Free Models** — No crypto, no signup, no API key required
- **x402 USDC Payments** — Pay-per-use via wallet transactions (Base EVM or Solana)
- **OpenAI-Compatible API** — Drop-in replacement at `/v1/chat/completions`
- **98% Cost Savings** — vs pinning Claude Opus 5 on `eco` mode
- **Local Proxy** — <1ms latency, zero external API calls for routing decisions

## How It Works

```
Request → Weighted Scorer → Tier → Best Model → Response
```

The scorer weighs 15 dimensions of each request (code presence, reasoning markers, token count, complexity, etc.) and routes to the optimal model across three tiers: ECO, AUTO, or PREMIUM.

## Deploy

One click deploys ClawRouter as a persistent proxy on Railway:

1. Click the **Deploy to Railway** button
2. Optionally set `BLOCKRUN_WALLET_KEY` to use your existing wallet
3. Deploy — Railway provides a public `*.up.railway.app` domain

## Usage

Once deployed, use ClawRouter as an OpenAI-compatible endpoint:

```bash
curl https://your-app.up.railway.app/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "auto", "messages": [{"role": "user", "content": "Hello"}]}'
```

### Model Selection

- `auto` — Smart routing (recommended)
- `eco` — Free models only
- `premium` — Best model regardless of cost
- Specific model ID — Pin to one model

### Authentication

ClawRouter uses wallet-based auth. On first run, it generates a BIP-39 mnemonic stored in the persistent volume. Back up your wallet key before terminating the service!

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Proxy server port (Railway injects this) |
| `BLOCKRUN_WALLET_KEY` | — | Ethereum private key (0x-prefixed). Auto-generated if unset. |
| `CLAWROUTER_SOLANA_RPC_URL` | `https://api.mainnet-beta.solana.com` | Solana RPC for USDC balance checks |
| `CLAWROUTER_DISABLED` | `false` | Disable smart routing (pass-through mode) |
| `CLAWROUTER_WORKER` | — | Set to `1` to earn USDC via health checks |
| `CLAWROUTER_DEBUG_HEADERS` | on | Set to `off` to suppress debug headers |
| `BLOCKRUN_WEB_SEARCH` | auto | Set to `off` to disable Exa web search |
| `CLAWROUTER_PAYMENT_CHAIN` | — | Override payment chain: `solana` or `base` |

## Persistent Storage

ClawRouter stores wallet keys and config in a persistent volume mounted at `/home/clawrouter/.openclaw/blockrun`. Your wallet survives deploys and restarts.

## License

MIT — [BlockRunAI/ClawRouter](https://github.com/BlockRunAI/ClawRouter)
