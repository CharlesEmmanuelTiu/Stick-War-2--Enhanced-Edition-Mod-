package com.brockw.stickwar.engine.multiplayer
{
    import com.brockw.game.Screen;
    import com.brockw.stickwar.BaseMain;
    import fl.controls.ScrollPolicy;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.utils.setTimeout;

    public class CoopScreen extends Screen
    {
        public static var lanSocketRef: LanSocket;

        private var mc:CoopScreenMc;
        private var main:BaseMain;
        private var lobbyContainer:MovieClip;
        private var lobbyEntries:Array;
        private var isMouseDown:Boolean;
        private var returningFromHost:Boolean;
        private var discovery: LanDiscovery;
        private var lanSocket: LanSocket;
        private var selectedSession: Object;
        private var originalHostOverlayHeight: Number;
        private var inJoinPasswordMode: Boolean;
        private var debugText:TextField;
        private var debugBuffer:Array;

        public function CoopScreen(main:BaseMain)
        {
            super();
            this.main = main;
            this.mc = new CoopScreenMc();
            addChild(this.mc);
            this.lobbyEntries = [];
            this.lobbyContainer = new MovieClip();
            setupFrame1();
        }

        private function setupButton(btn:MovieClip, clickHandler:Function) : void
        {
            btn.stop();
            btn.gotoAndStop(1);
            btn.buttonMode = true;
            btn.mouseChildren = false;
            btn.addEventListener(MouseEvent.MOUSE_OVER, function(e:*)
            {
                btn.gotoAndStop(2);
            });
            btn.addEventListener(MouseEvent.MOUSE_OUT, function(e:*)
            {
                btn.gotoAndStop(1);
            });
            btn.addEventListener(MouseEvent.CLICK, function(e:*)
            {
                btn.gotoAndStop(4);
                clickHandler(e);
                setTimeout(function()
                {
                    if (stage != null)
                    {
                        btn.gotoAndStop(btn.hitTestPoint(stage.mouseX, stage.mouseY, true) ? 2 : 1);
                    }
                }, 150);
            });
        }

        private function setupFrame1() : void
        {
            setupButton(mc.backButton, this.onBack);
            setupButton(mc.refreshButton, this.onRefresh);
            setupButton(mc.hostButton, this.onHost);

            mc.hostOverlay.visible = false;
            mc.lobbyName.visible = false;
            mc.password.visible = false;
            mc.startHost.visible = false;
            mc.cancelHost.visible = false;
            mc.joinSession.visible = false;
            mc.connecting.visible = false;
            mc.loadingIcon.visible = false;

            originalHostOverlayHeight = mc.hostOverlay.height;

            mc.scrollPane.source = lobbyContainer;
            mc.scrollPane.setSize(mc.scrollPane.width, mc.scrollPane.height);
            mc.scrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;

            setupInputFields();
            setupDebugText();

            mc.startHost.addEventListener(MouseEvent.CLICK, this.onStartHost);
            mc.cancelHost.addEventListener(MouseEvent.CLICK, this.onCancelHost);
            mc.joinSession.addEventListener(MouseEvent.CLICK, this.onJoinSessionClick);
        }

        private function setupInputFields() : void
        {
            mc.lobbyName.type = TextFieldType.INPUT;
            mc.lobbyName.text = "Lobby Name";
            mc.lobbyName.textColor = 0x666666;
            mc.lobbyName.border = false;
            mc.lobbyName.addEventListener(FocusEvent.FOCUS_IN, function(e:*)
            {
                if (mc.lobbyName.text == "Lobby Name")
                {
                    mc.lobbyName.text = "";
                    mc.lobbyName.textColor = 0x000000;
                }
            });
            mc.lobbyName.addEventListener(FocusEvent.FOCUS_OUT, function(e:*)
            {
                if (mc.lobbyName.text == "")
                {
                    mc.lobbyName.text = "Lobby Name";
                    mc.lobbyName.textColor = 0x666666;
                }
            });

            mc.password.type = TextFieldType.INPUT;
            mc.password.text = "Password (Optional)";
            mc.password.textColor = 0x666666;
            mc.password.addEventListener(FocusEvent.FOCUS_IN, function(e:*)
            {
                if (mc.password.text == "Password (Optional)")
                {
                    mc.password.text = "";
                    mc.password.textColor = 0x000000;
                    mc.password.displayAsPassword = true;
                }
            });
            mc.password.addEventListener(FocusEvent.FOCUS_OUT, function(e:*)
            {
                if (mc.password.text == "")
                {
                    mc.password.displayAsPassword = false;
                    mc.password.text = "Password (Optional)";
                    mc.password.textColor = 0x666666;
                }
            });

            var inputFmt:TextFormat = new TextFormat();
            inputFmt.size = 48;

            mc.lobbyName.setTextFormat(inputFmt);
            mc.lobbyName.defaultTextFormat = inputFmt;
            mc.lobbyName.y = mc.lobbyName.y + 4;

            mc.password.setTextFormat(inputFmt);
            mc.password.defaultTextFormat = inputFmt;
            mc.password.y = mc.password.y + 4;
        }

        private function setupDebugText() : void
        {
            debugBuffer = [];
            debugText = new TextField();
            debugText.textColor = 0x00FF00;
            debugText.background = true;
            debugText.backgroundColor = 0xCC000000;
            debugText.width = 400;
            debugText.height = 300;
            debugText.multiline = true;
            debugText.wordWrap = true;
            debugText.mouseEnabled = false;
            debugText.visible = false;
            debugText.x = 20;
            debugText.y = 400;
            mc.addChild(debugText);
        }

        private function setDebug(msg:String) : void
        {
            if (debugText != null)
            {
                debugText.visible = true;
                debugBuffer.push("[DEBUG] " + msg);
                if (debugBuffer.length > 20) debugBuffer.shift();
                debugText.text = debugBuffer.join("\n");
            }
        }

        override public function enter() : void
        {
            this.addEventListener(Event.ENTER_FRAME, this.update);
            this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.scanForLobbies();
            if (returningFromHost)
            {
                mc.hostOverlay.visible = true;
                mc.lobbyName.visible = true;
                mc.password.visible = true;
                mc.startHost.visible = true;
                mc.cancelHost.visible = true;
                returningFromHost = false;
            }
            if (discovery == null)
            {
                discovery = new LanDiscovery();
                discovery.onSessionFound = onSessionFound;
                discovery.onSessionLost = onSessionLost;
                discovery.start("127.0.0.1", 9333);
            }
        }

        override public function leave() : void
        {
            this.removeEventListener(Event.ENTER_FRAME, this.update);
            this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            if (lanSocket != null)
            {
                lanSocket.close();
                lanSocket = null;
            }
            if (discovery != null)
            {
                discovery.stop();
                discovery = null;
            }
            if (debugText != null)
            {
                debugText.visible = false;
            }
        }

        private function update(evt:Event) : void
        {
            if (discovery != null) discovery.tick();
            this.updateLobbyCards();
            this.mc.scrollPane.update();
            this.isMouseDown = false;
        }

        private function scanForLobbies() : void
        {
            for each(var card:rankEntryMc in this.lobbyEntries)
            {
                if (this.lobbyContainer.contains(card))
                {
                    this.lobbyContainer.removeChild(card);
                }
            }
            this.lobbyEntries = [];
            if (discovery == null) return;
            for each (var session:Object in discovery.sessions)
            {
                var card:rankEntryMc = new rankEntryMc();
                card.rankText.text = (lobbyEntries.length + 1).toString();
                card.nameText.text = session.name;
                card.winText.text = session.hasPassword ? "Yes" : "No";
                card.ratingText.text = session.playerCount + "/2";
                card.sessionData = session;
                card.addEventListener(MouseEvent.CLICK, onJoinGame);
                lobbyEntries.push(card);
            }
        }

        private function updateLobbyCards() : void
        {
            var i:int = 0;
            for each(var card:rankEntryMc in this.lobbyEntries)
            {
                if (!this.lobbyContainer.contains(card))
                {
                    this.lobbyContainer.addChild(card);
                }
                card.y = i * (card.height + 5);
                card.x = 0;
                i++;
            }
        }

        private function onSessionFound(session:Object):void
        {
            scanForLobbies();
        }

        private function onSessionLost(session:Object):void
        {
            scanForLobbies();
        }

        private function onJoinGame(evt:Event):void
        {
            var card:rankEntryMc = evt.currentTarget as rankEntryMc;
            var session:Object = card.sessionData;

            if (mc.connecting != null)
            {
                mc.connecting.visible = false;
                mc.connecting.stop();
            }

            if (session.hasPassword)
            {
                inJoinPasswordMode = true;
                selectedSession = session;
                mc.hostOverlay.visible = true;
                mc.hostOverlay.height = originalHostOverlayHeight / 2;
                mc.joinSession.visible = true;
                mc.password.visible = true;
                mc.password.displayAsPassword = false;
                mc.password.text = "Enter password";
                mc.password.textColor = 0x666666;
                mc.password.border = false;
                mc.cancelHost.visible = true;
                mc.lobbyName.visible = false;
                mc.startHost.visible = false;
            }
            else
            {
                joinSession(session, "");
            }
        }

        private function onJoinSessionClick(evt:Event):void
        {
            var session:Object = selectedSession;
            if (session == null) return;
            var pw:String = mc.password.text;
            if (pw == "" || pw == "Enter password")
            {
                mc.password.border = true;
                mc.password.borderColor = 0xFF0000;
                setTimeout(function()
                {
                    if (mc.password) mc.password.border = false;
                }, 500);
                return;
            }
            joinSession(session, pw);
        }

        private function joinSession(session:Object, password:String):void
        {
            mc.connecting.visible = true;
            mc.connecting.play();

            if (lanSocket != null) lanSocket.close();
            lanSocket = new LanSocket();
            CoopScreen.lanSocketRef = lanSocket;

            lanSocket.onConnect = function():void
            {
                lanSocket.send("PROXY_JOIN|" + session.id + "|" + password);
            };

            lanSocket.onMessage = function(line:String):void
            {
                if (line == "JOINED")
                {
                    mc.connecting.visible = false;
                    mc.connecting.stop();
                    HostSessionScreen.role = "client";
                    HostSessionScreen.lobbyName = session.name;
                    HostSessionScreen.password = password;
                    HostSessionScreen.hostIp = session.hostIp;
                    HostSessionScreen.hostPort = 9333;
                    HostSessionScreen.sourceSocket = lanSocket;
                    lanSocket = null;
                    inJoinPasswordMode = false;
                    main.showScreen("hostSession", false, true);
                }
                else if (line.indexOf("JOIN_FAILED") == 0)
                {
                    mc.connecting.visible = false;
                    mc.connecting.stop();
                    mc.password.border = true;
                    mc.password.borderColor = 0xFF0000;
                    mc.password.text = "";
                    mc.password.textColor = 0x666666;
                }
            };

            lanSocket.onError = function(msg:String):void
            {
                mc.connecting.visible = false;
                mc.connecting.stop();
                setDebug("Connect error: " + msg);
            };

            lanSocket.connect("127.0.0.1", 9333);
        }

        private function onMouseDown(evt:Event) : void
        {
            this.isMouseDown = true;
        }

        private function onBack(evt:Event) : void
        {
            this.main.showScreen("mainMenu");
        }

        private function onRefresh(evt:Event) : void
        {
            this.scanForLobbies();
            if (discovery != null)
            {
                setDebug("Scanning subnets for remote sessions...");
                discovery.scanSubnets();
            }
        }

        private function onHost(evt:Event) : void
        {
            this.mc.hostOverlay.visible = true;
            this.mc.lobbyName.visible = true;
            this.mc.password.visible = true;
            this.mc.startHost.visible = true;
            this.mc.cancelHost.visible = true;
        }

        private function onCancelHost(evt:Event) : void
        {
            if (inJoinPasswordMode)
            {
                inJoinPasswordMode = false;
                mc.hostOverlay.height = originalHostOverlayHeight;
                mc.joinSession.visible = false;
                mc.lobbyName.visible = false;
                mc.startHost.visible = false;
                mc.password.visible = false;
                mc.password.displayAsPassword = false;
                mc.password.text = "Password (Optional)";
                mc.password.textColor = 0x666666;
                mc.password.border = false;
                mc.hostOverlay.visible = false;
                mc.cancelHost.visible = false;
                selectedSession = null;
                return;
            }
            this.mc.hostOverlay.visible = false;
            this.mc.lobbyName.visible = false;
            this.mc.password.visible = false;
            this.mc.startHost.visible = false;
            this.mc.cancelHost.visible = false;
            this.mc.lobbyName.text = "Lobby Name";
            this.mc.lobbyName.textColor = 0x666666;
            this.mc.lobbyName.border = false;
            this.mc.password.text = "Password (Optional)";
            this.mc.password.textColor = 0x666666;
            this.mc.password.displayAsPassword = false;
        }

        private function onStartHost(evt:Event) : void
        {
            var name:String = mc.lobbyName.text;
            if (name == "" || name == "Lobby Name")
            {
                mc.lobbyName.border = true;
                mc.lobbyName.borderColor = 0xFF0000;
                setTimeout(function()
                {
                    if (mc.lobbyName) mc.lobbyName.border = false;
                }, 500);
                return;
            }
            var pw:String = (mc.password.text == "Password (Optional)" || mc.password.text == "") ? "" : mc.password.text;

            mc.hostOverlay.visible = false;
            mc.lobbyName.visible = false;
            mc.password.visible = false;
            mc.startHost.visible = false;
            mc.cancelHost.visible = false;
            setDebug("Connecting...");

            if (lanSocket != null) lanSocket.close();
            lanSocket = new LanSocket();
            CoopScreen.lanSocketRef = lanSocket;

            lanSocket.onConnect = function():void
            {
                setDebug("Connected! Sending REGISTER...");
                lanSocket.send("REGISTER|" + name + "|" + pw);
            };

            lanSocket.onMessage = function(line:String):void
            {
                setDebug("Received: " + line);
                if (line.indexOf("REGISTERED|") == 0)
                {
                    mc.loadingIcon.visible = false;
                    mc.loadingIcon.stop();
                    HostSessionScreen.role = "host";
                    HostSessionScreen.lobbyName = name;
                    HostSessionScreen.password = pw;
                    HostSessionScreen.hostIp = "127.0.0.1";
                    HostSessionScreen.hostPort = 9333;
                    HostSessionScreen.sourceSocket = lanSocket;
                    lanSocket = null;
                    returningFromHost = true;
                    main.showScreen("hostSession", false, true);
                }
            };

            lanSocket.onClose = function():void
            {
                setDebug("Socket closed unexpectedly");
                mc.loadingIcon.visible = false;
                mc.loadingIcon.stop();
                mc.hostOverlay.visible = true;
                mc.lobbyName.visible = true;
                mc.password.visible = true;
                mc.startHost.visible = true;
                mc.cancelHost.visible = true;
            };

            lanSocket.onError = function(msg:String):void
            {
                setDebug("Error: " + msg);
                mc.loadingIcon.visible = false;
                mc.loadingIcon.stop();
                mc.hostOverlay.visible = true;
                mc.lobbyName.visible = true;
                mc.password.visible = true;
                mc.startHost.visible = true;
                mc.cancelHost.visible = true;
            };

            lanSocket.connect("127.0.0.1", 9333);
        }
    }
}
