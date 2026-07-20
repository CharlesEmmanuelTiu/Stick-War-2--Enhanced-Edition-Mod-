package com.brockw.stickwar.engine.multiplayer
{
    import flash.net.Socket;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.ByteArray;

    public class LanSocket
    {
        private var socket:Socket;
        private var buffer:String;

        public var onMessage:Function;
        public var onError:Function;
        public var onConnect:Function;
        public var onClose:Function;

        public function LanSocket()
        {
            buffer = "";
        }

        public function connect(host:String, port:int):void
        {
            socket = new Socket();
            socket.addEventListener(Event.CONNECT, function(e:Event):void
            {
                if (onConnect != null) onConnect();
            });
            socket.addEventListener(ProgressEvent.SOCKET_DATA, function(e:ProgressEvent):void
            {
                var data:String = socket.readUTFBytes(socket.bytesAvailable);
                buffer += data;
                while (buffer.indexOf("\n") != -1)
                {
                    var idx:int = buffer.indexOf("\n");
                    var line:String = buffer.substring(0, idx);
                    buffer = buffer.substring(idx + 1);
                    if (onMessage != null) onMessage(line);
                }
            });
            socket.addEventListener(Event.CLOSE, function(e:Event):void
            {
                if (onClose != null) onClose();
            });
            socket.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
            {
                if (onError != null) onError("IOError: " + e.text);
            });
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void
            {
                if (onError != null) onError("SecurityError: " + e.text);
            });
            try
            {
                socket.connect(host, port);
            }
            catch (e:Error)
            {
                if (onError != null) onError("Connect failed: " + e.message);
            }
        }

        public function send(line:String):void
        {
            if (socket == null) return;
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(line + "\n");
            try
            {
                socket.writeBytes(bytes, 0, bytes.length);
                socket.flush();
            }
            catch (e:Error)
            {
                if (onError != null) onError("Send failed: " + e.message);
            }
        }

        public function close():void
        {
            if (socket != null)
            {
                try { socket.close(); } catch (e:Error) {}
                socket = null;
            }
            buffer = "";
        }

        public function get connected():Boolean
        {
            return socket != null && socket.connected;
        }
    }
}
