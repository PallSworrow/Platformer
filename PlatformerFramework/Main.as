package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import Src.Units.TestUnit;
	import Src.MainCharacter;
	import Src.Walls.SimpleWall;
	import Src.Character;
	import Src.PhysicsApi.ConvertPngs;
	public class Main extends MovieClip {
		public static var Height:int=500;
		public static var Width:int=800;
		
		var player:MainCharacter;
		public function Main() {
			// constructor code
			this.addEventListener(Event.ENTER_FRAME,update);
			World.inst = new World();
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			this.addChild(World.inst);
			//player = new MainCharacter();
			//var a = new SimpleWall(250,380);
			
			
		}
		function init(e)
		{
			World.loadLevel();
		}
		function update(e:Event):void
		{
			if(World.inst) World.inst.update();
			MainCharacter.control();
			
		}
	}
	
}
