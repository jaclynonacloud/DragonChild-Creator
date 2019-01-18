package controllers
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import components.Part;
	import components.ui.Editor;

	public class DragController
	{
		private static var _stage:Stage;
		private static var _currPart:Part;

		private static var _offset:Point = new Point(0, 0);

		/*-------------------------------------------------------METHODS-----------*/
		public static function Setup(stage:Stage):void
		{
			_stage = stage;
		}

		public static function DragFromMousePosition(part:Part):void
		{
			_currPart = part;
			//move part to starting point
			_offset.x = part.width / 2;
			_offset.y = part.height / 2;

			part.x = _stage.mouseX;
			part.y = _stage.mouseY;

			//make sure part is visible
			if(!part.IsVisible)
				part.ChangeVisibility(true);

			//start dragging
			_stage.addEventListener(Event.ENTER_FRAME, onDrag);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onEndDrag);
		}

		public static function Drag(part:Part):void
		{
			_currPart = part;
			trace("PICKED UP: " + part.Name);
			//get mouse offset
			_offset.x = _currPart.mouseX;
			_offset.y = _currPart.mouseY;

			//start dragging
			_stage.addEventListener(Event.ENTER_FRAME, onDrag);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onEndDrag);
		}
		/*-------------------------------------------------------EVENTS------------*/
		private static function onDrag(e:Event):void
		{
			//move part
			_currPart.x = _stage.mouseX - _offset.x;
			_currPart.y = _stage.mouseY - _offset.y;

			if(Editor.IsVisible)
				Editor.Move();
		}
		private static function onEndDrag(e:MouseEvent):void
		{
			//end drag
			_stage.removeEventListener(Event.ENTER_FRAME, onDrag);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onEndDrag);
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/

	}

}