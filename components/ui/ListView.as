package components.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import events.ListEvent;

	public class ListView extends Sprite
	{
		private var _items:Vector.<DisplayObjectContainer>;
		private var _useListeners:Boolean;

		public function ListView(container:DisplayObjectContainer, useListeners:Boolean = true)
		{
			_useListeners = useListeners;

			_items = new Vector.<DisplayObjectContainer>();
			container.addChild(this);
		}

		
		/*-------------------------------------------------------METHODS-----------*/
		public function AddItem(item:DisplayObjectContainer):void
		{
			//add to array
			_items.push(item);
			//add to display
			addChild(item);

			//listen
			if(_useListeners)
			{
				(item as Sprite).buttonMode = true;
				item.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			}

			Update();
		}

		public function RemoveItem(item:DisplayObjectContainer):void
		{
			//remove from array
			if(_items.indexOf(item) != -1)
				//_items.splice(_items.indexOf(item), 1);
				_items.removeAt(_items.indexOf(item));

			//remove from display
			if(contains(item))
				removeChild(item);

			Update();
		}

		public function Clear():void
		{
			while(_items.length > 0)
				RemoveItem(_items[0]);
		}

		private function Update():void
		{
			//layout children
			for(var i:int = _items.length - 1; i > 0; i--)
			{
				var item:DisplayObjectContainer = _items[i];

				if(i == 0)
				{
					item.x = 0;
					item.y = 0;
					continue;
				}	

				var lastItem:DisplayObjectContainer = _items[i - 1];

				item.x = 0;
				item.y = lastItem.y + lastItem.height;

			}

		}
		/*---HELPERS---*/
		private function FindItemIndex(item:DisplayObjectContainer):int
		{
			for(var i:int = 0; i < _items.length; i++)
				if(_items[i].contains(item) || _items[i] == item)
					return i;

			return -1;
		}
		/*-------------------------------------------------------EVENTS------------*/
		private function onClick(e:MouseEvent):void
		{
			var index:int = FindItemIndex(e.target as DisplayObjectContainer);
			if(index == -1)
				return;

			//call list event
			dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK, index, e.target as DisplayObjectContainer));
		}

		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get Items():Vector.<DisplayObjectContainer> { return _items; }
	}
}