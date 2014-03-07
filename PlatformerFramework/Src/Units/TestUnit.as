package Src.Units {
	import Src.Character;
	
	public class TestUnit extends Character{
		//parameters to set unique view of unit. are called from frames of unit parts(arms, legs ...)
		var obj =  
		{
			
			param: 2
			
			
		};
		public function TestUnit() {
			// constructor code
			this.jumpPower = 2000;
			moveSpeed = 6;
			this.Sets = obj;
			trace('constructor '+ Sets.param);
			
		}

	}
	
}
