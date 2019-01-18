package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.ui.Keyboard;
	import components.*;
	import managers.*;
	import controllers.*;
	import components.ui.*;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.ByteArray;
	import flash.net.FileReference;

	public class Creator extends MovieClip
	{
		private static var _stage:Stage;
		private static var _bounds:Rectangle;
		private static var _eyedropper:MovieClip;
		private static var _character:MovieClip;
		public static var _result:MovieClip;

		private static var _eyedropperCT:ColorTransform = new ColorTransform();
		private static var _sceneBitmap:BitmapData;

		public function Creator()
		{
			gotoAndStop(1);
			addEventListener(Event.ENTER_FRAME, onEnterLoading);			
		}
		
		private function onEnterLoading(e:Event):void
		{
			// Calculate the percentage of the movie that has loaded.
			var percentage:Number = Math.round(loaderInfo.bytesLoaded / loaderInfo.bytesTotal) * 100;
			// Put the percentage loaded into the textarea, e.g. "47%"
			txtLoading.text = percentage + "%";
			trace("LOADED: " + percentage);
			// Check if the percentage variable is equal to 100
			if(percentage >= 100){
				// remove the onEnterFrame loop we started above
				removeEventListener(Event.ENTER_FRAME, onEnterLoading);
				// go and start your movie
				gotoAndStop(2);	
				Setup();
			}
		}
		
		public function Setup():void
		{
			_stage = stage;
			_bounds = new Rectangle(stage.x, stage.y, stage.width, stage.height);
			_eyedropper = eyedropper;
			_character = character;
			_result = result;

			//setup
			Editor.Setup();
			Pager.Setup(pager);
			Console.Setup(console, console.txtOutput);

			//run hints
			Hints.Run();

			
			GroupsManager.Setup(character);
			DragController.Setup(stage);

			
			//hide credits initially
			credits.visible = false;

			Console.Log("Welcome to the Dragon Child Creator!");

			//save
			btnSave.addEventListener(MouseEvent.MOUSE_DOWN, onSave);
		}

		/*-------------------------------------------------------METHODS-----------*/
		public static function StartEyedropper():void
		{
			Main.addChild(_eyedropper);
			_eyedropper.visible = true;

			//draw the scene bitmap
			_sceneBitmap = new BitmapData(Main.width, Main.height);
			_sceneBitmap.draw(Main);

			Main.addEventListener(Event.ENTER_FRAME, onEyedropping);
			_eyedropper.addEventListener(MouseEvent.MOUSE_DOWN, onEndEyedropping);
			//listen for an escape
			Main.addEventListener(KeyboardEvent.KEY_DOWN, onEyedroppingEscape);
		}
		public static function UpdateEyedropper(x:Number, y:Number, colour:uint):void
		{
			_eyedropper.swatch.x = x + 10;
			_eyedropper.swatch.y = y;
			_eyedropperCT.color = colour;
			_eyedropper.swatch.swatch.transform.colorTransform = _eyedropperCT;
		}
		public static function StopEyedropper():void
		{
			_eyedropper.visible = false;

			//kill listeners
			Main.removeEventListener(Event.ENTER_FRAME, onEyedropping);
			_eyedropper.removeEventListener(MouseEvent.MOUSE_DOWN, onEndEyedropping);
			Main.removeEventListener(KeyboardEvent.KEY_DOWN, onEyedroppingEscape);
		}
		/*-------------------------------------------------------EVENTS------------*/
		private function onSave(e:MouseEvent):void
		{
			//turn on credits
			credits.visible = true;
			//attach everything to final
			final.addChild(background);
			final.addChild(namePlaque);
			final.addChild(result);
			final.addChild(credits);

			//create bitmapdata
			var bitmap:BitmapData = new BitmapData(background.width, background.height);
			bitmap.draw(final);

			//get bytes for file reference
			var bytes:ByteArray = PNGEncoder.encode(bitmap);

			//save to file reference
			var file:FileReference = new FileReference();
			file.save(bytes, "creatorImage.png");

			//return the stuff to the stage
			addChild(background);
			addChild(namePlaque);
			addChild(result);
			addChild(credits);
			credits.visible = false;
			addChild(btnSave);
		}

		private static function onEyedropping(e:Event):void
		{
			//get the colour at the current position
			var colour:uint = _sceneBitmap.getPixel(_character.mouseX, _character.mouseY);
			UpdateEyedropper(Main.mouseX, Main.mouseY, colour);
		}

		private static function onEndEyedropping(e:MouseEvent):void
		{
			//tell editor we found a colour
			var colour:uint = _sceneBitmap.getPixel(_character.mouseX, _character.mouseY);
			Editor.SendColourToSection(colour);

			StopEyedropper();
		}

		private static function onEyedroppingEscape(e:KeyboardEvent):void
		{
			if(e.keyCode != Keyboard.ESCAPE)
				return;

			_eyedropper.removeEventListener(MouseEvent.MOUSE_DOWN, onEndEyedropping);

			StopEyedropper();
			Editor.EyedropperEnded();
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public static function get Main():Stage { return _stage; }
		public static function get Bounds():Rectangle { return _bounds; }
		public static function get Result():MovieClip { return _result; }







		/*-------------------------------------------HELPFUL METHODS---------------*/
		/**http://www.purplesquirrels.com.au/2013/01/as3-split-a-camel-case-string/**/
		public static function SplitCamelCase(str:String, capitaliseFirst:Boolean = true):String
		{
		    var r:RegExp = /(^[a-z]|[A-Z0-9])[a-z]*/g;
		    var result:Array = str.match(r);
		    
		    if (result.length > 0)
		    {
		        if (capitaliseFirst)
		            result[0] = String(result[0]).charAt(0).toUpperCase() + String(result[0]).substring(1);
		        
		        return result.join(" ");
		    }
		    
		    return str;
		}

		/**https://code.tutsplus.com/tutorials/quick-tip-get-a-random-number-within-a-specified-range-using-as3--active-3142**/
		public static function RandomRange(minNum:Number, maxNum:Number):Number 
		{
		    return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}

		/**http://www.keendevelopment.ch/getting-the-class-of-an-object-in-as3/**/
		public static function GetClass(obj:Object):Class 
		{
	       return Class(getDefinitionByName(getQualifiedClassName(obj)));
	    }


		

	}
}