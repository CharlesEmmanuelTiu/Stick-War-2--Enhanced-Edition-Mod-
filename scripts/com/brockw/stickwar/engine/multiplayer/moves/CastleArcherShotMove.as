package com.brockw.stickwar.engine.multiplayer.moves
{
   import com.brockw.simulationSync.Move;
   import com.brockw.simulationSync.Simulation;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.Team.CastleDefence;
   import com.brockw.stickwar.engine.Team.Team;
   import com.brockw.stickwar.engine.units.Unit;
   import com.smartfoxserver.v2.entities.data.SFSObject;
   
   public class CastleArcherShotMove extends Move
   {
      
      public static const KIND_ARROW:int = 0;
      
      public static const KIND_GUTS:int = 1;
      
      private var _teamId:int;
      
      private var _castleIndex:int;
      
      private var _targetUnitId:int;
      
      private var _kind:int;
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _rotation:Number;
      
      private var _velocity:Number;
      
      private var _targetY:Number;
      
      private var _dy:Number;
      
      private var _damage:Number;
      
      private var _poison:Number;
      
      private var _poisonDamage:Number;
      
      private var _isFire:Boolean;
      
      private var _area:Number;
      
      private var _areaDamage:Number;
      
      public function CastleArcherShotMove()
      {
         super();
         type = Commands.CASTLE_SHOT_MOVE;
         this._teamId = 0;
         this._castleIndex = -1;
         this._targetUnitId = -1;
         this._kind = 0;
         this._x = 0;
         this._y = 0;
         this._rotation = 0;
         this._velocity = 0;
         this._targetY = 0;
         this._dy = 0;
         this._damage = 0;
         this._poison = 0;
         this._poisonDamage = 0;
         this._isFire = false;
         this._area = 0;
         this._areaDamage = 0;
      }
      
      public static function castleUnitIndex(team:Team, unit:Unit) : int
      {
         var i:int = 0;
         if(team == null || unit == null || team.castleDefence == null || team.castleDefence.units == null)
         {
            return -1;
         }
         i = 0;
         while(i < team.castleDefence.units.length)
         {
            if(team.castleDefence.units[i] == unit)
            {
               return i;
            }
            i++;
         }
         return -1;
      }
      
      override public function toString() : String
      {
         var s:String = super.toString();
         s += this._teamId + " ";
         s += this._castleIndex + " ";
         s += this._targetUnitId + " ";
         s += this._kind + " ";
         s += this._x + " ";
         s += this._y + " ";
         s += this._rotation + " ";
         s += this._velocity + " ";
         s += this._targetY + " ";
         s += this._dy + " ";
         s += this._damage + " ";
         s += this._poison + " ";
         s += this._poisonDamage + " ";
         s += (this._isFire ? 1 : 0) + " ";
         s += this._area + " ";
         s += this._areaDamage + " ";
         return s;
      }
      
      override public function fromString(s:Array) : Boolean
      {
         super.fromString(s);
         this._teamId = int(s.shift());
         this._castleIndex = int(s.shift());
         this._targetUnitId = int(s.shift());
         this._kind = int(s.shift());
         this._x = Number(s.shift());
         this._y = Number(s.shift());
         this._rotation = Number(s.shift());
         this._velocity = Number(s.shift());
         this._targetY = Number(s.shift());
         this._dy = Number(s.shift());
         this._damage = Number(s.shift());
         this._poison = Number(s.shift());
         this._poisonDamage = Number(s.shift());
         this._isFire = int(s.shift()) == 1;
         this._area = Number(s.shift());
         this._areaDamage = Number(s.shift());
         return true;
      }
      
      override public function readFromSFSObject(o:SFSObject) : void
      {
         readBasicsSFSObject(o);
         this._teamId = o.getInt("t");
         this._castleIndex = o.getInt("c");
         this._targetUnitId = o.getInt("u");
         this._kind = o.getInt("k");
         this._x = o.getDouble("x");
         this._y = o.getDouble("y");
         this._rotation = o.getDouble("r");
         this._velocity = o.getDouble("v");
         this._targetY = o.getDouble("ty");
         this._dy = o.getDouble("dy");
         this._damage = o.getDouble("d");
         this._poison = o.getDouble("p");
         this._poisonDamage = o.getDouble("pd");
         this._isFire = o.getBool("f");
         this._area = o.getDouble("a");
         this._areaDamage = o.getDouble("ad");
      }
      
      override public function writeToSFSObject(o:SFSObject) : void
      {
         writeBasicsSFSObject(o);
         o.putInt("t",this._teamId);
         o.putInt("c",this._castleIndex);
         o.putInt("u",this._targetUnitId);
         o.putInt("k",this._kind);
         o.putDouble("x",this._x);
         o.putDouble("y",this._y);
         o.putDouble("r",this._rotation);
         o.putDouble("v",this._velocity);
         o.putDouble("ty",this._targetY);
         o.putDouble("dy",this._dy);
         o.putDouble("d",this._damage);
         o.putDouble("p",this._poison);
         o.putDouble("pd",this._poisonDamage);
         o.putBool("f",this._isFire);
         o.putDouble("a",this._area);
         o.putDouble("ad",this._areaDamage);
      }
      
      override public function execute(game:Simulation) : void
      {
         var g:StickWar = null;
         var t:Team = null;
         var u:Unit = null;
         g = game as StickWar;
         if(g == null)
         {
            return;
         }
         t = g.teamA;
         if(t == null || t.id != this._teamId)
         {
            t = g.teamB;
         }
         if(t == null || t.castleDefence == null || t.castleDefence.units == null)
         {
            return;
         }
         if(this._castleIndex < 0 || this._castleIndex >= t.castleDefence.units.length)
         {
            return;
         }
         u = t.castleDefence.units[this._castleIndex] as Unit;
         if(u == null || !u.isAlive())
         {
            return;
         }
         if(this._kind == KIND_ARROW)
         {
            g.projectileManager.initArrow(this._x,this._y,this._rotation,this._velocity,this._targetY,this._dy,u,this._damage,this._poison,this._isFire,this._area,this._areaDamage);
         }
         else
         {
            g.projectileManager.initGuts(this._x,this._y,this._rotation,this._velocity,this._targetY,this._dy,this._poisonDamage,u);
         }
      }
      
      public function get teamId() : int
      {
         return this._teamId;
      }
      
      public function set teamId(value:int) : void
      {
         this._teamId = value;
      }
      
      public function get castleIndex() : int
      {
         return this._castleIndex;
      }
      
      public function set castleIndex(value:int) : void
      {
         this._castleIndex = value;
      }
      
      public function get targetUnitId() : int
      {
         return this._targetUnitId;
      }
      
      public function set targetUnitId(value:int) : void
      {
         this._targetUnitId = value;
      }
      
      public function get kind() : int
      {
         return this._kind;
      }
      
      public function set kind(value:int) : void
      {
         this._kind = value;
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(value:Number) : void
      {
         this._x = value;
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(value:Number) : void
      {
         this._y = value;
      }
      
      public function get rotation() : Number
      {
         return this._rotation;
      }
      
      public function set rotation(value:Number) : void
      {
         this._rotation = value;
      }
      
      public function get velocity() : Number
      {
         return this._velocity;
      }
      
      public function set velocity(value:Number) : void
      {
         this._velocity = value;
      }
      
      public function get targetY() : Number
      {
         return this._targetY;
      }
      
      public function set targetY(value:Number) : void
      {
         this._targetY = value;
      }
      
      public function get dy() : Number
      {
         return this._dy;
      }
      
      public function set dy(value:Number) : void
      {
         this._dy = value;
      }
      
      public function get damage() : Number
      {
         return this._damage;
      }
      
      public function set damage(value:Number) : void
      {
         this._damage = value;
      }
      
      public function get poison() : Number
      {
         return this._poison;
      }
      
      public function set poison(value:Number) : void
      {
         this._poison = value;
      }
      
      public function get poisonDamage() : Number
      {
         return this._poisonDamage;
      }
      
      public function set poisonDamage(value:Number) : void
      {
         this._poisonDamage = value;
      }
      
      public function get isFire() : Boolean
      {
         return this._isFire;
      }
      
      public function set isFire(value:Boolean) : void
      {
         this._isFire = value;
      }
      
      public function get area() : Number
      {
         return this._area;
      }
      
      public function set area(value:Number) : void
      {
         this._area = value;
      }
      
      public function get areaDamage() : Number
      {
         return this._areaDamage;
      }
      
      public function set areaDamage(value:Number) : void
      {
         this._areaDamage = value;
      }
   }
}