package com.brockw.stickwar.engine.multiplayer
{
    import com.brockw.game.Screen;
    import com.brockw.stickwar.BaseMain;
    import com.brockw.stickwar.campaign.CampaignMenuScreen;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.setInterval;
    import flash.utils.clearInterval;
    import flash.utils.setTimeout;

    public class HostSessionScreen extends Screen
    {
        public static var role:String;
        public static var lobbyId:String;
        public static var lobbyName:String;
        public static var password:String;
        public static var hostIp:String;
        public static var hostPort:int;
        public static var sourceSocket: LanSocket;

        private var mc:HostSessionMc;
        private var main:BaseMain;
        private var lanSocket:LanSocket;
        private var debugText:TextField;
        private var debugIntervalId:int;
        private var _pingIntervalId:int;

        public function HostSessionScreen(main:BaseMain)
        {
            super();
            this.main = main;
            this.mc = new HostSessionMc();
            addChild(this.mc);
            setupButton(mc.stopHosting, onStopHosting);
            var panel:MovieClip = mc.newOrContinuePanel;
            if (panel.newGameButton != null) setupButton(panel.newGameButton, onNewGame);
            if (panel.continueButton != null) setupButton(panel.continueButton, onContinue);
            if (mc.difficultyPanel.normalButton != null) setupButton(mc.difficultyPanel.normalButton, onNormalDifficulty);
            if (mc.difficultyPanel.hardButton != null) setupButton(mc.difficultyPanel.hardButton, onHardDifficulty);
            if (mc.difficultyPanel.insaneButton != null) setupButton(mc.difficultyPanel.insaneButton, onInsaneDifficulty);
        }

        override public function enter():void
        {
            mc.player2_icon.visible = false;
            mc.newOrContinuePanel.visible = false;
            mc.difficultyPanel.visible = false;
            mc.stopHosting.visible = (role == "host");

            if (role == "host")
            {
                mc.waiting.visible = false;
                mc.loadingIcon.visible = true;
                mc.loadingIcon.play();
                // Host may start the game even before a player 2 joins.
                mc.newOrContinuePanel.visible = true;
                if (main.campaign.saveGameExists())
                {
                    mc.newOrContinuePanel.continueButton.visible = true;
                }
                else
                {
                    mc.newOrContinuePanel.continueButton.visible = false;
                }
            }
            else
            {
                mc.player2_icon.visible = true;
                mc.waiting.visible = true;
                mc.loadingIcon.visible = false;
            }

            debugText = new TextField();
            debugText.textColor = 0x00FF00;
            debugText.background = true;
            debugText.backgroundColor = 0xCC000000;
            debugText.width = 350;
            debugText.height = 100;
            debugText.mouseEnabled = false;
            debugText.text = "=== LAN Debug ===";
            mc.addChild(debugText);

            debugIntervalId = setInterval(updateDebug, 1000);
            _pingIntervalId = setInterval(function():void
            {
                if (lanSocket != null && lanSocket.connected)
                {
                    lanSocket.send("PING");
                }
            }, 10000);

            lanSocket = sourceSocket;
            lanSocket.onMessage = onMessage;
            lanSocket.onError = onSocketError;
            lanSocket.onClose = onDisconnected;
        }

        override public function leave():void
        {
            if (_pingIntervalId != 0)
            {
                clearInterval(_pingIntervalId);
                _pingIntervalId = 0;
            }
            if (debugIntervalId != 0)
            {
                clearInterval(debugIntervalId);
                debugIntervalId = 0;
            }
            if (debugText != null && mc.contains(debugText))
            {
                mc.removeChild(debugText);
                debugText = null;
            }
        }

        private function setupButton(btn:*, clickHandler:Function):void
        {
            if (btn is flash.display.SimpleButton)
            {
                btn.addEventListener(MouseEvent.CLICK, clickHandler);
                return;
            }
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

        private function onMessage(line:String):void
        {
            if (line == "CLIENT_JOINED")
            {
                showClientJoined();
                return;
            }
            if (line == "CLIENT_DISCONNECTED")
            {
                mc.player2_icon.visible = false;
                mc.newOrContinuePanel.visible = false;
                mc.difficultyPanel.visible = false;
                if (role == "host")
                {
                    mc.waiting.visible = true;
                    mc.loadingIcon.visible = true;
                    mc.loadingIcon.play();
                }
                else
                {
                    if (lanSocket != null)
                    {
                        lanSocket.send("DISCONNECT");
                        lanSocket.close();
                        lanSocket = null;
                    }
                    role = null;
                    sourceSocket = null;
                    main.showScreen("coopScreen", false, true);
                }
                return;
            }
            if (line == "HOST_DISCONNECTED")
            {
                mc.player2_icon.visible = false;
                mc.newOrContinuePanel.visible = false;
                mc.difficultyPanel.visible = false;
                if (lanSocket != null)
                {
                    lanSocket.send("DISCONNECT");
                    lanSocket.close();
                    lanSocket = null;
                }
                role = null;
                sourceSocket = null;
                main.showScreen("coopScreen", false, true);
                return;
            }
            if (line.indexOf("WAIT_FOR_RECONNECT|") == 0)
            {
                mc.player2_icon.visible = false;
                mc.newOrContinuePanel.visible = false;
                mc.difficultyPanel.visible = false;
                mc.waiting.visible = true;
                mc.loadingIcon.visible = true;
                mc.loadingIcon.play();
                return;
            }
            if (line == "RESUMED")
            {
                showClientJoined();
                return;
            }
            if (line.indexOf("COOP_") == 0)
            {
                handleCoopMessage(line);
                return;
            }
        }

        private function showClientJoined():void
        {
            mc.waiting.visible = false;
            mc.loadingIcon.visible = false;
            mc.player2_icon.visible = true;
            mc.newOrContinuePanel.visible = true;
            if (main.campaign.saveGameExists())
            {
                mc.newOrContinuePanel.continueButton.visible = true;
            }
            else
            {
                mc.newOrContinuePanel.continueButton.visible = false;
            }
        }

        private function handleCoopMessage(msg:String):void
        {
            if (msg.indexOf("COOP_START_GAME|") == 0)
            {
                var parts:Array = msg.split("|");
                var diff:int = parseInt(parts[1]);
                var seed:int = parseInt(parts[2]);
                CampaignMenuScreen.coopMode = true;
                CampaignMenuScreen.coopLanSocket = sourceSocket;
                CampaignMenuScreen.coopDifficulty = diff;
                CampaignMenuScreen.coopGameSeed = seed;
                main.showScreen("mainMenu", false, true);
                return;
            }
            if (msg == "COOP_CONTINUE")
            {
                appendDebug("Continue game");
                main.campaign.load();
                main.showScreen("campaignMap", false, true);
                return;
            }
            if (msg == "COOP_HOST_STOPPED")
            {
                appendDebug("Host stopped the session");
                if (lanSocket != null)
                {
                    lanSocket.send("DISCONNECT");
                    lanSocket.close();
                    lanSocket = null;
                }
                role = null;
                sourceSocket = null;
                main.showScreen("coopScreen", false, true);
                return;
            }
        }

        private function appendDebug(msg:String):void
        {
            if (debugText != null)
            {
                debugText.appendText(msg + "\n");
                debugText.scrollV = debugText.maxScrollV;
            }
        }

        private function onDisconnected():void
        {
            appendDebug("DISCONNECTED");
        }

        private function onNewGame(e:*):void
        {
            mc.newOrContinuePanel.visible = false;
            mc.difficultyPanel.visible = true;
        }

        private function onContinue(e:*):void
        {
            main.campaign.load();
            CampaignMenuScreen.coopSolo = (mc.player2_icon.visible != true);
            if (role == "host" && mc.player2_icon.visible && lanSocket != null && lanSocket.connected)
            {
                lanSocket.send("DATA|COOP_CONTINUE");
            }
            if (role == "host" && lanSocket != null && lanSocket.connected)
            {
                lanSocket.send("HOST_BUSY|1");
            }
            main.showScreen("campaignMap", false, true);
        }

        private function onNormalDifficulty(e:*):void
        {
            onDifficultySelected(0);
        }

        private function onHardDifficulty(e:*):void
        {
            onDifficultySelected(1);
        }

        private function onInsaneDifficulty(e:*):void
        {
            onDifficultySelected(2);
        }

        private function onDifficultySelected(diff:int):void
        {
            var seed:int = Math.floor(Math.random() * 2147483647);
            CampaignMenuScreen.coopMode = true;
            CampaignMenuScreen.coopLanSocket = sourceSocket;
            CampaignMenuScreen.coopDifficulty = diff;
            CampaignMenuScreen.coopGameSeed = seed;
            CampaignMenuScreen.coopSolo = (mc.player2_icon.visible != true);
            if (mc.player2_icon.visible && lanSocket != null && lanSocket.connected)
            {
                lanSocket.send("DATA|COOP_START_GAME|" + diff + "|" + seed);
            }
            if (lanSocket != null && lanSocket.connected)
            {
                lanSocket.send("HOST_BUSY|1");
            }
            main.showScreen("mainMenu", false, true);
        }

        private function updateDebug():void
        {
            if (debugText == null || lanSocket == null) return;
            var connectedStr:String = lanSocket.connected ? "YES" : "NO";
            var hasClient:Boolean = mc.player2_icon.visible;
            debugText.text = "=== LAN Debug ===\n";
            debugText.appendText("Relay: " + connectedStr + "\n");
            debugText.appendText("Role: " + role + "\n");
            debugText.appendText("Client: " + (hasClient ? "YES" : "NO"));
        }

        private function onSocketError(msg:String):void
        {
            appendDebug("Socket error: " + msg);
        }

        private function onStopHosting(e:*):void
        {
            if (lanSocket != null)
            {
                lanSocket.send("DATA|COOP_HOST_STOPPED");
                lanSocket.send("DISCONNECT");
                lanSocket.close();
                lanSocket = null;
            }
            role = null;
            sourceSocket = null;
            main.showScreen("coopScreen", false, true);
        }
    }
}
