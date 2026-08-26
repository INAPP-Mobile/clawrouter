# ClawRouter — Agent-Native LLM Router

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/clawrouter)

The LLM router built for autonomous agents. Agents can't sign up for accounts, enter credit cards, or manage API keys. ClawRouter is the only LLM router that lets agents operate independently — wallet-based auth, x402 USDC micropayments, 71+ models, 5 free forever.

## Features

- **71+ Models** — Claude, GPT, Gemini, Grok, Kimi, DeepSeek, and more
- **Smart Routing** — 15-dimension weighted scorer picks the best model per request
- **5 Free Models** — No crypto, no signup, no API key required
- **x402 USDC Payments** — Pay-per-use via wallet transactions (Base EVM or Solana)
- **OpenAI-Compatible API** — Drop-in replacement at `/v1/chat/completions`
- **Local Proxy** — Routing decisions made in-process, zero external calls
- **Persistent Wallet** — Railway volume keeps your wallet across deploys

## How It Works

```
Request → Weighted Scorer → Tier → Best Model → Response
```

The scorer weighs 15 dimensions of each request (code presence, reasoning markers, token count, complexity, etc.) and routes to the optimal model across three tiers: ECO, AUTO, or PREMIUM.

## Prerequisites

- A Railway account
- Nothing else — ClawRouter generates its own wallet on first boot and serves free models with a zero balance

## One-Click Deploy

1. Click the **Deploy to Railway** button
2. Optionally set `BLOCKRUN_WALLET_KEY` to restore an existing funded wallet
3. Deploy — Railway provisions a public `*.up.railway.app` domain and a persistent volume

On first boot ClawRouter generates an EVM (Base) and a Solana wallet, prints both addresses in the deploy logs, and writes the key to the mounted volume. **Back up the key from the logs before you touch the service again.**

## Usage

Once deployed, use ClawRouter as an OpenAI-compatible endpoint:

```bash
curl https://your-app.up.railway.app/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "auto", "messages": [{"role": "user", "content": "Hello"}]}'
```

Health and discovery endpoints:

```bash
curl https://your-app.up.railway.app/health
curl https://your-app.up.railway.app/v1/models
```

### Model Selection

- `auto` — Smart routing (recommended)
- `eco` — Free models only
- `premium` — Best model regardless of cost
- Specific model ID — Pin to one model

### Authentication

ClawRouter uses wallet-based auth. On first run it generates a BIP-39 mnemonic stored in the persistent volume. Fund the printed Solana (or Base) address with USDC to unlock premium models; with a zero balance the free tier still works.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BLOCKRUN_WALLET_KEY` | — | Existing wallet private key (0x-prefixed hex). Auto-generated if unset. |
| `CLAWROUTER_PAYMENT_CHAIN` | `solana` | Settlement chain: `solana` or `base` |
| `CLAWROUTER_SOLANA_RPC_URL` | `https://api.mainnet-beta.solana.com` | Solana RPC for USDC balance checks |
| `CLAWROUTER_DISABLED` | `false` | Disable smart routing (pass-through mode) |
| `CLAWROUTER_WORKER` | `0` | Set to `1` to earn USDC via network health checks |
| `CLAWROUTER_DEBUG_HEADERS` | `on` | Set to `off` to suppress `x-clawrouter-*` headers |
| `BLOCKRUN_WEB_SEARCH` | `auto` | Set to `off` to disable the built-in web search tool |

`PORT` is injected by Railway; the container binds it automatically.

## Service Dependencies

None. ClawRouter is a single container with no database, cache, or queue. Model access is brokered over HTTPS by the BlockRun network using your wallet.

## Persistent Storage

A Railway volume is mounted at `/root/.openclaw`. Wallet key, mnemonic, and routing config live there, so your wallet survives redeploys and restarts. Detaching the volume means a new wallet on the next boot — and loss of any funds on the old one.

## Local Development

```bash
npm i -g openclaw @blockrun/clawrouter
clawrouter --port 8080
```

Then hit `http://127.0.0.1:8080/v1/models` to confirm it is serving.

## Troubleshooting

### Healthcheck fails right after deploy
ClawRouter binds loopback internally; the container forwards the public port to it. Confirm the deploy logs show `Forwarding 0.0.0.0:$PORT` before assuming a crash.

### A new wallet appears after every deploy
The volume is missing or was remounted at a different path. Re-attach a volume at `/root/.openclaw`.

### Premium models return payment errors
The wallet balance is zero. Fund the Solana or Base address printed in the deploy logs with USDC, or use `eco` to stay on free models.

## Resource Requirements

Minimal — a single Node process. Railway's smallest instance is sufficient for personal and small-team use.

## License

MIT — [BlockRunAI/ClawRouter](https://github.com/BlockRunAI/ClawRouter)

# Deploy and Host

Deploy this template on Railway with one click. Railway provides compute, TLS at the edge, and a public URL. The service restarts automatically on failures.

## About Hosting

This template runs as a single container. There is no external database: wallet state and configuration are stored in a Railway persistent volume mounted at `/root/.openclaw`. Model traffic is settled with USDC micropayments from the container's own wallet, so no API keys are provisioned or stored.

## Why Deploy

- **One-click deploy** — No API keys, no signup, no configuration
- **Zero external dependencies** — Single container, no database needed
- **Automatic HTTPS** — Railway provisions TLS certificates automatically
- **Self-healing** — Automatic restarts on failure
- **Persistent wallet** — Railway volume keeps your key across deploys

## Common Use Cases

- OpenAI-compatible endpoint for autonomous agents that cannot hold API keys
- Cost-controlled model routing across 71+ models from a single URL
- Free-tier LLM access for prototypes and side projects
- Pay-per-call inference settled in USDC rather than a monthly subscription

## Dependencies for ClawRouter

### Deployment Dependencies

ClawRouter needs no external database, cache, or message queue. It talks to the BlockRun network over HTTPS using a wallet it generates itself.

- [Railway Account](https://railway.app) — hosting platform
- [BlockRun network](https://blockrun.ai) — model access and x402 settlement
- Railway persistent volume at `/root/.openclaw` — wallet durability
