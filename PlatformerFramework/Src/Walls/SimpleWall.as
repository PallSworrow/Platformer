package Src.Walls {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import Box2D.Dynamics.b2Body;
	import Src.PhysicBody;
	
	
	public class SimpleWall extends PhysicBody{
		
		
		public function SimpleWall(X=null,Y=null) {
			// constructor code
			if(X) x=X;
			if(Y) y=Y;
			
			this.addEventListener(Event.ADDED_TO_STAGE, ini);
		}
		function ini(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, ini);
			physics = World.quickCreate(x+parent.parent.x ,y+parent.parent.y,width/2,height/2,rotation,'static',{friction: 10, restitution: 0});
			
		}
	}
	
}
