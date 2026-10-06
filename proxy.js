// Host-rewriting TCP-to-HTTP proxy in front of ClawRouter.
// ClawRouter binds 127.0.0.1 hard-coded and refuses any request whose Host
// header is not localhost/127.0.0.1/[::1] (local-guard in dist/index.js),
// and also rejects cross-site Origin / Sec-Fetch-Site: cross-site headers.
// Railway's healthchecker and external clients arrive with real Hosts,
// so rewrite those headers to loopback form before forwarding upstream.
const http = require("http");

const EXTERNAL_PORT = parseInt(process.env.PORT || "8080", 10);
const INTERNAL_PORT = parseInt(process.env.INTERNAL_PORT || "8081", 10);
const UPSTREAM_HOST = "127.0.0.1";

const server = http.createServer((req, res) => {
  const headers = { ...req.headers };
  headers.host = "localhost";
  // Neutralize cross-site browser-guard headers the local guard rejects.
  delete headers.origin;
  delete headers["sec-fetch-site"];
  delete headers["sec-fetch-mode"];
  delete headers.referer;

  const upstream = http.request(
    {
      host: UPSTREAM_HOST,
      port: INTERNAL_PORT,
      path: req.url,
      method: req.method,
      headers,
    },
    (up) => {
      res.writeHead(up.statusCode || 502, up.headers);
      up.pipe(res);
    }
  );
  upstream.on("error", (err) => {
    if (!res.headersSent) {
      res.writeHead(502, { "Content-Type": "application/json" });
    }
    res.end(JSON.stringify({ error: "upstream unavailable", details: err.message }));
  });
  req.pipe(upstream);
});

server.listen(EXTERNAL_PORT, "0.0.0.0", () => {
  console.log(`[proxy] 0.0.0.0:${EXTERNAL_PORT} -> ${UPSTREAM_HOST}:${INTERNAL_PORT} (Host rewritten to localhost)`);
});