package components
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import controllers.DragController;
	import components.ui.*;

	/**Creates a group of sections.**/
	public class Part extends MovieClip
	{
		public static const SNAP_DISTANCE:int = 5;
		private static var _allParts:Vector.<Part> = new Vector.<Part>();

		protected var _fullName:String;
		protected var _name:String;
		protected var _clip:MovieClip;
		private var _parent:DisplayObjectContainer;
		private var _container:DisplayObjectContainer;
		private var _preferredPlacement:int;

		private var _item:Pager_GroupItem;

		private var _snapPoint:Point; //where the part snaps to the object
		private var _decisionTimer:Timer = new Timer(100, 1);

		//collections
		private var _sections:Vector.<Section> = new Vector.<Section>();

		//flags
		private var _baseObject:Boolean = false; //base objects are objects that are added and cannot be removed or moved
		private var _snapOnly:Boolean = false; //these objects can ONLY be snapped, not moved
		private var _canSnap:Boolean = true;
		private var _startSnapped:Boolean = false;
		private var _groupIndex:int = -1; //if this number is set, only one of this type will be accepted

		public function Part(clip:MovieClip, preferredPlacement:int = 0, name = "", snapPoint:Point = null, par:DisplayObjectContainer = null)
		{
			//_fullName = fullName == "" ? clip.name : fullName;
			_fullName = clip.name;
			//get name
			if(name != "")
				_fullName = name;
			if(_fullName.indexOf("_") != -1)
				_name = Creator.SplitCamelCase(_fullName.substr(0, _fullName.indexOf("_")));
			else
				_name = Creator.SplitCamelCase(_fullName);
			
			//get clip
			_clip = clip;
			//get parent
			_parent = clip.parent;
			if(par != null) _parent = par;

			//get attach point
			if(snapPoint != null)
				_snapPoint = snapPoint;
			else
				_snapPoint = new Point(clip.x, clip.y);

			_preferredPlacement = preferredPlacement;


			//get the sections
			for(var i:int = 0; i < _clip.numChildren; i++)
			{
				var child:MovieClip = (_clip.getChildAt(i) as MovieClip)

				if(child == null)
					continue;

				if(child.name.toLowerCase().indexOf("ignore") != -1)
					continue;
				

				_sections.push(new Section(child));
			}


			//check flags
			//--sets whether this part is a base object
			if(_fullName.toLowerCase().indexOf("baseobject") != -1)
			{
				_baseObject = true;
				_canSnap = false;
			}
			//--sets whether this object can only be snapped
			if(_fullName.toLowerCase().indexOf("snaponly") != -1)
				_snapOnly = true;
			//--sets whether part can be snapped
			if(_fullName.toLowerCase().indexOf("nosnap") != -1)
				_canSnap = false;
			//--sets whether part starts out snapped on character
			if(_fullName.toLowerCase().indexOf("startsnapped") != -1)
				_startSnapped = true;
			//--look for local preferred placement
			if(_fullName.toLowerCase().indexOf("top") != -1)
				_preferredPlacement = 1;
			else if(_fullName.toLowerCase().indexOf("bottom") != -1)
				_preferredPlacement = -1;
			//--sets whether this part is part of a singular group
			if(_fullName.toLowerCase().indexOf("onlyone") != -1)
			{
				var start:int = _fullName.toLowerCase().indexOf("onlyone") + 7;
				var end:int = _fullName.toLowerCase().indexOf("g", start);
				_groupIndex = int(_fullName.slice(start, end));
			}

			//create the icon for the pager
			CreateItem();

			//setup listeners
			addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			addEventListener(MouseEvent.MOUSE_UP, onRelease);
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightClick);


			_allParts.push(this);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function AddTo(container:DisplayObjectContainer):void
		{
			_container = container;
			//create setup for this
			x = _clip.x;
			y = _clip.y;
			addChild(_clip);
			_clip.x = 0;
			_clip.y = 0;


			container.addChild(this);

			buttonMode = true;
		}

		//only used on parts that are set as base or snapping initial
		public function SetInScene():void
		{
			Creator.Result.addChild(this);
		}

		public function AddToTop():void
		{
			trace("PREFERRED: " + Name + ", " + PreferredPlacement);
			//check preferred placement
			if(PreferredPlacement == -1)
				Creator.Result.addChildAt(this, 0);
			else
				Creator.Result.addChild(this);

		}

		public function Use():void
		{
			//MAKE SURE THIS PART is not part of a group index that is already out
			//if it is, remove the part that is visible and replace with this part
			var groupPart:Part = GetVisibleGroupPart();
			if(groupPart != null)
			{
				trace("YES I HAPPENED");
				groupPart.ChangeVisibility(false);
				//put this part to that parts child position
				var index:int = Creator.Result.getChildIndex(groupPart);
				trace("INEX: " + index);
				if(index != -1)
					Creator.Result.addChildAt(this, index);
			}
			else
				//add to top
				AddToTop();

			

			//drag part
			if(!SnapOnly)
				DragController.DragFromMousePosition(this);
			else
			{
				Snap();
				ChangeVisibility(true);
			}

			//close editor
			if(Editor.IsVisible)
				Editor.Hide();
			return;
			//if the editor is open, set to this part
			if(Editor.IsVisible)
				Editor.Show(Creator.Main, this);
		}

		public function Return():void
		{
			ChangeVisibility(false);

			//if the editor was open with this part, close it
			if(Editor.IsVisibleOn(this))
				Editor.Hide();

			parent.removeChild(this);
		}

		public function Drop():void
		{
			if(_canSnap)
				//if within distance, snap to position
				var distance:Number = Point.distance(new Point(x, y), _snapPoint);
				if(distance < SNAP_DISTANCE)
					Snap();
		}

		public function Snap():void
		{
			if(!_canSnap)
				return;

			x = _snapPoint.x;
			y = _snapPoint.y;

			if(Editor.IsVisible)
				Editor.Move();
		}

		private function ToggleEditor():void
		{
			if(!Editor.IsVisibleOn(this))
				Editor.Show(Creator.Main, this);
			else
				Editor.Hide();
		}

		private function CreateItem():void
		{
			_item = new Pager_GroupItem();
			_item.txtName.text = Name;
			_item.txtName.mouseEnabled = false;
			_item.image.mouseEnabled = false;
			_item.txtGroupIndex.mouseEnabled = false;

			//create image
			var spr:Sprite = new Sprite();
			//--draw image
			var bitmap:BitmapData = new BitmapData(Clip.width, Clip.height, true, 0x00000000);
			bitmap.draw(Clip);
			
			//--set scale
			var mat:Matrix = new Matrix();
			var sc:Number = _item.image.width / Clip.width;
			if(Clip.height * sc > _item.image.height)
				sc = _item.image.height / Clip.height;
			if(Clip.height < _item.image.height && Clip.width < _item.image.width)
				sc = 1;
			mat.scale(sc, sc);

			//--set graphics
			spr.graphics.beginBitmapFill(bitmap, mat, false, true);
			spr.graphics.drawRect(0, 0, Clip.width * sc, Clip.height * sc);
			spr.graphics.endFill();
			//--add to image
			_item.image.addChild(spr);

			//check flags
			if(_baseObject)
				_item.baseObject.visible = true;
			if(_groupIndex != -1)
				_item.txtGroupIndex.text = _groupIndex.toString();
			else
				_item.txtGroupIndex.text = "";
			if(_snapOnly)
				_item.snapOnly.visible = true;
			if(_startSnapped)
				_item.checkedOut.visible = true;

			//center the graphic
			spr.x = (_item.image.width / 2) - ((Clip.width * sc) / 2);
			spr.y = (_item.image.height / 2) - ((Clip.height * sc) / 2);

			//add listeners
			_item.checkedOut.addEventListener(MouseEvent.MOUSE_DOWN, onReturnPart);
			_item.baseObject.addEventListener(MouseEvent.MOUSE_DOWN, onUseEditor);

			//after the object is created, set whether it is visible
			if(!_startSnapped && !_baseObject)
				if(!this is ManyPart)
					ChangeVisibility(false);
		}

		public function ChangeVisibility(showing:Boolean):void
		{
			//cannot toggle base object
			if(_baseObject)
				return;

			if(showing)
			{
				visible = true;

				if(Creator.GetClass(this) != ManyPart)
					_item.checkedOut.visible = true;
			}
			else
			{
				visible = false;
				_item.checkedOut.visible = false;
			}
		}

		public function ShiftUp():void
		{
			//get part index
			var index:int = parent.getChildIndex(this);
			trace("INDEX: " + index);

			if(index < Creator.Result.numChildren - 1)
				parent.addChildAt(this, index + 1);
		}

		public function ShiftDown():void
		{
			//get part index
			var index:int = parent.getChildIndex(this);
			trace("INDEX DOWN: " + index);

			if(index > 0)
				parent.addChildAt(this, index - 1);
		}

		public function CheckIfGroupIsVisible():Boolean
		{
			//if we have no group, say no
			if(_groupIndex == -1)
				return false;

			//otherwise, check the visible children
			for(var i:int = 0; i < Creator.Result.numChildren; i++)
			{
				var child:Part = Creator.Result.getChildAt(i) as Part;
				if(child == null)
					continue;

				if(!child.visible)
					continue;
				//see if this child has the group index
				if(child.GroupIndex == _groupIndex)
					return true;
			}

			return false;
		}

		public function GetVisibleGroupPart():Part
		{
			if(!CheckIfGroupIsVisible())
				return null;

			//look for part
			for(var i:int = 0; i < Creator.Result.numChildren; i++)
			{
				var child:Part = Creator.Result.getChildAt(i) as Part;
				if(child == null)
					continue;

				if(!child.visible)
					continue;
				//see if this child has the group index
				if(child.GroupIndex == _groupIndex)
					return child;
			}

			return null;
		}
		/*-------------------------------------------------------EVENTS------------*/
		private function onClick(e:MouseEvent):void
		{
			//the base objects can only be altered in the editor
			if(_baseObject || _snapOnly)
			{
				ToggleEditor();
				return;
			}

			//listen for decision
			_decisionTimer.reset();
			_decisionTimer.start();
			_decisionTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDecisionTimerComplete);
			//startup local listener
			addEventListener(MouseEvent.MOUSE_UP, onDecisionEnded);

		}

		private function onRelease(e:MouseEvent):void
		{
			Drop();
		}

		private function onRightClick(e:MouseEvent):void
		{
			//right click opens editor
			Editor.Show(Creator.Main, this);
		}


		private function onDecisionTimerComplete(e:TimerEvent):void
		{
			//kill local listener
			removeEventListener(MouseEvent.MOUSE_UP, onDecisionEnded);

			//if timer finished, but we are still holding button, this is a drag
			DragController.Drag(this);

			//if editor is open, change to this part
			if(Editor.IsVisible)
				Editor.Show(Creator.Main, this);

			_decisionTimer.stop();
			_decisionTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDecisionTimerComplete);
		}

		private function onDecisionEnded(e:MouseEvent):void
		{
			//kill decision timer
			_decisionTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDecisionTimerComplete);
			_decisionTimer.stop();

			//kill local listener
			removeEventListener(MouseEvent.MOUSE_UP, onDecisionEnded);

			//if we released within time, open editor
			ToggleEditor();
		}

		/*----ITEM EVENTS---*/
		public function onReturnPart(e:MouseEvent):void
		{
			Return();
		}
		private function onUseEditor(e:MouseEvent):void
		{
			//opens editor
			Editor.Show(Creator.Main, this);
		}
		/*-------------------------------------------OVERRIDES---------------------*/
		public override function toString():String
		{
			return "PART- " + Name + ", Parent:" + Parent + ", Snap:" + SnapPoint;
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get FullName():String { return _fullName; }
		public function get Name():String { return _name; }
		public function get Clip():MovieClip { return _clip; }
		public function get Parent():DisplayObjectContainer { return _parent; }
		public function get Container():DisplayObjectContainer { return _container; }
		public function get PreferredPlacement():int { return _preferredPlacement; }
		public function get Item():Pager_GroupItem { return _item; }
		public function get IsVisible():Boolean { return visible; }

		public function get SnapPoint():Point { return _snapPoint; }

		public function get Sections():Vector.<Section> { return _sections; }

		//flags
		public function get StartSnapped():Boolean { return _startSnapped; }
		public function get SnapOnly():Boolean { return _snapOnly; }
		public function get CanSnap():Boolean { return _canSnap; }
		public function get BaseObject():Boolean { return _baseObject; }
		public function get GroupIndex():int { return _groupIndex; }


		public function get AllParts():Vector.<Part> { return _allParts; }

	}

}