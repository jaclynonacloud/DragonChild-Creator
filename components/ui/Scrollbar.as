package components.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;

	/**Used to create a scrollbar.**/
	public class Scrollbar
	{
		private var _stage:DisplayObjectContainer;
		private var _scrollArea:DisplayObjectContainer;
		private var _scrollbar:MovieClip;

		private var _value:Number;
		private var _autoHide:Boolean;

		public function Scrollbar(stage:DisplayObjectContainer, scrollArea:DisplayObjectContainer, scrollbar:MovieClip, autoHide:Boolean = true)
		{
			_stage = stage;
			_scrollArea = scrollArea;
			_scrollbar = scrollbar;

			_scrollbar.buttonMode = true;

			_autoHide = autoHide;

			//listen to scrollbar
			_scrollbar.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onEndDrag);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function Resize(percentage:Number):void
		{
			_scrollArea.visible = true;
			_scrollbar.visible = true;
			//if percentage is less than 0.0, check for autohide
			if(percentage >= 1.0)
			{
				if(_autoHide)
				{
					_scrollArea.visible = false;
					_scrollbar.visible = false;
				}
			}

			//clamp the number between 0.0 and 1.0
			percentage = percentage < 0.0 ? 0.0 : percentage > 1.0 ? 1.0 : percentage;
			trace("PREC: " + percentage);

			//make the scrollbar a percentage of the scrollarea
			_scrollbar.height = (_scrollArea.height * percentage);
			//set min height
			if(_scrollbar.height < 30)
				_scrollbar.height = 30;
		}

		public function Reset():void
		{
			_value = 0;
			_scrollbar.y = _scrollArea.y;
		}

		public function Destroy():void
		{
			_scrollbar.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onEndDrag);
		}
		/*-------------------------------------------------------EVENTS------------*/
		private function onStartDrag(e:MouseEvent):void
		{
			//start listening
			_scrollArea.addEventListener(Event.ENTER_FRAME, onDrag);
		}
		private function onDrag(e:Event):void
		{
			_scrollbar.y = _scrollArea.mouseY - _scrollbar.height / 2;

			//clamp to boundaries
			_scrollbar.y = _scrollbar.y < 0 ? 0 : _scrollbar.y > (_scrollArea.height - _scrollbar.height) ? (_scrollArea.height - _scrollbar.height) : _scrollbar.y;

			//get value
			_value = _scrollbar.y / (_scrollArea.height - _scrollbar.height);

			//send change event
			_scrollbar.dispatchEvent(new Event(Event.CHANGE));
		}
		private function onEndDrag(e:MouseEvent):void
		{
			//stop listening
			if(_scrollArea.hasEventListener(Event.ENTER_FRAME))
				_scrollArea.removeEventListener(Event.ENTER_FRAME, onDrag);
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get Value():Number { return _value; }
		public function get Scroll():MovieClip { return _scrollbar; }
	}
}