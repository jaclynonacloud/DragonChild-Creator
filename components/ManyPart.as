package components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class ManyPart extends Part
	{
		private var _clipClass:Class;

		public function ManyPart(clip:*, name:String, pos:Point, par:DisplayObjectContainer, preferredPlacement:int)
		{
			_clipClass = Creator.GetClass(clip);
			var c:* = new _clipClass();

			super(c as MovieClip, preferredPlacement, name, pos, par);


			//add the new graphics
			addChild(c);
			par.addChild(this);

			visible = true;
			buttonMode = true;

			//turn on multi item icon
			Item.multi.visible = true;
			Item.multi.mouseEnabled = false;

		}

		/*-------------------------------------------------------METHODS-----------*/
		public function CopyWithSectionData():ManyPart
		{
			//trace("PAR: " + Parent);
			var mP:ManyPart = new ManyPart(Clip, FullName, SnapPoint, Clip.parent.parent, PreferredPlacement);

			//change section data
			for(var i:int = 0; i < mP.Sections.length; i++)
			{
				var copySection:Section = mP.Sections[i];
				var currSection:Section = Sections[i];

				copySection.CopyDataFromOther(currSection);
			}
			return mP;
		}
		/*-------------------------------------------------------EVENTS------------*/
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get ClipClass():Class { return _clipClass; }

	}
}