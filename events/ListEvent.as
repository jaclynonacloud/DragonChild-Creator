package events {
	import flash.events.Event;
	
	public class ListEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClicked";
		

		// this is the object you want to pass through your event.
		public var index:int;
		public var item:*;

		public function ListEvent(type:String, index:int, item:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.index = index;
			this.item = item;
		}

		// always create a clone() method for events in case you want to redispatch them.
		public override function clone():Event
		{
			return new ListEvent(type, index, item, bubbles, cancelable);
		}
	}
	
}
