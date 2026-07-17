package com.brockw.stickwar.engine.projectile
{
   import com.brockw.stickwar.engine.*;
   import com.brockw.stickwar.engine.units.Unit;
   
   public class ElectricWallManager
   {
      
      private static const STUN_TICK_INTERVAL:int = 3;
      
      private static const GRID_SIZE:Number = 60;
      
      private static var walls:Array = [];
      
      private static var gridBuckets:Array = [];
      
      private static var bucketCount:int = 0;
      
      private static var lastRebuildFrame:int = -1;
      
      public static var frequency:int = -1;
      
      public function ElectricWallManager()
      {
         super();
      }
      
      public static function addWall(wall:ElectricWall, game:StickWar) : void
      {
         if(bucketCount == 0)
         {
            initGrid(game);
         }
         wall.spellMc.gotoAndStop(1);
         game.battlefield.addChild(wall);
         walls.push(wall);
      }
      
      public static function update(game:StickWar, frame:int) : void
      {
         if(walls.length == 0)
         {
            return;
         }
         if(frequency == -1)
         {
            frequency = int(game.xml.xml.Order.Units.magikill.electricWall.frequency);
         }
         var i:int = walls.length - 1;
         while(i >= 0)
         {
            var wall:ElectricWall = walls[i];
            wall.update(game);
            if(wall.isReadyForCleanup())
            {
               if(game.battlefield.contains(wall))
               {
                  game.battlefield.removeChild(wall);
               }
               game.projectileManager.returnElectricWall(wall);
               walls.splice(i,1);
            }
            i--;
         }
         if(walls.length == 0)
         {
            return;
         }
         var stunTick:Boolean = frame % STUN_TICK_INTERVAL == 0;
         var damageTick:Boolean = frame % frequency == 0;
         if(!stunTick && !damageTick)
         {
            return;
         }
         rebuildGrid(game,frame);
         var buckets:Object = buildWallBuckets();
         for each(var bucket in buckets)
         {
            if(bucket.isStunZone)
            {
               if(stunTick)
               {
                  processStunBucket(game,bucket);
               }
            }
            else if(damageTick)
            {
               processDamageBucket(game,bucket);
            }
         }
      }
      
      private static function buildWallBuckets() : Object
      {
         var buckets:Object = {};
         for each(var wall in walls)
         {
            var key:String = int(wall.px / GRID_SIZE) + "_" + wall.team.id + "_" + (wall.isStunZone ? "1" : "0") + "_" + (wall.controlledFriendlyFire ? "1" : "0");
            var bucket:Object = buckets[key];
            if(bucket == null)
            {
               bucket = {};
               bucket.count = 0;
               bucket.totalDamage = 0;
               bucket.px = wall.px;
               bucket.wallArea = wall.wallArea;
               bucket.team = wall.team;
               bucket.isStunZone = wall.isStunZone;
               bucket.controlledFriendlyFire = wall.controlledFriendlyFire;
               bucket.inflictors = [];
               bucket.maxRemainingFrames = 0;
               buckets[key] = bucket;
            }
            var _loc10_:Object = bucket;
            var _loc11_:Number = Number(_loc10_.count) + 1;
            _loc10_.count = _loc11_;
            bucket.totalDamage += wall.damageToDeal;
            if(bucket.isStunZone)
            {
               var remaining:int = wall.spellMc.totalFrames - wall.spellMc.currentFrame;
               if(remaining > bucket.maxRemainingFrames)
               {
                  bucket.maxRemainingFrames = remaining;
               }
            }
            if(bucket.controlledFriendlyFire && wall.inflictor != null)
            {
               var found:Boolean = false;
               for each(var inf in bucket.inflictors)
               {
                  if(inf.id == wall.inflictor.id)
                  {
                     found = true;
                     break;
                  }
               }
               if(!found)
               {
                  bucket.inflictors.push(wall.inflictor);
               }
            }
         }
         return buckets;
      }
      
      private static function isInflictor(unit:Unit, inflictors:Array) : Boolean
      {
         for each(var inf in inflictors)
         {
            if(unit == inf)
            {
               return true;
            }
         }
         return false;
      }
      
      private static function processDamageBucket(game:StickWar, bucket:Object) : void
      {
         var leftBucket:int = int(Math.max(0,(bucket.px - bucket.wallArea) / GRID_SIZE));
         var rightBucket:int = int(Math.min(bucketCount - 1,(bucket.px + bucket.wallArea) / GRID_SIZE));
         var b:int = leftBucket;
         while(b <= rightBucket)
         {
            var gridBucket:Array = gridBuckets[b];
            var j:int = 0;
            while(j < gridBucket.length)
            {
               var unit:Unit = gridBucket[j];
               if(unit.team != bucket.team || bucket.controlledFriendlyFire)
               {
                  if(!bucket.controlledFriendlyFire || !isInflictor(unit,bucket.inflictors) && !unit.isBossUnit && unit.type != Unit.U_STATUE)
                  {
                     if(Math.abs(unit.px - bucket.px) < bucket.wallArea)
                     {
                        unit.damage(Unit.D_NO_SOUND | Unit.D_NO_BLOOD,bucket.totalDamage,null);
                     }
                  }
               }
               j++;
            }
            b++;
         }
      }
      
      private static function processStunBucket(game:StickWar, bucket:Object) : void
      {
         var remainingFrames:int = int(bucket.maxRemainingFrames);
         if(remainingFrames <= 0)
         {
            return;
         }
         var leftBucket:int = int(Math.max(0,(bucket.px - bucket.wallArea) / GRID_SIZE));
         var rightBucket:int = int(Math.min(bucketCount - 1,(bucket.px + bucket.wallArea) / GRID_SIZE));
         var b:int = leftBucket;
         while(b <= rightBucket)
         {
            var gridBucket:Array = gridBuckets[b];
            var j:int = 0;
            while(j < gridBucket.length)
            {
               var unit:Unit = gridBucket[j];
               if(unit.team != bucket.team || bucket.controlledFriendlyFire)
               {
                  if(!bucket.controlledFriendlyFire || !isInflictor(unit,bucket.inflictors) && !unit.isBossUnit && unit.type != Unit.U_STATUE)
                  {
                     if(Math.abs(unit.px - bucket.px) < bucket.wallArea)
                     {
                        if(unit.stunTimeLeft < remainingFrames)
                        {
                           unit.damage(Unit.D_NO_SOUND | Unit.D_NO_BLOOD,bucket.totalDamage,null);
                           unit.stun(remainingFrames);
                        }
                     }
                  }
               }
               j++;
            }
            b++;
         }
      }
      
      private static function initGrid(game:StickWar) : void
      {
         bucketCount = Math.ceil(game.map.width / GRID_SIZE) + 1;
         gridBuckets = [];
         var i:int = 0;
         while(i < bucketCount)
         {
            gridBuckets.push([]);
            i++;
         }
      }
      
      private static function rebuildGrid(game:StickWar, frame:int) : void
      {
         if(frame == lastRebuildFrame)
         {
            return;
         }
         lastRebuildFrame = frame;
         var i:int = 0;
         while(i < bucketCount)
         {
            gridBuckets[i].length = 0;
            i++;
         }
         for each(var unit in game.teamA.units)
         {
            addToGrid(unit);
         }
         for each(unit in game.teamB.units)
         {
            addToGrid(unit);
         }
      }
      
      private static function addToGrid(unit:Unit) : void
      {
         var idx:int = int(unit.px / GRID_SIZE);
         if(idx < 0)
         {
            idx = 0;
         }
         if(idx >= bucketCount)
         {
            idx = bucketCount - 1;
         }
         gridBuckets[idx].push(unit);
      }
   }
}

