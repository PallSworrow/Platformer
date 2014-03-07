package Src {
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import Src.Units.TestUnit;
	
	public class MainCharacter {
		public static var inst:Character;
		static var pressedKeys:Object = new Object();
		// keys: 0-1   codes: 48 - 57
		//space: 32
		static var aimKey:int=16;//shift
		static var attackKey:int=32;
		
		public function MainCharacter(char:Character) {
			// constructor code
			inst= char;
			
			
			World.inst.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			World.inst.stage.addEventListener(KeyboardEvent.KEY_UP,keyReleased);
		}
		function keyPressed(e:KeyboardEvent):void
		{
			pressedKeys[e.keyCode] = true;
			trace(e.keyCode);
			
		}
		function keyReleased(e:KeyboardEvent):void
		{
			pressedKeys[e.keyCode] = false;
		}
		public static function control():void
		{
			World.inst.x = Main.Width/2 - inst.x;
			if(pressedKeys[Keyboard.UP])
			{
				inst.setAction('jump');
			}
			else if(pressedKeys[Keyboard.DOWN])
			{
				trace('seat');
			}
			
			if(pressedKeys[aimKey])
			{
				inst.aiming = true;
			}
			else
			{
				inst.aiming = false;
			}
			
			if(pressedKeys[attackKey])
			{
				inst.attack = true;
			}
			else
			{
				inst.attack = false;
			}
			
			if(pressedKeys[Keyboard.LEFT])
			{
				inst.walkSwitch('Left');
				
			}
			else if(pressedKeys[Keyboard.RIGHT])
			{
				inst.walkSwitch('Right');
			}
			else
			{
				inst.walkSwitch('Stop');
			}
			
			
		}
		

	}
	
}
