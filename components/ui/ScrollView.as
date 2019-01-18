package components.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	/**Used to create a scrolling viewport.**/
	public class ScrollView
	{
		private var _content:DisplayObjectContainer;
		private var _container:DisplayObjectContainer;
		private var _scrollbar:Scrollbar;

		public function ScrollView(content:DisplayObjectContainer, container:DisplayObjectContainer, scrollbar:Scrollbar)
		{
			_content = content;
			_container = container;
			_scrollbar = scrollbar;

			//mask
			_content.mask = _container;

			//listen to scrollbar for value update
			_scrollbar.Scroll.addEventListener(Event.CHANGE, onValueChange);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function Update():void
		{
			//compare content to the display container
			var size:Number = (_content.height / _container.height);
			_scrollbar.Resize(2.0 - size);
		}

		public function Reset():void
		{
			trace("CALLED");
			_content.y = _container.y;	
			_scrollbar.Reset();
		}

		public function Destroy():void
		{
			//remove listeners
			_scrollbar.Scroll.removeEventListener(Event.CHANGE, onValueChange);
		}

		/*-------------------------------------------------------EVENTS------------*/
		private function onValueChange(e:Event):void
		{
			//change position of scrollview
			_content.y =  -((_content.height - _container.height) * _scrollbar.Value);
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/


	}
}