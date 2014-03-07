package Src.PhysicsApi {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.events.Event;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2DSeparator.*;
	import flash.display.Stage;
	import Src.StageManager;
	public class ConvertPngs extends MovieClip{
		/*
		checks box for any png-s, and adds a physic body to each of them
		*/
		
		var bitmap:Bitmap;
		var bitmapData:BitmapData;
		var boxMc:MovieClip;
		private var tolerance:Number=0x99;
		var bodyDef:b2BodyDef, body:b2Body, fixtureDef:b2FixtureDef, polyShape:b2PolygonShape, worldCont:Sprite = new Sprite();
		//var movic:MovieClip;
		
		var offsetX:int=0;
		var offsetY:int=0;
		public var bodies:Array= new Array();
		
		//public var bodies:Vector.<b2Body> = new Vector.<b2Body>();
		public function ConvertPngs(box:MovieClip):void
		{
			boxMc=box;
			var obj = box;
			
			var errPreventer:int = 0;
			while(!(obj is World)) 
			{
				trace('parent: '+obj);
				offsetX += obj.x;
				offsetY += obj.y;
				obj = obj.parent;
				errPreventer++;
				if(errPreventer > 5)
				{
					break ;///wrong parameters. output error warrning
				}
			}
			
			var L:int = box.numChildren;
			trace('=================================');
			var bd:BitmapData;
			var nb:Bitmap;
			var child;
			for (var i:int = L-1; i >=0; i--)
    		{
				//trace(this.getChildAt(i));
				trace('hey: '+ box.getChildAt(i));
				child = box.getChildAt(i);
				trace(box.getChildAt(i) is Bitmap);
				
				if(child is Bitmap)
				{
					complexBody((child as Bitmap));
				}
				else if (child is Shape)
				{
					trace('BITMAP X: '+child.x);
					bd = new BitmapData(StageManager.cellW+100,StageManager.cellH+100,true,0x00000000);
					bd.draw(child);
					box.removeChild(child);
					nb = new Bitmap(bd);
					
					box.addChild(nb);
					trace('NEW BITMAP X: '+nb.parent.parent);
					complexBody(nb);
					
				}
				
			}
			visible = false;
			trace('=================================');
		}
		public function complexBody(img:Bitmap) {
			// adding a png image with transparency
			/*bitmapData.draw(new Logo(300,225),new Matrix(1,0,0,1,10,10));
			var bitmap:Bitmap=new Bitmap(bitmapData);
			addChild(bitmap);*/
			
			bitmap = img;
			
			bitmapData = img.bitmapData;
			
			bitmap.alpha=0.5;
			var marchingVector:Vector.<Point>=marchingSquares(bitmapData);
			
			while(marchingVector)
			{
				//trace(marchingVector);
				//trace('=============================================================== \n');
				//var marchingVector:Vector.<Point>=marchingSquares(bitmapData);
				marchingVector=RDP(marchingVector,0.2);
				var canvas:Sprite=new Sprite();
				//addChild(canvas);
				canvas.graphics.moveTo(marchingVector[0].x/*+StageManager.cellW*2*/,marchingVector[0].y);
				for (var i:Number=0; i<marchingVector.length; i++) 
				{
					canvas.graphics.lineStyle(2,0xffffff);
					canvas.graphics.lineTo(marchingVector[i].x/*+StageManager.cellW*2*/,marchingVector[i].y);
					canvas.graphics.lineStyle(1,0xff0000);
					canvas.graphics.drawCircle(marchingVector[i].x/*+StageManager.cellW*2*/,marchingVector[i].y, 2);
				}
				canvas.graphics.lineStyle(2,0xffffff);
				canvas.graphics.lineTo(marchingVector[0].x/*+StageManager.cellW*2*/,marchingVector[0].y);
				// Box2D'as turn;
				/*world=new b2World(new b2Vec2(0,10),true);
				debug_draw();*/
			
				//addChild(worldCont);
				
				// Here we create the non-convex polygon! We do it in 5 steps.

				// 1) We create a b2Separator instance.
				var sep:b2Separator = new b2Separator();
			
				// 2) Then we create a b2Body instance. This is where the fixtures of the non-polygon shape will be stored.
				bodyDef = new b2BodyDef();
				bodyDef.position.Set((bitmap.x+offsetX)/World.PXperM,(bitmap.y+ offsetY)/World.PXperM);
				bodyDef.type = b2Body.b2_staticBody;
					//trace(World.inst);
				body=World.inst.sim.CreateBody(bodyDef);
			
				// 3) We also need a b2FixtureDef instance, so that the new fixtures can inherit its properties.
				
				fixtureDef = new b2FixtureDef();
				fixtureDef.restitution=0;
				fixtureDef.friction=10;
				//fixtureDef.density=4;

				// 4) And what is of most importance - we need a Vector of b2Vec2 instances so that we can pass the vertices! 
				// Remember, we need the vertices in clockwise order! For more information, read the documentation for the b2Separator.Separate() method.
				// Notice how I am reversing the Vector
				var vec:Vector.<b2Vec2> = new Vector.<b2Vec2>();
				for (i=marchingVector.length-1; i>=0; i--) 
				{
					// reducing a bit the polys
					if (i%10==0)
					{
						vec.push(new b2Vec2(marchingVector[i].x/30,marchingVector[i].y/30));
					}
				}
				//vec.push(new b2Vec2(-100/30, -100/30), new b2Vec2(100/30, -100/30), new b2Vec2(100/30, 0), new b2Vec2(0, 0), new b2Vec2(-100/30, 100/30));

				// If you want to be sure that the vertices are entered correctly, use the b2Separator.Validate() method!
				// Refer to the documentation of b2Separate.Validate() to see what it does and the values it returns.
				if (sep.Validate(vec)==0) 
				{
					sep.Separate(body, fixtureDef, vec);
					trace("Yey! Those vertices are good to go! ("+sep.Validate(vec)+")");
				
				}
				else
				{
					trace("Oh, I guess you messed something up :( ("+sep.Validate(vec)+")");
				}
			
			
				bodies.push(body);
		
				// 5) And finally, we pass the b2Body, b2FixtureDef and Vector.<b2Vec2> instances as parameters to the Separate() method!
				// It separates the non-convex shape into convex shapes, creates the fixtures and adds them to the body for us! Sweet, eh?
					//trace(sep.Validate(vec));
				//sep.Separate(body, fixtureDef, vec);
				//bitmapData.floodFill(marchingVector[0].x+1, marchingVector[0].y+1, 0x00000000);
				//bitmapData.draw(new Logo);
				
				//marchingVector=marchingSquares(bitmapData);
				//bitmapData.floodFill(marchingVector[0].x+1, marchingVector[0].y+1, 0x00000000);
				//trace(marchingVector);
				marchingVector=null;
				break;
			}
		}

		public function RDP(v:Vector.<Point>,epsilon:Number):Vector.<Point> {
			var firstPoint:Point=v[0];
			var lastPoint:Point=v[v.length-1];
			if (v.length<3) {
				return v;
			}
			var index:Number=-1;
			var dist:Number=0;
			for (var i:Number=1; i<v.length-1; i++) {
				var cDist:Number=findPerpendicularDistance(v[i],firstPoint,lastPoint);
				if (cDist>dist) {
					dist=cDist;
					index=i;
				}
			}
			if (dist>epsilon) {
				var l1:Vector.<Point>=v.slice(0,index+1);
				var l2:Vector.<Point>=v.slice(index);
				var r1=RDP(l1,epsilon);
				var r2=RDP(l2,epsilon);
				var rs:Vector.<Point>=r1.slice(0,r1.length-1).concat(r2);
				return rs;
			}
			else {
				return new Vector.<Point>(firstPoint,lastPoint);
			}
			return null;
		}

		private function findPerpendicularDistance(p:Point, p1:Point,p2:Point) {
			var result;
			var slope;
			var intercept;
			if (p1.x==p2.x) {
				result=Math.abs(p.x-p1.x);
			}
			else {
				slope = (p2.y - p1.y) / (p2.x - p1.x);
				intercept=p1.y-(slope*p1.x);
				result = Math.abs(slope * p.x - p.y + intercept) / Math.sqrt(Math.pow(slope, 2) + 1);
			}
			return result;
		}

		public function marchingSquares(bitmapData:BitmapData):Vector.<Point> {
			var contourVector:Vector.<Point> = new Vector.<Point>();
			// this is the canvas we'll use to draw the contour
			var canvas:Sprite=new Sprite();
			addChild(canvas);
			canvas.graphics.lineStyle(2,0x00ff00);
			// getting the starting pixel;
			var startPoint:Point=getStartingPixel(bitmapData);
			// if we found a starting pixel we can begin
			if (startPoint!=null) {
				// moving the graphic pen to the starting pixel
				canvas.graphics.moveTo(startPoint.x,startPoint.y);
				// pX and pY are the coordinates of the starting point;
				var pX:Number=startPoint.x;
				var pY:Number=startPoint.y;
				// stepX and stepY can be -1, 0 or 1 and represent the step in pixels to reach
				// next contour point
				var stepX:Number;
				var stepY:Number;
				// we also need to save the previous step, that's why we use prevX and prevY
				var prevX:Number;
				var prevY:Number;
				// closedLoop will be true once we traced the full contour
				var closedLoop:Boolean=false;
				while (!closedLoop) {
					// the core of the script is getting the 2x2 square value of each pixel
					var squareValue:Number=getSquareValue(pX,pY);
					switch (squareValue) {
							/* going UP with these cases:
							
							+---+---+   +---+---+   +---+---+
							| 1 |   |   | 1 |   |   | 1 |   |
							+---+---+   +---+---+   +---+---+
							|   |   |   | 4 |   |   | 4 | 8 |
							+---+---+   +---+---+  +---+---+
							
							*/
						case 1 :
						case 5 :
						case 13 :
							stepX=0;
							stepY=-1;
							break;
							/* going DOWN with these cases:
							
							+---+---+   +---+---+   +---+---+
							|   |   |   |   | 2 |   | 1 | 2 |
							+---+---+   +---+---+   +---+---+
							|   | 8 |   |   | 8 |   |   | 8 |
							+---+---+   +---+---+  +---+---+
							
							*/
						case 8 :
						case 10 :
						case 11 :
							stepX=0;
							stepY=1;
							break;
							/* going LEFT with these cases:
							
							+---+---+   +---+---+   +---+---+
							|   |   |   |   |   |   |   | 2 |
							+---+---+   +---+---+   +---+---+
							| 4 |   |   | 4 | 8 |   | 4 | 8 |
							+---+---+   +---+---+  +---+---+
							
							*/
						case 4 :
						case 12 :
						case 14 :
							stepX=-1;
							stepY=0;
							break;
							/* going RIGHT with these cases:
							
							+---+---+   +---+---+   +---+---+
							|   | 2 |   | 1 | 2 |   | 1 | 2 |
							+---+---+   +---+---+   +---+---+
							|   |   |   |   |   |   | 4 |   |
							+---+---+   +---+---+  +---+---+
							
							*/
						case 2 :
						case 3 :
						case 7 :
							stepX=1;
							stepY=0;
							break;
						case 6 :
							/* special saddle point case 1:
							
							+---+---+ 
							|   | 2 | 
							+---+---+
							| 4 |   |
							+---+---+
							
							going LEFT if coming from UP
							else going RIGHT 
							
							*/
							if (prevX==0&&prevY==-1) {
								stepX=-1;
								stepY=0;
							}
							else {
								stepX=1;
								stepY=0;
							}
							break;
						case 9 :
							/* special saddle point case 2:
							
							+---+---+ 
							| 1 |   | 
							+---+---+
							|   | 8 |
							+---+---+
							
							going UP if coming from RIGHT
							else going DOWN 
							
							*/
							if (prevX==1&&prevY==0) {
								stepX=0;
								stepY=-1;
							}
							else {
								stepX=0;
								stepY=1;
							}
							break;
					}
					// moving onto next point
					pX+=stepX;
					pY+=stepY;
					// saving contour point
					contourVector.push(new Point(pX, pY));
					prevX=stepX;
					prevY=stepY;
					//  drawing the line
					canvas.graphics.lineTo(pX,pY);
					// if we returned to the first point visited, the loop has finished;
					if (pX==startPoint.x&&pY==startPoint.y) {
						closedLoop=true;
					}
				}
			}
			return contourVector;
		}

		private function getStartingPixel(bitmapData:BitmapData):Point {
			// finding the starting pixel is a matter of brute force, we need to scan
			// the image pixel by pixel until we find a non-transparent pixel
			var zeroPoint:Point=new Point(0,0);
			var offsetPoint:Point=new Point(0,0);
			for (var i:Number=0; i<bitmapData.height; i++) {
				for (var j:Number=0; j<bitmapData.width; j++) {
					offsetPoint.x=j;
					offsetPoint.y=i;
					if (bitmapData.hitTest(zeroPoint,tolerance,offsetPoint)) {
						trace('point='+bitmapData.getPixel32(offsetPoint.x,offsetPoint.y));
						return offsetPoint;
					}
				}
			}
			return null;
		}

		private function getSquareValue(pX:Number,pY:Number):Number {
			/*
			
			checking the 2x2 pixel grid, assigning these values to each pixel, if not transparent
			
			+---+---+
			| 1 | 2 |
			+---+---+
			| 4 | 8 | <- current pixel (pX,pY)
			+---+---+
			
			*/
			var squareValue:Number=0;
			// checking upper left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX-1,pY-1))>=tolerance) {
				squareValue+=1;
			}
			// checking upper pixel
			if (getAlphaValue(bitmapData.getPixel32(pX,pY-1))>tolerance) {
				squareValue+=2;
			}
			// checking left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX-1,pY))>tolerance) {
				squareValue+=4;
			}
			// checking the pixel itself
			if (getAlphaValue(bitmapData.getPixel32(pX,pY))>tolerance) {
				squareValue+=8;
			}
			return squareValue;
		}

		private function getAlphaValue(n:Number):Number {
			// given an ARGB color value, returns the alpha 0 -> 255
			return n >> 24 & 0xFF;
		}

		public function debug_draw():void {
			/*var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(worldCont);
			debugDraw.SetDrawScale(30);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetLineThickness(1);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_centerOfMassBit);
			world.SetDebugDraw(debugDraw);*/
		}

		private function update(e:Event):void {
			/*world.Step(1/30, 10, 10);
			world.ClearForces();
			world.DrawDebugData();*/
		}
	}
}