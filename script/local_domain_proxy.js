const fs = require("fs");
const http = require("http");
const https = require("https");
const net = require("net");
const path = require("path");

const PROJECT_ROOT = path.resolve(__dirname, "..");
const CERT_DIR = path.join(PROJECT_ROOT, "script", "certs");
const TARGET_HOST = process.env.RAILS_HOST || "127.0.0.1";
const TARGET_PORT = Number.parseInt(process.env.RAILS_PORT || "3000", 10);
const PUBLIC_HOST = process.env.LOCAL_APP_HOST || "work.local";
const HTTP_PORT = Number.parseInt(process.env.LOCAL_HTTP_PORT || "80", 10);
const HTTPS_PORT = Number.parseInt(process.env.LOCAL_HTTPS_PORT || "443", 10);
const FORCE_HTTPS = process.env.LOCAL_FORCE_HTTPS === "1";

const keyPath = path.join(CERT_DIR, "work-local.key");
const certPath = path.join(CERT_DIR, "work-local.crt");

function certificateOptions() {
  if (!fs.existsSync(keyPath) || !fs.existsSync(certPath)) {
    return null;
  }

  return {
    key: fs.readFileSync(keyPath),
    cert: fs.readFileSync(certPath)
  };
}

function forwardedHeaders(request, protocol, port) {
  const headers = { ...request.headers };
  const forwardedFor = headers["x-forwarded-for"];

  headers.host = PUBLIC_HOST;
  headers["x-forwarded-host"] = PUBLIC_HOST;
  headers["x-forwarded-proto"] = protocol;
  headers["x-forwarded-port"] = String(port);
  headers["x-forwarded-for"] = forwardedFor
    ? `${forwardedFor}, ${request.socket.remoteAddress}`
    : request.socket.remoteAddress;

  return headers;
}

function rewriteLocation(location, protocol) {
  if (!location) return location;

  try {
    const url = new URL(location, `${protocol}://${PUBLIC_HOST}`);

    if (url.hostname === PUBLIC_HOST || url.hostname === TARGET_HOST) {
      url.protocol = `${protocol}:`;
      url.hostname = PUBLIC_HOST;
      url.port = "";
      return url.toString();
    }
  } catch {
    return location;
  }

  return location;
}

function proxyRequest(protocol, port) {
  return (clientRequest, clientResponse) => {
    const upstream = http.request(
      {
        hostname: TARGET_HOST,
        port: TARGET_PORT,
        method: clientRequest.method,
        path: clientRequest.url,
        headers: forwardedHeaders(clientRequest, protocol, port)
      },
      (upstreamResponse) => {
        const responseHeaders = { ...upstreamResponse.headers };

        if (responseHeaders.location) {
          responseHeaders.location = rewriteLocation(responseHeaders.location, protocol);
        }

        clientResponse.writeHead(
          upstreamResponse.statusCode || 502,
          upstreamResponse.statusMessage,
          responseHeaders
        );

        upstreamResponse.pipe(clientResponse);
      }
    );

    upstream.on("error", () => {
      clientResponse.writeHead(502, { "content-type": "text/plain; charset=utf-8" });
      clientResponse.end("Rails is not ready yet. Refresh in a few seconds.");
    });

    clientRequest.pipe(upstream);
  };
}

function proxyUpgrade(protocol, port) {
  return (request, socket, head) => {
    const upstream = net.connect(TARGET_PORT, TARGET_HOST, () => {
      upstream.write(`${request.method} ${request.url} HTTP/${request.httpVersion}\r\n`);

      for (const [name, value] of Object.entries(forwardedHeaders(request, protocol, port))) {
        if (Array.isArray(value)) {
          value.forEach((entry) => upstream.write(`${name}: ${entry}\r\n`));
        } else if (value !== undefined) {
          upstream.write(`${name}: ${value}\r\n`);
        }
      }

      upstream.write("\r\n");

      if (head.length > 0) {
        upstream.write(head);
      }

      upstream.pipe(socket);
      socket.pipe(upstream);
    });

    upstream.on("error", () => socket.destroy());
  };
}

const httpsOptions = certificateOptions();
let httpsServer = null;
let httpServer = null;

if (httpsOptions) {
  httpsServer = https.createServer(httpsOptions, proxyRequest("https", HTTPS_PORT));
  httpsServer.on("upgrade", proxyUpgrade("https", HTTPS_PORT));
  httpsServer.listen(HTTPS_PORT, "127.0.0.1", () => {
    console.log(`HTTPS proxy listening at https://${PUBLIC_HOST}`);
  });
}

if (httpsOptions && FORCE_HTTPS) {
  httpServer = http.createServer((request, response) => {
    response.writeHead(308, {
      location: `https://${PUBLIC_HOST}${request.url}`
    });
    response.end();
  });
  httpServer.listen(HTTP_PORT, "127.0.0.1", () => {
    console.log(`HTTP proxy redirecting to https://${PUBLIC_HOST}`);
  });
} else {
  httpServer = http.createServer(proxyRequest("http", HTTP_PORT));
  httpServer.on("upgrade", proxyUpgrade("http", HTTP_PORT));
  httpServer.listen(HTTP_PORT, "127.0.0.1", () => {
    console.log(`HTTP proxy listening at http://${PUBLIC_HOST}`);
  });
}

if (!httpsOptions) {
  console.log("HTTPS proxy skipped because local certificate files are missing.");
} else if (!FORCE_HTTPS) {
  console.log("HTTPS proxy available but HTTP redirect is disabled.");
}

function shutdown() {
  httpServer.close();

  if (httpsServer) {
    httpsServer.close(() => process.exit(0));
  } else {
    process.exit(0);
  }
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
