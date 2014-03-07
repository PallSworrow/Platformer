package Src.PhysicsApi {
	import Box2D.Dynamics.b2Body;
	
	public class Sensor {
		public var contacts:int=0;
		public function Sensor(body:b2Body) {
			// constructor code
			body.GetFixtureList().SetUserData(this);
		}

	}
	
}
