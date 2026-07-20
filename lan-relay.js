const net = require("net");
const dgram = require("dgram");

const TCP_PORT = 9333;
const UDP_PORT = 9334;
const REMOTE_TIMEOUT = 6000;

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

server.listen(TCP_PORT, "0.0.0.0", () => {
  log("TCP", "Server listening on port " + TCP_PORT);
});
