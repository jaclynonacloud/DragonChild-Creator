package events {
	import flash.events.Event;
	
	public class GridEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClick";
		

		// this is the object you want to pass through your event.
		public var row:int;
		public var col:int;
		public var index:int;
		public var item:*;

		public function GridEvent(type:String, row:int, col:int, index:int = -1, item:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.row = row;
			this.col = col;
			this.index = index;
			this.item = item;
		}

		// always create a clone() method for events in case you want to redispatch them.
		public override function clone():Event
		{
			return new GridEvent(type, row, col, index, item, bubbles, cancelable);
		}
	}
	
}
