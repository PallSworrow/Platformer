package  {
	import flash.display.MovieClip;
	import Box2D.Collision.b2Bound;  
	import Box2D.Collision.b2DistanceInput;  
	import Box2D.Dynamics.b2World;  
	import Box2D.Common.Math.b2Vec2;  
	import Box2D.Dynamics.b2BodyDef;  
	import Box2D.Dynamics.b2Body;  
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
    import Box2D.Dynamics.b2Fixture;  
    import Box2D.Dynamics.b2FixtureDef;  
    import Box2D.Dynamics.b2DebugDraw; 
    import flash.display.Sprite;
    import Src.PhysicsApi.Collisions;
    import Src.MainCharacter;
    import Src.PhysicsApi.ConvertPngs;
    import Src.StageManager;
    import Src.Levels.TestLevel;
	import Src.Character;
	
	public class World extends MovieClip{
		public var sim:b2World;
		public static var inst:World;
		
		//constants:
		public static var PXperM:int=30;
		var timeStep:Number = 1 / 30;  
      	var velocityIterations:int = 6;  
     	var positionIterations:int = 2;  
		
		//layers:
		public var LevelBox:MovieClip= new MovieClip();
		
		static var currentStage:StageManager;
		
		
		
		public function World() {
			// constructor code
			addChild(LevelBox);
			sim = new b2World(new b2Vec2(0,10),true);
			sim.SetContactListener(new Collisions);
			//test debug:
			var debugSprite:Sprite = new Sprite();
		   addChild(debugSprite);  
		   var debugDraw:b2DebugDraw = new b2DebugDraw();  
		   debugDraw.SetSprite(debugSprite);
		   debugDraw.SetDrawScale(World.PXperM);  
		   debugDraw.SetLineThickness(1.0);  
		   debugDraw.SetAlpha(1);  
		   debugDraw.SetFillAlpha(0.4);  
		   debugDraw.SetFlags(b2DebugDraw.e_shapeBit);  
		   sim.SetDebugDraw(debugDraw);
		   
							 
		  
			
		}
		public static function loadLevel():void
		{
			/*inst.curLevel = new ['Level()'];
			inst.LevelBox.addChild(inst.curLevel);
			new ConvertPngs(inst.curLevel);
			new MainCharacter();*/
			currentStage = new StageManager();
			inst.addChild(currentStage);
			currentStage.LoadLevel(new TestLevel());
		}
		
		
		public function update():void
		{
			
			//trace('step');
			sim.Step(timeStep, velocityIterations, positionIterations);
			sim.ClearForces();
			sim.DrawDebugData();
			
			Character.Control();
			
			if(currentStage) currentStage.moving();
			for (var bodyList:b2Body = sim.GetBodyList(); bodyList; bodyList = bodyList.GetNext() ) 
      		 { 
			 	if(bodyList.GetUserData() == "DELETE"/* || 
				   bodyList.GetPosition().x*PXperM + World.inst.x> Main.Width +2000 ||
				   bodyList.GetPosition().x*PXperM + World.inst.x < -2000 ||
				   bodyList.GetPosition().y*PXperM + World.inst.y > Main.Height +2000 ||
				   bodyList.GetPosition().y*PXperM + World.inst.y < -2000*/  )
				{
       				trace('delete');
					sim.DestroyBody(bodyList);
				}
       			
			}
			
		}
		
		
		
		
		
		
		
		
		public static function createBody(def:b2BodyDef, fix:b2FixtureDef):b2Body//used in character
		{
			var body:b2Body;
			body =  inst.sim.CreateBody(def);
			body.CreateFixture(fix);
			
			return body;
		}
		public static function quickCreate(X:int, Y:int, W:int,H:int, R:int,type:String,param:Object=null):b2Body
		{
			var form:String;
			if(!param ) form='box';
			else if (!param.form) form = 'box';
			else form = param.form;
			
			var bodyDef:b2BodyDef = new b2BodyDef();//тело - геометрия
			var bodyF:b2FixtureDef = new b2FixtureDef(); //форма-физика
			
			if(type == 'dynamic')
			{
				bodyDef.type = b2Body.b2_dynamicBody; 
				bodyDef.linearVelocity.x = 0;
				bodyDef.linearVelocity.y = 0;
				
				if(param.disabled == true) bodyDef.active = false;
				
				if(param.sleep == true) bodyDef.awake = false;
				
				if(param.angularDamping) bodyDef.angularDamping = param.angularDamping;
				
				bodyF.density = param.density;
			}
			else if(type == 'static')
			{
				bodyDef.type = b2Body.b2_staticBody; 
			}
			
			
			bodyDef.position.Set( X/World.PXperM, Y/World.PXperM);
			bodyDef.angle =  R;
			//bodyDef.position.Set(10,10);
			//trace('rapam:', param.friction);
			
			if(param.restitution) bodyF.restitution = param.restitution;
			if(param.friction)bodyF.friction = param.friction
			if(param.isSensor) bodyF.isSensor = true;
			if(param.groupIndex)
			{
				bodyF.filter.groupIndex = param.groupIndex;
			}
			//bodyF.filter.groupIndex = -1;
			if(form == "ball")
			{
				var circle:b2CircleShape = new b2CircleShape();
				circle.SetRadius(W*0.5/PXperM);
				
				bodyF.shape = circle;
				
			}
			else if(form == "box")
			{
				var dynamicBox:b2PolygonShape = new b2PolygonShape(); 
				dynamicBox.SetAsBox(W/PXperM,H/PXperM);  
				bodyF.shape = dynamicBox;  
				
			}
			
			
			var body:b2Body = inst.sim.CreateBody(bodyDef);
			body.CreateFixture(bodyF);
			
			if(param.userData) body.SetUserData(param.userData);
			return body;
			
			
			
		}
	}
	
}
