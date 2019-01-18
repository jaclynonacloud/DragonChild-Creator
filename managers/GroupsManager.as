package managers
{
	import flash.display.MovieClip;
	import components.Group;
	import components.ui.Pager;

	public class GroupsManager
	{
		private static var _container:MovieClip;
		private static var _groups:Vector.<Group> = new Vector.<Group>();

		/*-------------------------------------------------------METHODS-----------*/
		public static function Setup(container:MovieClip)
		{
			_container = container;

			//create parts
			for(var i:int = 0; i < _container.numChildren; i++)
			{
				if(_container.getChildAt(i) is MovieClip)
				{
					var group:Group = new Group(_container.getChildAt(i) as MovieClip)
					_groups.push(group);
					//add group to pager
					Pager.AddGroup(group);
				}
			}

			trace("GROUPS: " + _groups.length);
		}
		/*-------------------------------------------------------EVENTS------------*/
		/*-------------------------------------------GETTERS and SETTERS-----------*/

	}

}