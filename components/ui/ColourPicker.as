package components.ui
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.geom.ColorTransform;
	import flash.events.Event;
	import flash.geom.Point;

	/**Creates a colour picker object.**/
	public class ColourPicker extends Sprite
	{
		private var _container:DisplayObjectContainer;
		private var _valuePicker:MovieClip;
		private var _valueOverlay:DisplayObjectContainer;
		private var _huePicker:MovieClip;
		private var _valueCursor:DisplayObjectContainer;
		private var _hueCursor:DisplayObjectContainer;

		private var _valueBitmap:BitmapData;
		private var _hueBitmap:BitmapData;

		private var _hue:uint;
		private var _colour:uint;
		private var _overlayCT:ColorTransform = new ColorTransform();

		private var _initHue:uint;
		private var _initColour:uint;

		public function ColourPicker(container:DisplayObjectContainer, valuePicker:MovieClip, huePicker:MovieClip, valueCursor:DisplayObjectContainer, hueCursor:DisplayObjectContainer)
		{
			_container = container;
			_container.parent.addChild(this);
			addChild(_container);

			_valuePicker = valuePicker;
			if(_valuePicker.getChildByName("overlay") != null)
				_valueOverlay = _valuePicker.getChildByName("overlay") as DisplayObjectContainer;
			_huePicker = huePicker;
			_valueCursor = valueCursor;
			_hueCursor = hueCursor;

			//colour picker requires picker and hue picker
			if(_valuePicker == null || _huePicker == null || _valueOverlay == null)
				return;

			//setup buttonmode
			_valuePicker.buttonMode = true;
			_huePicker.buttonMode = true;

			//create bitmaps
			_valueBitmap = new BitmapData(_valuePicker.parent.width, _valuePicker.parent.height);
			_valueBitmap.draw(_valuePicker);
			_hueBitmap = new BitmapData(_huePicker.width, _huePicker.height);
			_hueBitmap.draw(_huePicker);

			//set cursor if available
			if(_valueCursor != null)
			{
				_valuePicker.parent.addChild(_valueCursor);
				_valueCursor.mouseEnabled = false;				
				_valueCursor.blendMode = BlendMode.DIFFERENCE;
			}
			if(_hueCursor != null)
			{
				_hueCursor = hueCursor;
				_hueCursor.mouseEnabled = false;
			}

			//hide cursor initially
			HideCursor();


			//setup listeners
			_valuePicker.addEventListener(MouseEvent.MOUSE_DOWN, onValuePickerStart);
			_valuePicker.addEventListener(MouseEvent.MOUSE_UP, onValuePickerSelect);
			_valuePicker.addEventListener(MouseEvent.MOUSE_OUT, onValuePickerSelect);
			_huePicker.addEventListener(MouseEvent.MOUSE_DOWN, onHuePickerStart);
			_huePicker.addEventListener(MouseEvent.MOUSE_UP, onHuePickerSelect);
			_huePicker.addEventListener(MouseEvent.MOUSE_OUT, onHuePickerSelect);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public function StartSession():void
		{
			_initColour = _colour;
			_initHue = _hue;
		}

		public function EndSession():void
		{
			_initColour = _colour;
			_initHue = _hue;
		}

		public function SetSessionColour(colour:uint):void
		{
			_colour = colour;
			_initColour = colour;
		}

		public function ChangeHue(hue:uint = 0xFF0000):void
		{
			_hue = hue;
			_overlayCT.color = _hue;
			_valueOverlay.transform.colorTransform = _overlayCT;
			
			_valueBitmap.draw(_valuePicker);	

			//try to find position
			var position:Point = FindColourPixel(_hue, _hueBitmap);
			if(position != null)
				SlideHueCursor(position.y);

			//get new colour
			_colour = _valueBitmap.getPixel(_valueCursor.x, _valueCursor.y);
		}

		public function ChangeColour(colour:uint):void
		{
			 _colour = colour;

			 //try to find position
			 var position:Point = FindColourPixel(_colour, _valueBitmap);
			 if(position != null)
			 	ShowCursor(position.x, position.y);
		}

		private function SlideHueCursor(y:Number):void
		{
			if(_hueCursor == null)
				return;
			
			_hueCursor.y = y;
		}

		public function ShowCursor(x:Number, y:Number):void
		{
			if(_valueCursor == null)
				return;

			if(!_valueCursor.visible)
				_valueCursor.visible = true;

			_valueCursor.x = x;
			_valueCursor.y = y;
		}

		public function HideCursor():void
		{
			if(_valueCursor == null)
				return;

			if(_valueCursor.visible)
				_valueCursor.visible = false;
		}

		//FINDERS
		public function SetToColour(colour:uint):Boolean
		{
			//if we are already at this colour, don't do this
			if(colour == _valueBitmap.getPixel(_valueCursor.x, _valueCursor.y))
				return true;

			//get current positions
			var currHue:uint = _hue;

			//iterate through hues
			for(var h:int = 0; h < _huePicker.height; h++)
			{
				//get the hue
				var hueColour:uint = _hueBitmap.getPixel(_hueBitmap.width / 2, h);
				ChangeHue(hueColour);
				//look for the colour
				if(FindColourPixel(colour, _valueBitmap) != null)
				{
					ChangeColour(colour);

					//set event
					dispatchEvent(new Event(Event.CHANGE));
					dispatchEvent(new Event(Event.SELECT));
					return true;
				}
			}
			return false;
			//if it didn't work, reset to before
			ChangeHue(currHue);

			return false;
		}

		private function FindColourPixel(colour:uint, bitmap:BitmapData):Point
		{
			//look for colour position on hue
			for(var w:int = 0; w < bitmap.width; w++)
				for(var h:int = 0; h < bitmap.height; h++)
					if(bitmap.getPixel(w, h) == colour)
						return new Point(w, h);

			return null;
		}
		/*-------------------------------------------------------EVENTS------------*/
		//VALUE
		private function onValuePickerStart(e:MouseEvent):void
		{
			_valuePicker.addEventListener(MouseEvent.MOUSE_MOVE, onValuePickerMove);
			//simulate move
			onValuePickerMove(e);
		}
		private function onValuePickerMove(e:MouseEvent):void
		{
			//get color at point
			_colour = _valueBitmap.getPixel(_valuePicker.mouseX, _valuePicker.mouseY);
			//UpdateNewSwatch(col);
			
			ShowCursor(_valuePicker.parent.mouseX, _valuePicker.parent.mouseY);

			//call event
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function onValuePickerSelect(e:MouseEvent):void
		{

			//stop listening
			_valuePicker.removeEventListener(MouseEvent.MOUSE_MOVE, onValuePickerMove);
			//call event
			dispatchEvent(new Event(Event.SELECT));
		}


		//HUE
		private function onHuePickerStart(e:MouseEvent):void
		{
			_huePicker.addEventListener(MouseEvent.MOUSE_MOVE, onHuePickerMove);
			//simulate move
			onHuePickerMove(e);
		}
		private function onHuePickerMove(e:MouseEvent):void
		{
			//change the overlay color
			var color:uint = _hueBitmap.getPixel(0, _huePicker.mouseY);
			ChangeHue(color);
			//show the cursor
			SlideHueCursor(_huePicker.mouseY);

			//call event
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function onHuePickerSelect(e:MouseEvent):void
		{

			//stop listening
			_huePicker.removeEventListener(MouseEvent.MOUSE_MOVE, onHuePickerMove);
			//call event
			dispatchEvent(new Event(Event.SELECT));
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public function get Hue():uint { return _hue; }
		public function get Colour():uint { return _colour; }
		public function get InitHue():uint { return _initHue; }
		public function get InitColour():uint { return _initColour; }

	}
}