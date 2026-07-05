package com.brockw.game
{
   import com.brockw.simulationSync.Simulation;
   
   public class Pool
   {
      
      private var free:Vector.<Object>;
      
      private var fIndex:int;
      
      private var poolClass:Class;
      
      private var capacity:int;
      
      private var game:Simulation;
      
      public function Pool(capacity:int, c:Class, game:Simulation)
      {
         super();
         this.game = game;
         this.capacity = capacity;
         this.poolClass = c;
         this.fIndex = 0;
         this.free = new Vector.<Object>(capacity,false);
         var i:int = 0;
         while(i < capacity)
         {
            this.free[i] = new c(game);
            i++;
         }
         this.fIndex = 0;
      }
      
      public function cleanUp() : void
      {
         var i:int = 0;
         while(i < this.free.length)
         {
            if(this.free[i] != null)
            {
               this.free[i].cleanUp();
               this.free[i] = null;
            }
            else
            {
               trace("that things would have happened");
            }
            i++;
         }
      }
      
      public function getItem() : Object
      {
         var i:int = 0;
         if(this.fIndex >= this.capacity)
         {
            this.free = new Vector.<Object>(2 * this.capacity,false);
            i = this.capacity;
            while(i < 2 * this.capacity)
            {
               this.free[i] = new this.poolClass(this.game);
               i++;
            }
            this.capacity *= 2;
         }
         if(this.fIndex < this.capacity)
         {
            ++this.fIndex;
            return this.free[this.fIndex - 1];
         }
         return null;
      }
      
      public function returnItem(item:Object) : void
      {
         if(this.fIndex > 0)
         {
            --this.fIndex;
            this.free[this.fIndex] = item;
         }
      }
   }
}

