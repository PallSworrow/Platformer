package Src.PhysicsApi {
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	
	public class Collisions extends b2ContactListener{

		override public function BeginContact(contact:b2Contact):void 
		{
			if(contact.GetFixtureA().GetUserData() is Sensor)
			{
				contact.GetFixtureA().GetUserData().contacts ++;
			}
			if(contact.GetFixtureB().GetUserData() is Sensor)
			{
				contact.GetFixtureB().GetUserData().contacts ++;
			}
		}

	
		override public function EndContact(contact:b2Contact):void 
		{
			if(contact.GetFixtureA().GetUserData() is Sensor)
			{
				contact.GetFixtureA().GetUserData().contacts --;
			}
			if(contact.GetFixtureB().GetUserData() is Sensor)
			{
				contact.GetFixtureB().GetUserData().contacts --;
			}
		}
	}
	
}
