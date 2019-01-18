package components
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	public class Section
	{
		private var _fullName:String;
		private var _name:String;
		private var _clip:MovieClip;
		private var _colour:ColorTransform = new ColorTransform();
		private var _visibility:Boolean = true;

		//flags
		private var _canBeInvisible:Boolean = true;

		public function Section(clip:MovieClip)
		{
			//get name
			_fullName = clip.name;
			if(_fullName.indexOf("_") != -1)
				_name = Creator.SplitCamelCase(_fullName.substr(0, _fullName.indexOf("_")));
			else
				_name = Creator.SplitCamelCase(_fullName);
			//get clip
			_clip = clip;

			//set default colour
			ChangeColour(0x818E86);
			

			//parse the flags
			//--start a certain colour
			if(_fullName.toLowerCase().indexOf("__") != -1)
			{
				var colour:uint = (uint)("0x" + _fullName.substr(_fullName.toLowerCase().indexOf("__") + 2, 6));
				ChangeColour(colour);
			}
			//--start invisible
			if(_fullName.toLowerCase().indexOf("startinvisible") != -1)
				ChangeVisibility(false);
			//--flag whether this section can be invisible
			if(_fullName.toLowerCase().indexOf("noinvisible") != -1)
			{
				_canBeInvisible = false;
				ChangeVisibility(true); //in case other flag flipped it to false
			}
			

			//OVERRIDERS
			//if this section is a base section, it cannot be invisible
			if(_name.toLowerCase() == "base")
			{
				_canBeInvisible = false;
				ChangeVisibility(true); //in case flag flipped it to false
			}
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function ChangeToRandomColour():void
		{
			_colour.redMultiplier = Creator.RandomRange(0.0, 1.0);
			_colour.greenMultiplier = Creator.RandomRange(0.0, 1.0);
			_colour.blueMultiplier = Creator.RandomRange(0.0, 1.0);
			_clip.transform.colorTransform = _colour;
		}
		
		public function ChangeColour(colour:uint):void
		{
			_colour.color = colour;
			_clip.transform.colorTransform = _colour;
		}

		public function ChangeVisibility(visibility:Boolean):void
		{
			_visibility =  visibility;
			_clip.visible = _visibility;
		}

		public function CopyDataFromOther(section:Section):void
		{
			_name = section.Name;
			ChangeColour(section.Colour);
			ChangeVisibility(section.Visibility);
		}
		/*-------------------------------------------------------EVENTS------------*/
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get FullName():String { return _fullName; }
		public function get Name():String { return _name; }
		public function get Clip():MovieClip { return _clip; }
		public function get Colour():uint { return _colour.color; }
		public function get Visibility():Boolean { return _clip.visible; }

		//flags
		public function get CanBeInvisible():Boolean { return _canBeInvisible; }

	}

}