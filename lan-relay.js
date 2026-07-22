const net = require("net");
const dgram = require("dgram");
const os = require("os");

const TCP_PORT = 9333;
const UDP_PORT = 9334;
const REMOTE_TIMEOUT = 30000;

let nextSequential = 1;
const lobbies = new Map();
const remoteSessions = new Map();

function now() { return new Date().toISOString().substr(11, 8); }

function log(tag, msg) { console.log("[" + now() + "][" + tag + "] " + msg); }

function makeId() {
  return "l_" + Date.now().toString(36) + "_" + (nextSequential++) + "_" + Math.random().toString(36).substr(2, 4);
}

function send(socket, line) {
  if (socket && !socket.destroyed) {
    try { socket.write(line + "\n"); } catch (e) {}
  }
}

function findPeer(socket) {
  if (!socket._lobbyId) return null;
  const lobby = lobbies.get(socket._lobbyId);
  if (!lobby) return null;
  return lobby.host === socket ? lobby.client : lobby.host;
}

function getLobbyList() {
  const entries = [];
  for (const [id, lobby] of lobbies) {
    if (lobby.host && !lobby.host.destroyed && !lobby.client) {
      entries.push(id + "," + lobby.name + "," + (lobby.password ? "1" : "0") + ",1,127.0.0.1");
    }
  }
  const now = Date.now();
  const expired = [];
  for (const [key, rs] of remoteSessions) {
    if (now - rs.lastSeen > REMOTE_TIMEOUT) {
      expired.push(key);
    } else {
      entries.push(rs.id + "," + rs.name + "," + (rs.hasPassword ? "1" : "0") + "," + rs.playerCount + "," + rs.hostIp);
    }
  }
  for (const key of expired) remoteSessions.delete(key);
  return "SESSIONS|" + entries.length + "|" + entries.join(";");
}

function getBroadcastAddresses() {
  const broadcasts = [];
  const interfaces = os.networkInterfaces();
  for (const name in interfaces) {
    for (const iface of interfaces[name]) {
      if (iface.internal || iface.family !== "IPv4") continue;
      const ipParts = iface.address.split(".").map(Number);
      const maskParts = iface.netmask.split(".").map(Number);
      const bc = ipParts.map((p, i) => p | (~maskParts[i] & 0xFF));
      broadcasts.push(bc.join("."));
    }
  }
  return broadcasts;
}

// --- UDP discovery ---
const udp = dgram.createSocket("udp4");
udp.on("listening", () => {
  udp.setBroadcast(true);
  log("UDP", "Discovery listening on port " + UDP_PORT);
});
udp.on("message", (msg, rinfo) => {
  const text = msg.toString();
  const parts = text.split("|");
  if (parts[0] !== "HELLO" || parts.length < 5) return;
  const remoteId = parts[1];
  const name = parts[2];
  const hasPassword = parts[3] === "1";
  const playerCount = parseInt(parts[4]) || 1;
  if (lobbies.has(remoteId)) return;
  const key = rinfo.address + ":" + remoteId;
  remoteSessions.set(key, {
    id: remoteId,
    name: name,
    hasPassword: hasPassword,
    playerCount: playerCount,
    hostIp: rinfo.address,
    lastSeen: Date.now()
  });
  log("UDP", "Discovered session '" + name + "' at " + rinfo.address);
});
udp.bind(UDP_PORT);

