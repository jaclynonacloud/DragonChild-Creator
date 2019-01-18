package
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import components.ui.Console;

	public class Hints
	{
		private static var _hints:Array = [
			"TIP: By clicking on the eyedropper next to a layer name, you can select a colour from the scene to paint this layer.",
			"TIP: Some parts only allow one of its kind to be showing at once.  These parts have group numbers on the bottom left of their item picture.",
			"TIP: A part image with an icon in the bottom right is a multi part.  Many of these can be placed in the scene.",
			"TIP: Not all parts can be snapped.  If the snap icon in their editor is greyed out, there is no snap.",
			"TIP: The copy button in the editor is for multi parts.  You can find these parts by looking for them in the part grid.",
			"TIP: You can change the order of parts by clicking the shift buttons in their editor.",
			"TIP: Some parts are snap only, meaning you can't drag them.  A magnet icon will be on their item picture if they are one.",
			"TIP: Like your dragon child?  Save them as an image by clicking the save button!",
			"TIP: Having trouble opening the editor?  Try right-clicking the part!",
			"TIP: Have a specific colour in mind? You can type your colour into the hex text of the colour picker.  Just be sure to press enter!",
			"TIP: Checked Out on a part image means the part is already somewhere on your dragon!  You can return the part to the part grid by clicking.",
			"TIP: Copying a coloured part will create a copy with the same colours!",
			"TIP: Clicking a layer swatch square will open the colour picker!",
			"TIP: Can't click a layer swatch?  Make sure the layer is turned on.",
			"TIP: Need to work on parts under another part?  You can return the part to the grid and bring it back later.  It keeps its colours!",
			"TIP: Some parts have layers that are initially turned off.  Feel free to toggle them and check them out!",
			"TIP: Don't forget to change your dragon child's name!  Click the name text in the top left to change it!"
		];

		private static var _timer:Timer;
		private static var _lastHint:int = 0;


		/*-------------------------------------------------------METHODS-----------*/
		public static function Run(interval:int = 60000):void
		{
			//run the timer
			_timer = new Timer(interval, 0);
			_timer.addEventListener(TimerEvent.TIMER, onInterval);

			_timer.start();
		}
		/*-------------------------------------------------------EVENTS------------*/
		private static function onInterval(e:TimerEvent):void
		{
			var index:int = Creator.RandomRange(0, _hints.length - 1);
			//make sure the same hint doesn't play twice in a row
			while(index == _lastHint)
				index = Creator.RandomRange(0, _hints.length - 1);

			//play console
			Console.Log(_hints[index], 8000);
			//set this to our last hint
			_lastHint = index;
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
	}
}