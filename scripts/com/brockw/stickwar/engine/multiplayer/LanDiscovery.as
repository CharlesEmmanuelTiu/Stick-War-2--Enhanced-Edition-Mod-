package com.brockw.stickwar.engine.multiplayer
{
    import flash.net.Socket;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;

    public class LanDiscovery
    {
        private var socket:Socket;
        private var buffer:String;
        private var _sessions:Array;
        private var lastSweep:int;
        private var relayHost:String;
        private var relayPort:int;
        private var _connected:Boolean;
        private var pendingList:Boolean;

        public var onSessionFound:Function;
        public var onSessionLost:Function;

        public static const TIMEOUT_MS:int = 6000;
        public static const SWEEP_INTERVAL_MS:int = 2000;

        public function LanDiscovery()
        {
            _sessions = [];
            lastSweep = getTimer();
            _connected = false;
            pendingList = false;
            buffer = "";
        }

        public function start(host:String, port:int):void
        {
            relayHost = host;
            relayPort = port;
            socket = new Socket();
            socket.addEventListener(Event.CONNECT, onConnected);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
            socket.addEventListener(Event.CLOSE, onClose);
            socket.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            try
            {
                socket.connect(host, port);
            }
            catch (e:Error) {}
        }

        public function stop():void
        {
            if (socket != null)
            {
                try
                {
                    socket.removeEventListener(Event.CONNECT, onConnected);
                    socket.removeEventListener(ProgressEvent.SOCKET_DATA, onData);
                    socket.removeEventListener(Event.CLOSE, onClose);
                    socket.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                    socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                    socket.close();
                }
                catch (e:Error) {}
                socket = null;
            }
            _sessions = [];
            buffer = "";
            _connected = false;
        }

        public function tick():void
        {
            var now:int = getTimer();
            if (now - lastSweep < SWEEP_INTERVAL_MS) return;
            lastSweep = now;

            if (_connected && !pendingList)
            {
                pendingList = true;
                var bytes:ByteArray = new ByteArray();
                bytes.writeUTFBytes("LIST\n");
                try
                {
                    socket.writeBytes(bytes, 0, bytes.length);
                    socket.flush();
                }
                catch (e:Error) {}
            }

            var toRemove:Array = [];
            for each (var s:Object in _sessions)
            {
                if (now - s.lastSeen > TIMEOUT_MS)
                {
                    toRemove.push(s);
                }
            }
            for each (var r:Object in toRemove)
            {
                var idx:int = _sessions.indexOf(r);
                if (idx >= 0) _sessions.splice(idx, 1);
                if (onSessionLost != null) onSessionLost(r);
            }
        }

        public function scanSubnets():void
        {
            if (_connected && socket != null)
            {
                var bytes:ByteArray = new ByteArray();
                bytes.writeUTFBytes("SCAN_SUBNET\n");
                try
                {
                    socket.writeBytes(bytes, 0, bytes.length);
                    socket.flush();
                }
                catch (e:Error) {}
            }
        }

        private function onConnected(event:Event):void
        {
            _connected = true;
        }

        private function onClose(event:Event):void
        {
            _connected = false;
        }

        private function onData(event:ProgressEvent):void
        {
            var data:String = socket.readUTFBytes(socket.bytesAvailable);
            buffer += data;
            while (buffer.indexOf("\n") != -1)
            {
                var idx:int = buffer.indexOf("\n");
                var line:String = buffer.substring(0, idx);
                buffer = buffer.substring(idx + 1);
                processLine(line);
            }
        }

        private function processLine(line:String):void
        {
            if (line.indexOf("SESSIONS|") == 0)
            {
                pendingList = false;
                var parts:Array = line.split("|");
                var count:int = parseInt(parts[1]);
                var now:int = getTimer();
                var seenIds:Object = {};

                if (count > 0 && parts.length > 2)
                {
                    var entries:Array = parts[2].split(";");
                    for each (var entry:String in entries)
                    {
                        var fields:Array = entry.split(",");
                        if (fields.length < 5) continue;
                        var id:String = fields[0];
                        var name:String = fields[1];
                        var hasPw:Boolean = (fields[2] == "1");
                        var pc:int = parseInt(fields[3]);
                        var hostIp:String = fields[4];
                        seenIds[id] = true;

                        var found:Boolean = false;
                        for each (var s:Object in _sessions)
                        {
                            if (s.id == id)
                            {
                                s.lastSeen = now;
                                found = true;
                                break;
                            }
                        }
                        if (!found)
                        {
                            var session:Object = {
                                id: id,
                                name: name,
                                hostIp: hostIp,
                                hostPort: 9333,
                                hasPassword: hasPw,
                                playerCount: pc,
                                lastSeen: now
                            };
                            _sessions.push(session);
                            if (onSessionFound != null) onSessionFound(session);
                        }
                    }
                }

                var toRemove:Array = [];
                for each (var s2:Object in _sessions)
                {
                    if (seenIds[s2.id] == undefined)
                    {
                        toRemove.push(s2);
                    }
                }
                for each (var r:Object in toRemove)
                {
                    var idx2:int = _sessions.indexOf(r);
                    if (idx2 >= 0) _sessions.splice(idx2, 1);
                    if (onSessionLost != null) onSessionLost(r);
                }
                return;
            }
        }

        private function onIoError(event:IOErrorEvent):void {}
        private function onSecurityError(event:SecurityErrorEvent):void {}

        public function get sessions():Array
        {
            return _sessions.concat();
        }

        public function get isRunning():Boolean
        {
            return _connected;
        }
    }
}
