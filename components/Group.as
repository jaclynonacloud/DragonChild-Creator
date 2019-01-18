package components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;

	/**Creates a group of parts.**/
	public class Group
	{
		private var _name:String;
		private var _container:DisplayObjectContainer;
		private var _parts:Vector.<Part> = new Vector.<Part>();

		public function Group(container:DisplayObjectContainer)
		{
			var fullName:String = container.name;
			//get name
			var check:String = fullName.indexOf("_") != -1 ? fullName.substr(0, fullName.indexOf("_")) : fullName;
			trace("NOM : " + check);
			_name = Creator.SplitCamelCase(check);
			//get container
			_container = container;


			//check flags
			var preferredPlacement:int = 0;
			if(fullName.toLowerCase().indexOf("top") != -1)
				preferredPlacement = 1;
			if(fullName.toLowerCase().indexOf("bottom") != -1)
				preferredPlacement = -1;

			//create parts
			for(var i:int = 0; i < _container.numChildren; i++)
			{
				var child:MovieClip = _container.getChildAt(i) as MovieClip;
				if(child == null)
					continue;

				//find out if this is a manypart
				if(child.name.toLowerCase().indexOf("_allowmany") != -1)
				{
					var mP:ManyPart = new ManyPart(child, child.name, new Point(child.x, child.y), child.parent.parent, preferredPlacement);
					_parts.push(mP);
					//toggle away
					mP.ChangeVisibility(false);
					//hide the initial
					child.visible = false;
				}
				//otherwise, just create a part
				else
					_parts.push(new Part(child, preferredPlacement));
			}

			//setup parts
			for each(var part:Part in _parts)
				part.AddTo(container);

			//do specifics
			for each(var p:Part in _parts)
			{
				//add base objects to top
				if(p.BaseObject)
					p.AddToTop();
				//snap snappy objects
				else if(p.StartSnapped)
				{
					p.Snap();
					p.AddToTop();
				}

				else p.Return();
			}

			


			//sort parts alphabetically by their name
			_parts.sort(SortByName);
			_parts.reverse();

			trace("PARTS: " + _parts.length);
		}

		/*-------------------------------------------------------METHODS-----------*/
		private function SortByName(a:Part, b:Part):int
		{
			return a.Name < b.Name ? 1 : -1;
		}
		/*-------------------------------------------------------EVENTS------------*/
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get Name():String { return _name; }
		public function get Container():DisplayObjectContainer { return _container; }
		public function get Parts():Vector.<Part> { return _parts; }

	}
}