// --- TCP relay ---
const server = net.createServer((socket) => {
  const remoteAddr = socket.remoteAddress || "unknown";
  const remotePort = socket.remotePort || 0;
  log("TCP", "Connection from " + remoteAddr + ":" + remotePort);

  socket._state = "fresh";
  socket._lobbyId = null;
  let buffer = "";
  let heartbeatTimer = null;

  send(socket, "WELCOME|relay_ready");
  log("TCP", "Sent WELCOME to " + remoteAddr + ":" + remotePort);

  function resetHeartbeat() {
    if (heartbeatTimer) clearTimeout(heartbeatTimer);
    heartbeatTimer = setTimeout(() => {
      send(socket, "ERROR|Heartbeat timeout");
      socket.destroy();
    }, 30000);
  }
  resetHeartbeat();

  socket.on("data", (chunk) => {
    buffer += chunk.toString();
    while (true) {
      const idx = buffer.indexOf("\n");
      if (idx === -1) break;
      const line = buffer.substring(0, idx);
      buffer = buffer.substring(idx + 1);
      resetHeartbeat();
      processLine(line);
    }
  });

  function lobbyCleanup(id) {
    const lobby = lobbies.get(id);
    if (!lobby) return;
    if (lobby.helloInterval) clearInterval(lobby.helloInterval);
    if (lobby.host && lobby.host.remoteCleanup) lobby.host.remoteCleanup();
    lobbies.delete(id);
  }

  socket.on("close", () => {
    if (heartbeatTimer) clearTimeout(heartbeatTimer);
    if (socket._lobbyId && lobbies.has(socket._lobbyId)) {
      const lobby = lobbies.get(socket._lobbyId);
      const peer = lobby.host === socket ? lobby.client : lobby.host;
      const role = socket._state;
      log("TCP", "Disconnected (role=" + role + ", lobby=" + socket._lobbyId + ")");
      if (peer && !peer.destroyed) {
        send(peer, lobby.host === socket ? "HOST_DISCONNECTED" : "CLIENT_DISCONNECTED");
        peer._state = "fresh";
        peer._lobbyId = null;
      }
      lobbyCleanup(socket._lobbyId);
    } else {
      log("TCP", "Disconnected (unregistered)");
    }
  });

  socket.on("error", (err) => {
    log("TCP", "Socket error: " + err.message);
  });

  function processLine(line) {
    const parts = line.split("|");
    const cmd = parts[0];

    if (socket._pipeMode) return;

    if (cmd === "PING") {
      send(socket, "PONG");
      return;
    }

    if (cmd === "REGISTER") {
      if (socket._state !== "fresh") {
        send(socket, "ERROR|Already registered or joined");
        return;
      }
      if (parts.length < 3) {
        send(socket, "ERROR|Missing name or password");
        return;
      }
      const name = parts[1];
      const password = parts[2] || "";
      const id = makeId();
      const lobby = { id, host: socket, client: null, name, password };
      lobby.helloInterval = setInterval(() => {
        const msg = "HELLO|" + id + "|" + name + "|" + (password ? "1" : "0") + "|1";
        try { udp.send(msg, 0, msg.length, UDP_PORT, "255.255.255.255"); } catch (e) {}
        const broadcasts = getBroadcastAddresses();
        for (const addr of broadcasts) {
          if (addr === "255.255.255.255") continue;
          try { udp.send(msg, 0, msg.length, UDP_PORT, addr); } catch (e) {}
        }
      }, 2000);
      lobbies.set(id, lobby);
      socket._state = "host";
      socket._lobbyId = id;
      log("CMD", "REGISTER name='" + name + "' id=" + id);
      send(socket, "REGISTERED|" + id);
      return;
    }

    if (cmd === "LIST") {
      log("CMD", "LIST");
      send(socket, getLobbyList());
      return;
    }

    if (cmd === "SCAN_SUBNET") {
      log("CMD", "SCAN_SUBNET");
      scanSubnets(socket);
      return;
    }

    if (cmd === "JOIN") {
      if (socket._state !== "fresh") {
        send(socket, "ERROR|Already registered or joined");
        return;
      }
      if (parts.length < 2) {
        send(socket, "JOIN_FAILED|Missing lobby ID");
        return;
      }
      const targetId = parts[1];
      const joinPw = parts[2] || "";
      const lobby = lobbies.get(targetId);
      if (!lobby) {
        log("CMD", "JOIN target=" + targetId + " FAILED (not found)");
        send(socket, "JOIN_FAILED|Lobby not found");
        return;
      }
      if (lobby.client) {
        log("CMD", "JOIN target=" + targetId + " FAILED (full)");
        send(socket, "JOIN_FAILED|Lobby full");
        return;
      }
      if (lobby.password !== "" && joinPw !== lobby.password) {
        log("CMD", "JOIN target=" + targetId + " FAILED (wrong password)");
        send(socket, "JOIN_FAILED|Wrong password");
        return;
      }
      if (lobby.host.destroyed) {
        lobbyCleanup(targetId);
        log("CMD", "JOIN target=" + targetId + " FAILED (host disconnected)");
        send(socket, "JOIN_FAILED|Host disconnected");
        return;
      }
      lobby.client = socket;
      socket._state = "client";
      socket._lobbyId = targetId;
      if (lobby.helloInterval) {
        clearInterval(lobby.helloInterval);
        lobby.helloInterval = null;
      }
      log("CMD", "JOIN target=" + targetId + " OK (paired host<->client)");
      send(lobby.host, "CLIENT_JOINED");
      send(socket, "JOINED");
      return;
    }

    if (cmd === "PROXY_JOIN") {
      if (parts.length < 2) {
        send(socket, "JOIN_FAILED|Missing lobby ID");
        return;
      }
      const targetId = parts[1];
      const joinPw = parts[2] || "";
      let targetIp = null;
      for (const [, rs] of remoteSessions) {
        if (rs.id === targetId) { targetIp = rs.hostIp; break; }
      }
      for (const [, lobby] of lobbies) {
        if (lobby.id === targetId && lobby.host && !lobby.host.destroyed && !lobby.client) {
          targetIp = "127.0.0.1"; break;
        }
      }
      if (!targetIp) {
        send(socket, "JOIN_FAILED|Session not found");
        return;
      }
      socket._pipeMode = true;
      log("CMD", "PROXY_JOIN target=" + targetId + " at " + targetIp);
      const proxySocket = new net.Socket();
      let proxyBuffer = "";
      let proxyJoined = false;
      function enterPipeMode() {
        if (heartbeatTimer) clearTimeout(heartbeatTimer);
        socket.removeAllListeners("data");
        socket.on("data", (c) => {
          resetHeartbeat();
          if (!proxySocket.destroyed) proxySocket.write(c);
        });
        proxySocket.on("data", (c) => { if (!socket.destroyed) socket.write(c); });
        socket.on("close", () => { if (!proxySocket.destroyed) proxySocket.destroy(); });
        proxySocket.on("close", () => { if (!socket.destroyed) socket.destroy(); });
        socket.on("error", () => {});
        proxySocket.on("error", () => {});
      }
      function failProxy(msg) {
        if (heartbeatTimer) clearTimeout(heartbeatTimer);
        if (socket.writable) socket.end("JOIN_FAILED|" + msg + "\n");
        else if (!socket.destroyed) socket.destroy();
        if (!proxySocket.destroyed) proxySocket.destroy();
      }
      proxySocket.connect(TCP_PORT, targetIp, () => {
        proxySocket.write("JOIN|" + targetId + "|" + joinPw + "\n");
      });
      proxySocket.on("data", (chunk) => {
        if (proxyJoined) return;
        proxyBuffer += chunk.toString();
        while (true) {
          const idx = proxyBuffer.indexOf("\n");
          if (idx === -1) break;
          const line = proxyBuffer.substring(0, idx);
          proxyBuffer = proxyBuffer.substring(idx + 1);
          if (line === "JOINED") {
            proxyJoined = true;
            send(socket, "JOINED");
            enterPipeMode();
          } else if (line.indexOf("JOIN_FAILED") === 0) {
            proxyJoined = true;
            failProxy(line.substring(11));
          }
        }
      });
      proxySocket.on("close", () => {
        if (!proxyJoined) failProxy("Connection to host failed");
      });
      proxySocket.on("error", (err) => {
        if (!proxyJoined) failProxy(err.message);
      });
      return;
    }

    if (cmd === "DISCONNECT") {
      log("CMD", "DISCONNECT lobby=" + socket._lobbyId);
      const peer = findPeer(socket);
      if (peer && !peer.destroyed) {
        send(peer, "CLIENT_DISCONNECTED");
        peer._state = "fresh";
        peer._lobbyId = null;
      }
      if (socket._lobbyId && lobbies.has(socket._lobbyId)) {
        lobbyCleanup(socket._lobbyId);
      }
      socket._state = "fresh";
      socket._lobbyId = null;
      return;
    }

    if (cmd === "DATA") {
      const peer = findPeer(socket);
      if (peer && !peer.destroyed) {
        const payloadLen = parts.slice(1).join("|").length;
        log("CMD", "DATA (" + payloadLen + " bytes) -> peer");
        send(peer, parts.slice(1).join("|"));
      } else {
        log("CMD", "DATA dropped (no peer)");
      }
      return;
    }

    log("CMD", "Unknown command: " + cmd);
    send(socket, "ERROR|Unknown command");
  }
});

