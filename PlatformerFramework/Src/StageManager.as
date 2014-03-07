package Src {
	import flash.display.MovieClip;
	import Src.PhysicsApi.ConvertPngs;
	import Src.Units.TestUnit;
	import Box2D.Dynamics.b2Body;
	
	public class StageManager extends MovieClip{
		//constants:
		public static var cellH:int = 600;
		public static var cellW:int = 1000;
		
		
		//current params:
		public var map:Object;
		var cellX:int=0;
		var cellY:int=0;
		
		public var bgBox:MovieClip = new MovieClip();
		
		var leftCell:MovieClip;
		var rightCell:MovieClip;
		var upCell:MovieClip;
		var downCell:MovieClip;
		var centerCell:MovieClip;
		//cell's complex bodies:(needs for destroy func)
		var CellCB11:Array=new Array();
		var CellCB01:Array=new Array();
		var CellCB21:Array=new Array();
		var CellCB12:Array=new Array();
		var CellCB10:Array=new Array();
		
		public var actionBox:MovieClip = new MovieClip();
		
		public var upperBox:MovieClip = new MovieClip();
		/*map-object description:
		contents cells of stage parts. they have format:
		cell_X_Y = {src:(background with graphics and physics), upper:(upper graphics), portalRight(1-4 portals to not-next cell, optional, b2vec type.)}
		
		*/
		
		
		
		public function StageManager()
		{
			
		}
		public function moving():void
		{
			//trace(centerCell.x + parent.x);
			if(centerCell.x + parent.x > -50 && !leftCell) leftCell = loadCell(-1,0);
			if(centerCell.x + parent.x < -90 && leftCell) destroyCell('left');
			
			if(centerCell.x + parent.x < Main.Width-StageManager.cellW+50 && !rightCell) rightCell = loadCell(1,0);
			if(centerCell.x + parent.x > Main.Width-StageManager.cellW+90 && rightCell) destroyCell('right');
			
			
			if(centerCell.x + parent.x < -StageManager.cellW/2 ) cellStep(1,0);
			if(centerCell.x + parent.x > StageManager.cellW/2) cellStep(-1,0);
		}
		
		
		
		
		public function LoadLevel(lvl) {
			// constructor code
			addChild(bgBox);
			addChild(actionBox);
			
			map = lvl.map;
			trace('stage manager');
			centerCell = loadCell(0,0);
			/*rightCell = loadCell(1,0);
			leftCell = loadCell(-1,0);
			upCell = loadCell(0,1);
			downCell = loadCell(0,-1);*/
			
			var Char:TestUnit = new TestUnit();
			actionBox.addChild(Char);
			var A = new MainCharacter(Char);
			
		}
		//loads nearby cell. x y - offset from center cell
		function loadCell(X:int,Y:int):MovieClip
		{
			var cell;
			trace('loadcell: '+ map['cell_'+(cellX+X)+'_'+(cellY+Y)]);
			if(map['cell_'+(cellX+X)+'_'+(cellY+Y)])
			{
				cell = new map['cell_'+(cellX+X)+'_'+(cellY+Y)].src();
				cell.x = (cellX+X)*cellW;
				cell.y = (cellY+Y)*cellH;
			
				var converter:ConvertPngs;
				bgBox.addChild(cell);
				if(cell.physicsMap)
				{
					converter = new ConvertPngs(cell.physicsMap);
					//if(X ==0 && Y==1)
					//this.up = converter.bodies;
					cell.physicsMap.addChild(converter);
				}
				return cell;
			}
			else
			{
				cell = new MovieClip();
				cell.x = (cellX+X)*cellW;
				cell.y = (cellY+Y)*cellH;
				bgBox.addChild(cell);
				return cell;
			}
		}
		function destroyCell(destroy:String):void
		{
			var cell = this[destroy+'Cell'];
			
			if(cell.physicsMap)
			{
				var box:MovieClip = cell.physicsMap;
				var L:int = box.numChildren;
				var L1:int;
				trace('L='+L);
				var obj:Object;
				trace('destroy: '+destroy);
				for (var i:int = L-1; i >=0; i--)
    			{
					//trace(this.getChildAt(i));
				obj = box.getChildAt(i);
					if(obj is ConvertPngs)
					{
						trace('converter');
						for(L1 = (obj.bodies as Array).length-1; L1>=0;L1--)
						{
							(obj.bodies[L1] as b2Body).SetUserData('DELETE');
							trace('deleted');
						}
					}
					else if(obj is PhysicBody)
					{
						trace('simpleWall');
						(obj.physics as b2Body).SetUserData('DELETE');
					}
					
				
				}
			}
			this.bgBox.removeChild( this[destroy+'Cell']);
			 this[destroy+'Cell'] = null;
			
		}
		function cellStep(X:int,Y:int):void
		{
			cellX += X;
			cellY += Y;
			trace('cellStep: '+X);
			if(X==1)
			{
				
				/*if(leftCell)
				{
					destroyCell('left');
					bgBox.removeChild(leftCell);
					leftCell = null;
				}*/
				//destroyCell('up');
				//destroyCell('down');
				
				//bgBox.removeChild(upCell);
				//bgBox.removeChild(downCell);
				//delete : left,up, down
				//trace('step right');
				leftCell = centerCell;
				if(rightCell) centerCell = rightCell;
				rightCell = null;
				
				//rightCell = loadCell(1,0);
				///upCell = loadCell(0,1);
				//downCell = loadCell(0,-1);
				
				
			}
			else if(X==-1)
			{
				/*if(rightCell)
				{
					destroyCell('right');
					bgBox.removeChild(rightCell);
					rightCell = null;
				}*/
				/*destroyCell('up');
				destroyCell('down');
				destroyCell('right');
				bgBox.removeChild(rightCell);
				bgBox.removeChild(upCell);
				bgBox.removeChild(downCell);
				//delete : left,up, down*/
				rightCell = centerCell;
				
				if(leftCell) centerCell = leftCell;
				leftCell=null;
				/*leftCell = loadCell(-1,0);
				upCell = loadCell(0,1);
				downCell = loadCell(0,-1);*/
				//trace('step left complete');
			}
		}
	}
	
}
