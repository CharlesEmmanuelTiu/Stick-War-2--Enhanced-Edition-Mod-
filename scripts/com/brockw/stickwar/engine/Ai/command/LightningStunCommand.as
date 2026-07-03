package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.multiplayer.moves.*;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;

   public class LightningStunCommand extends UnitCommand
   {
      public static var actualButtonBitmap:Bitmap;

      private var area:Number;

      private var range:Number;

      public function LightningStunCommand(game:StickWar)
      {
         super();
         this.game = game;
         type = UnitCommand.LIGHTNING_STUN;
         hotKey = 87;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_MAGIKILL;
         isSingleSpell = true;
         requiresMouseInput = true;
         if(actualButtonBitmap == null)
         {
            var bmd:BitmapData = new MagikillWall();
            var ct:ColorTransform = new ColorTransform();
            ct.color = 0xFFD700;
            bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
            actualButtonBitmap = new Bitmap(bmd);
         }
         this.buttonBitmap = actualButtonBitmap;
         cursor = new electricWallCursor();
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.magikill.electricWall);
            this.area = game.xml.xml.Order.Units.magikill.electricWall.area;
            this.range = game.xml.xml.Order.Units.magikill.electricWall.range;
            var techXml:XMLList = game.xml.xml.Order.Tech.magikillLightningStun;
            var statsXml:XMLList = game.xml.xml.Order.Units.magikill.electricWall;
             var customXml:XML = <lightningStun>
                <name>{techXml.child("name").text()}</name>
                <info>{techXml.child("tip").text()}</info>
                <cooldown>{statsXml.cooldown}</cooldown>
               <gold>{statsXml.gold}</gold>
               <mana>{statsXml.mana}</mana>
               <population>{statsXml.population}</population>
            </lightningStun>;
            this.xmlInfo = new XMLList(customXml);
         }
      }

      override public function cleanUpPreClick(canvas:Sprite) : void
      {
         super.cleanUpPreClick(canvas);
         if(canvas.contains(cursor))
         {
            canvas.removeChild(cursor);
         }
      }

      override public function drawCursorPreClick(canvas:Sprite, gameScreen:GameScreen) : Boolean
      {
         while(canvas.numChildren != 0)
         {
            canvas.removeChildAt(0);
         }
         canvas.addChild(cursor);
         cursor.x = gameScreen.game.battlefield.mouseX - this.area / 2;
         cursor.y = 0;
         cursor.width = this.area;
         cursor.height = gameScreen.game.map.height;
         if(cursor.y + cursor.height < 0)
         {
            cursor.alpha = 1 - Math.abs(cursor.y) / 200;
         }
         else
         {
            cursor.alpha = 1;
         }
         cursor.gotoAndStop(1);
         this.drawRangeIndicators(canvas,this.range,true,gameScreen);
         return true;
      }

      override public function drawCursorPostClick(canvas:Sprite, game:GameScreen) : Boolean
      {
         super.drawCursorPostClick(canvas,game);
         return true;
      }

      override public function prepareNetworkedMove(gameScreen:GameScreen) : *
      {
         var unit:String = null;
         var u:UnitMove = new UnitMove();
         u.moveType = this.type;
         for(unit in gameScreen.team.units)
         {
            if(Unit(gameScreen.team.units[unit]).selected && gameScreen.team.units[unit] is Magikill && Magikill(gameScreen.team.units[unit]).stunCooldown() == 0)
            {
               if(this.intendedEntityType == -1 || this.intendedEntityType == gameScreen.team.units[unit].type)
               {
                  u.units.push(gameScreen.team.units[unit].id);
               }
               break;
            }
         }
         u.arg0 = gameScreen.game.battlefield.mouseX;
         u.arg1 = Math.max(0,Math.min(gameScreen.game.map.height,gameScreen.game.battlefield.mouseY));
         if(gameScreen.userInterface.keyBoardState.isShift)
         {
            u.queued = true;
         }
         gameScreen.doMove(u,team.id);
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Magikill(entity).stunCooldown();
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }

      override public function inRange(entity:Entity) : Boolean
      {
         return Math.pow(realX - entity.px,2) + Math.pow(realY - entity.py,2) < Math.pow(this.range,2);
      }
   }
}