// --- Subnet TCP scan (for ZeroTier / remote LAN discovery) ---
let _scanInProgress = false;
const _scanQueue = [];

function scanSubnets(requestingSocket) {
  if (_scanInProgress) {
    _scanQueue.push(requestingSocket);
    return;
  }
  _scanInProgress = true;

  const interfaces = os.networkInterfaces();
  const targets = [];

  for (const name in interfaces) {
    for (const iface of interfaces[name]) {
      if (iface.internal || iface.family !== "IPv4") continue;
      const ipParts = iface.address.split(".").map(Number);
      const maskParts = iface.netmask.split(".").map(Number);
      const network = ipParts.map((p, i) => p & maskParts[i]);
      for (let i = 1; i <= 254; i++) {
        const ip = network[0] + "." + network[1] + "." + network[2] + "." + i;
        if (ip !== iface.address) targets.push(ip);
      }
    }
  }

  if (targets.length === 0) {
    send(requestingSocket, "SESSIONS|0|");
    _scanInProgress = false;
    processScanQueue();
    return;
  }

  const found = {};
  let remaining = targets.length;
  const TIMEOUT = 1500;
  const BATCH = 60;
  let idx = 0;

  function processBatch() {
    const batch = targets.slice(idx, idx + BATCH);
    idx += BATCH;

    for (const ip of batch) {
      const s = new net.Socket();
      let handled = false;

      const finish = (sessionLine) => {
        if (handled) return;
        handled = true;
        if (!s.destroyed) s.destroy();

        if (sessionLine && sessionLine.indexOf("SESSIONS|") === 0) {
          const parts = sessionLine.split("|");
          const count = parseInt(parts[1]) || 0;
          if (count > 0) {
            for (const entry of parts.slice(2).join("|").split(";")) {
              const e = entry.split(",");
              if (e.length >= 5) {
                const key = ip + ":" + e[0];
                found[key] = { id: e[0], name: e[1], hasPassword: e[2] === "1", playerCount: parseInt(e[3]) || 1, hostIp: ip, lastSeen: Date.now() };
              }
            }
          }
        }

        remaining--;
        if (remaining === 0) finalize();
      };

      s.setTimeout(TIMEOUT);
      s.on("timeout", () => finish(null));
      s.on("error", () => finish(null));

      let buf = "";
      s.on("data", (chunk) => {
        buf += chunk.toString();
        const nl = buf.indexOf("\n");
        if (nl !== -1) finish(buf.substring(0, nl));
      });
      s.on("close", () => finish(null));

      s.connect(TCP_PORT, ip, () => { s.write("LIST\n"); });
    }

    if (idx < targets.length) {
      setImmediate(processBatch);
    }
  }

  function finalize() {
    for (const key in found) remoteSessions.set(key, found[key]);
    const entries = [];
    for (const [key, rs] of remoteSessions) {
      if (Date.now() - rs.lastSeen > REMOTE_TIMEOUT) remoteSessions.delete(key);
      else entries.push(rs.id + "," + rs.name + "," + (rs.hasPassword ? "1" : "0") + "," + rs.playerCount + "," + rs.hostIp);
    }
    send(requestingSocket, "SESSIONS|" + entries.length + "|" + entries.join(";"));
    _scanInProgress = false;
    if (remaining > 0) remaining = 0;
    processScanQueue();
  }

  processBatch();
}

function processScanQueue() {
  while (_scanQueue.length > 0 && !_scanInProgress) {
    const next = _scanQueue.shift();
    scanSubnets(next);
  }
}

server.listen(TCP_PORT, "0.0.0.0", () => {
  log("TCP", "Server listening on port " + TCP_PORT);
});
