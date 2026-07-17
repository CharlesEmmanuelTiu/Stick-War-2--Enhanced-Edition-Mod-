package com.brockw.stickwar.engine
{
   public class Rain extends Entity
   {
      
      internal var game:StickWar;
      
      internal var rain:Array;
      
      internal var numParticles:int;
      
      public function Rain(game:StickWar, n:int)
      {
         super();
         this.rain = [];
         this.game = game;
         this.numParticles = n;
         this.init(game);
         py = game.map.height;
      }
      
      public function init(game:StickWar) : void
      {
         var r:RainDrop = null;
         var i:* = 0;
         while(i < this.numParticles)
         {
            r = new RainDrop(game);
            addChild(r);
            this.rain.push(r);
            i++;
         }
      }
      
      public function setParticleCount(n:int) : void
      {
         var r:RainDrop = null;
         for each(r in this.rain)
         {
            if(r.parent != null)
            {
               r.parent.removeChild(r);
            }
         }
         this.rain = [];
         this.numParticles = n;
         this.init(this.game);
      }
      
      public function update(game:StickWar) : void
      {
         x = game.battlefield.x;
         var i:* = 0;
         while(i < this.numParticles)
         {
            this.rain[i].update(game);
            i++;
         }
      }
   }
}

