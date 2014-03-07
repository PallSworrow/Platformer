package Src {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import Src.Units.*;
	import Box2D.Collision.Shapes.b2Shape;
	import Src.PhysicsApi.Sensor;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import Box2D.Dynamics.Joints.b2LineJointDef;

	public class Character extends MovieClip{
		 //character global funcs:
		 public static var arr:Array = new Array();
		public static function findSet(finder:MovieClip, reqSetting:String)//returns string or int or bool
		{
			
			var obj = finder.parent;
			trace('parent is found');
			var errPreventer:int = 0;
			while(!(obj is Character)) 
			{
				obj = obj.parent;
				errPreventer++;
				if(errPreventer > 4)
				{
					return 1;///wrong parameters. output error warrning
				}
			}
			
			var p:Character = obj;
			trace('finding sets:'+p.Sets.param);
			return p.Sets[reqSetting];
		}
		
		
		

		// charecter sets:
		public var Sets:Object;
		
		//main:
		/*public var bootfix:Boolean = true;
		public var weapon:int=1;
		public var cannon:int=2;
		public var helm:int = 1;
		public var hair:int = 1;
		public var eyes:int = 1;
		public var body:int = 1;
		public var tits:int = 1;
		public var spads:int= 2;//наплечники 
		public var armu:int = 2;//upper 
		public var arml:int = 2;//lower
		public var legs:int = 1;
		public var feet:int = 2;
		
		public var tone:int = 1;
		public var mess:int = 2;
		
		*/
		
		
		var dirrection:int=1;
		
		//dirty:
		/*var messy:int = 0;
		var messyhead:int = 0;
		var messymouth:int = 0;
		var messyhelm:int = 0;
		var messytits:int = 0;
		var messyass:int = 0;
		var messylegs:int = 0;
		var messycalves:int = 0;
		var messyarms:int = 0;
		var messyback:int = 0;
		var messytail:int = 0;
		var messystomach:int = 0;
		var messypelvis:int = 0;
		*/
		///physic engine
		public var circle:b2Body;
		public var sensor:Sensor;
		var middleBox:b2Body;
		
		public var physics:b2Joint;
		public var W:int;
		public var H:int;
		
		///control logic:
		var weaponState:String = 'hidden';
		
		var mainAnim:String = 'custom';//seat, spesial
		var specialAnim:String;
		var legsAnim:String = 'wait';//go, run, seat, jump
		var torsoAnim:String = 'wait';//seat, jump, getWeap, putWeap, aim, pushButton....
		
		var realTA:String;
		var realLA:String;
		var realSA:String;
		
		
		var canJump:Boolean = true;
		var jumpDelay:int = 0;//0 - on the floor
		
		
		var inAir:Boolean = false;
		
		var isWalking:Boolean=false;
		public var aiming:Boolean = false;
		public var attack:Boolean = false;
	
		//movement params:
		public var jumpPower:int=0;
		public var moveSpeed:int=0;
		
		public function Character() {
			W = this.width;
			H  = this.height;
			trace(W+'='+width);
			x=200;
			y=200;
			
			// constructor code
			arr.push(this);
			addEventListener(Event.ADDED_TO_STAGE,applyPhysics);
			trace('prototypeTest:'+(this is TestUnit));
		}
		
		
		
		
		
		function applyPhysics(e):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,applyPhysics);
			
			var obj = parent;
			
			var errPreventer:int = 0;
			var offsetX:int=World.inst.x;
			var offsetY:int=World.inst.y;
			
			trace(offsetX);
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			var bodyF:b2FixtureDef = new b2FixtureDef();
			var shape:b2PolygonShape = new b2PolygonShape(); 
			
			//create main box:
			bodyDef.type = b2Body.b2_dynamicBody; 
			bodyDef.linearVelocity.x = 0;
			bodyDef.linearVelocity.y = 0;
			bodyDef.allowSleep = false;
			bodyDef.fixedRotation = true;
			
			
			bodyF.density = 25;
			bodyF.restitution = 0;
			bodyF.filter.groupIndex = -4;
			bodyF.friction =0;
			//bodyF.isSensor = true;
			
			shape.SetAsBox(this.W*0.5/World.PXperM, (this.H*0.5 - W/4)/World.PXperM);  
			bodyF.shape = shape; 
			
			bodyDef.position.Set( (offsetX+this.x)/World.PXperM, (offsetY+this.y - this.W/4)/World.PXperM);
			
			middleBox = World.createBody(bodyDef,bodyF);
			//trace(middleBox.GetPosition().x);
			
			bodyDef = new b2BodyDef();
			bodyF = new b2FixtureDef();
			var circleShape:b2CircleShape = new b2CircleShape(); 
			
			bodyDef.type = b2Body.b2_dynamicBody; 
			bodyDef.linearVelocity.x = 0;
			bodyDef.linearVelocity.y = 0;
			bodyDef.allowSleep = false;
			//bodyDef.fixedRotation = true;
			///bodyDef.angularDamping = 10;
			
			bodyF.density = 25;
			bodyF.restitution = 0;
			bodyF.friction =10;
			
			//bodyF.filter.groupIndex = -4;
			//bodyF.isSensor = true;
			
			circleShape.SetRadius((this.W/2)/World.PXperM);
			bodyF.shape = circleShape;
			
			bodyDef.position.Set( (offsetX+this.x)/World.PXperM, (offsetY+this.y+this.H/2 - this.W/2)/World.PXperM);
			
			circle = World.createBody(bodyDef,bodyF);
			
			
			
			
			var jointDef:b2LineJointDef = new b2LineJointDef();
			jointDef.Initialize( middleBox, circle,circle.GetWorldCenter(), new b2Vec2(0,1));
			jointDef.enableLimit = true;
			jointDef.collideConnected = false;
			
			var joint:b2Joint = World.inst.sim.CreateJoint(jointDef);
			//sensor = new Sensor(circle);
			//making a sensor body
			bodyF = new b2FixtureDef();
			shape = new b2PolygonShape(); 
			
			//create main box:
			bodyDef.type = b2Body.b2_dynamicBody; 
			bodyDef.linearVelocity.x = 0;
			bodyDef.linearVelocity.y = 0;
			//bodyDef.allowSleep = false;
			bodyDef.fixedRotation = true;
			
			bodyF.density = 0;
			/*
			bodyF.restitution = 0;
			bodyF.filter.groupIndex = -4;
			//bodyF.friction =;*/
			bodyF.isSensor = true;
			
			shape.SetAsBox(this.W*0.25/World.PXperM, W*0.25/World.PXperM);  
			bodyF.shape = shape; 
			
			bodyDef.position.Set( (offsetX+this.x)/World.PXperM, (offsetY+this.y + this.H/2.6)/World.PXperM);
			
			var sens:b2Body = World.createBody(bodyDef,bodyF);
			
			jointDef = new b2LineJointDef();
			jointDef.Initialize( middleBox, sens,sens.GetWorldCenter(), new b2Vec2(0,1));
			jointDef.enableLimit = true;
			jointDef.collideConnected = false;
			
			joint = World.inst.sim.CreateJoint(jointDef);
			sensor = new Sensor(sens);
			
			//circle.SetUserData(this);
			//middleBox.SetUserData(this);
		}
		public function setPos(posX:int,posY:int):Boolean//return false if imposible
		{
			return false;
		}
		
		public function walkSwitch(val:String):void
		{
			switch(val)
			{
				case 'Right':
						if(sensor.contacts >1) 
						{
							go(moveSpeed);
							
						}
						else 
						{
							go(0);
							push(moveSpeed/2);
						}
						isWalking = true;
						
				break;
					
				case 'Left':
						if(sensor.contacts >1)
						{
							
							go(-moveSpeed);
						}
						else 
						{
							go(0);
							push(-moveSpeed/2);
						}
						isWalking = true;
				break;
			
				default:
					go(0);
					isWalking = false;
					
				break;
			}
		}
		
		public function setAction(act:String):void
		{
			//trace('setAction: '+act);
			switch(act)
			{
				
				case 'prepareJump':
					jumpPower += 20;
				break;
				
				case 'jump':
				
				if(sensor.contacts >1 && jumpDelay == 0)
				{
					jump();
					//go(0);
					jumpDelay = 4;
					inAir = true;
					//jumpPower = 0;
				}
				break;
				
				
				
				
				
				
				
			}
		}
		public static function Control():void
		{
			for(var i:int = arr.length-1; i>=0;i--)
			{
				arr[i].update();
			}
			
		}
		function update():void
		{
			if( sensor.contacts > 1)
			{
				if(jumpDelay>0) jumpDelay--;
				else inAir = false;
				
				circle.SetFixedRotation(true);
			}
			else
			{
				circle.SetFixedRotation(false);
			}
			//trace(sensor.contacts);
			//trace(World.inst.y);
			if(sensor.contacts <=1 && !inAir)
			{
				inAir= true;
				
			}
			trace('FR='+circle.IsFixedRotation());
			
			
			
			x = middleBox.GetPosition().x*World.PXperM;
			y = (middleBox.GetPosition().y)*World.PXperM + W/4;// - World.inst.y;
			
			//Animate:
			if(attack && !aiming && !inAir)
			{
				mainAnim = 'special';
				gotoAndStop(mainAnim);
				if(attack)
				{
					specialAnim = 'attack';
				}
				
				if(specialAnim != realSA)
				{
					realSA = specialAnim;
					this['anim_mc'].gotoAndPlay(specialAnim);
				}
			}
			else
			{
				
				mainAnim = 'custom';
				gotoAndStop(mainAnim);
				if(inAir)
				{
					legsAnim = 'jump';
				}
				else if(isWalking)
				{
					legsAnim = 'walk';
				}
				else
				{
					legsAnim = 'wait';
				}
				
				if(aiming)
				{
					torsoAnim = 'aim';
				}
				else
				{
					torsoAnim = legsAnim;
				}
				
				if(torsoAnim != realTA)
				{
					realTA = torsoAnim;
					this['torso_mc'].gotoAndPlay(torsoAnim);
					
				}
				if(legsAnim != realLA)
				{
					realLA = legsAnim;
					this['legs_mc'].gotoAndPlay(legsAnim);
				}
			}
			
			
		}
		
		//inner functs. direct control
		function go(speed:int):void
		{
			//trace('go');
			//this.currentAnim = 'walk';
			this.circle.SetAngularVelocity(speed);
		}
		function push(force:int):void
		{
			 this.middleBox.ApplyForce(new b2Vec2(force*100, 0),new b2Vec2(0, 0));
			
		}
		function jump():void
		{
			 this.middleBox.SetLinearVelocity(new b2Vec2(middleBox.GetLinearVelocity().x, 0));
			 this.middleBox.ApplyImpulse(new b2Vec2(0, -jumpPower),new b2Vec2(0, 0));
		}
		// etc...
		
		
		
		
	}
	
}
