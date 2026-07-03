package com.brockw.stickwar.engine.Team.Order
{
   import com.brockw.stickwar.engine.Ai.ArcherAi;
   import com.brockw.stickwar.engine.Ai.command.*;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.Team.*;
   import com.brockw.stickwar.engine.units.Archer;
   
   public class CastleArchers extends CastleDefence
   {
      
      private var facingDirection:int;
      
      public function CastleArchers(game:StickWar, team:Team, facingDirection:int = 0)
      {
         super(game,team);
         units = [];
         this.facingDirection = facingDirection != 0 ? facingDirection : team.direction;
      }
      
      override public function update(game:StickWar) : void
      {
         var nArchers:int = 0;
         if(team.tech.isResearched(Tech.CASTLE_ARCHER_5))
         {
            nArchers = 5;
         }
         else if(team.tech.isResearched(Tech.CASTLE_ARCHER_4))
         {
            nArchers = 4;
         }
         else if(team.tech.isResearched(Tech.CASTLE_ARCHER_3))
         {
            nArchers = 3;
         }
         else if(team.tech.isResearched(Tech.CASTLE_ARCHER_2))
         {
            nArchers = 2;
         }
         else if(team.tech.isResearched(Tech.CASTLE_ARCHER_1))
         {
            nArchers = 1;
         }
          if(units.length < nArchers)
          {
             this.addUnit();
          }
          super.update(game);
      }
      
      override public function addUnit() : void
      {
         var newArcher:Archer = null;
         newArcher = new Archer(game);
         newArcher.ai = new ArcherAi(newArcher);
         newArcher.team = team;
          newArcher.isCastleArcher = true;
          newArcher.assignedSide = 1;
          newArcher.faceDirection(this.facingDirection);
          newArcher.init(game);
         newArcher.flyingHeight = 390;
         newArcher.pz = -newArcher.flyingHeight;
         newArcher.ai.init();
         newArcher.py = game.map.height / 2 * units.length / game.xml.xml.Order.Tech.castleArchers.num;
          newArcher.y = newArcher.py + newArcher.pz;
         newArcher.px = team.homeX + this.facingDirection * 180 - this.facingDirection * units.length * 8;
         newArcher.x = newArcher.px;
         var m:HoldCommand = new HoldCommand(game);
         newArcher.ai.setCommand(game,m);
         units.push(newArcher);
         game.battlefield.addChild(newArcher);
      }
   }
}
