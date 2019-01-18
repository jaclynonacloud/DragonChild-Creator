package components.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import events.GridEvent;

	public class GridView extends Sprite
	{
		private var _container:DisplayObjectContainer;
		private var _items:Vector.<Vector.<DisplayObjectContainer>>;
		private var _rows:int;
		private var _cols:int;
		private var _padding:Point;
		private var _useListeners:Boolean;

		public function GridView(container:DisplayObjectContainer, rows:int, cols:int, useListeners:Boolean = true, padding:Point = null)
		{
			_container = container;
			_rows = rows;
			_cols = cols;
			_useListeners = useListeners;
			_padding = padding;
			//create the empty grid
			Clear();

			//add this to parent object
			container.addChild(this);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function AddItem(item:DisplayObjectContainer):void
		{
			//find closest empty
			var empty:Point = FindClosestEmptyElement();

			if(empty == null)
				return;

			//trace("Placed Item AT: " + empty);
			//set to items list position
			_items[empty.x][empty.y] = item;
			//add to parent
			addChild(item);

			//give listener
			if(_useListeners)
			{
				(item as Sprite).buttonMode = true;
				item.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			}

			Update();
		}

		public function RemoveItem(item:DisplayObjectContainer):void
		{
			//find the item
			for(var r:int = 0; r < _rows; r++)
			{
				for(var c:int = 0; c < _cols; c++)
				{
					if(_items[c][r] == item)
					{
						//turn off listener
						if(_useListeners)
							_items[c][r].removeEventListener(MouseEvent.MOUSE_DOWN, onClick);

						//if there is data, remove from container
						removeChild(_items[c][r]);
						//if the item exists, nullify it
						_items[c][r] = null;
						break;
					}
				}
			}

			Update();
		}

		public function Clear():void
		{
			if(_items != null && _items.length > 0)
			{
				//clear images
				for each(var itemRow:Vector.<DisplayObjectContainer> in _items)
					for each(var item:DisplayObjectContainer in itemRow)
						if(item != null)
							RemoveItem(item);
			}

			_items = new Vector.<Vector.<DisplayObjectContainer>>();
			for(var r:int = 0; r <= _rows; r++)
			{
				var row:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>();
				for(var c:int = 0; c <= _cols; c++)
					row.push(null);
				_items.push(row);
			}

		}

		private function Update():void
		{
			var padding:Point = new Point(0, 0);
			if(_padding != null) padding = _padding;

			//layout children
			for(var r:int = 0; r < _rows; r++)
			{
				for(var c:int = 0; c < _cols; c++)
				{
					var item:DisplayObjectContainer = _items[c][r];
					if(item == null)
						continue;				

					item.x = (item.width * c) + (padding.x * c);
					item.y = (item.height * r) + (padding.y * r);


				}
			}

		}


		/*---HELPERS---*/
		private function FindClosestEmptyElement():Point
		{
			//iterate through and look for closest empty
			for(var r:int = 0; r < _rows; r++)
			{
				for(var c:int = 0; c < _cols; c++)
				{
					if(_items[c][r] == null)
						return new Point(c, r);
				}
			}

			return null;
		}
		private function FindItemPosition(item:DisplayObjectContainer):Point
		{
			if(item == null)
				return null;

			//iterate through items
			for(var c:int = 0; c < _cols; c++)
				for(var r:int = 0; r < _rows; r++)
				if(_items[c][r] != null)
						if(_items[c][r].contains(item) || _items[c][r] == item)
							return new Point(c, r);

			return null;
		}

		public function GetTotalChildren():int
		{
			var total:int = 0;
			for(var r:int = 0; r < _rows - 1; r++)
				for(var c:int = 0; c < _cols - 1; c++)
					if(_items[c][r] != null)
						total++;

			return total;
		}
		/*-------------------------------------------------------EVENTS------------*/
		private function onClick(e:MouseEvent):void
		{
			//get position
			var position:Point = FindItemPosition(e.target as DisplayObjectContainer);
			if(position == null)
				return;
			//create gridevent
			dispatchEvent(new GridEvent(GridEvent.ITEM_CLICK, position.x, position.y, (_cols * (position.y) + position.x), (e.target as DisplayObjectContainer)));
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get Items():Vector.<Vector.<DisplayObjectContainer>> { return _items; }
		public function ItemsInRow(index:int):Vector.<DisplayObjectContainer> { return _items[index]; }
		public function get Rows():int { return _rows; }
		public function get Cols():int { return _cols; }
		public function get TotalElements():int { return _rows * _cols; }
	}
}