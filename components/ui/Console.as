package components.ui
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextField;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;

	public class Console
	{
		private static var _main:Sprite;
		private static var _text:TextField;

		private static var _timer:Timer;
		private static var _showing:Boolean = false;

		
		/*-------------------------------------------------------METHODS-----------*/
		/*It is assumed that the console main is lying just above the bottom of the stage.*/
		public static function Setup(main:Sprite, text:TextField):void
		{
			_main = main;
			_text = text;

			_main.y += _main.height;
		}

		public static function Log(output:String, duration:int = 2000):void
		{
			if(_main == null)
				return;

			//if we're already open, don't show new log
			if(_showing)
				return;

			_showing = true;

			_text.text = output;

			//setup timer
			_timer = new Timer(duration, 1);
			//listen to timer
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeFinished);

			//show console
			var tween:Tween = new Tween(_main, "y", Regular.easeIn, _main.y, _main.y - _main.height, 12, false);
			tween.addEventListener(TweenEvent.MOTION_FINISH, onTweenDownComplete);
		}

		public static function Close():void
		{
			_timer.stop();
			_showing = false;
		}
		/*-------------------------------------------------------EVENTS------------*/
		//timer stuff
		private static function onTimeFinished(e:TimerEvent):void
		{
			//kill listener
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeFinished);

			//hide console
			var tween:Tween = new Tween(_main, "y", Regular.easeOut, _main.y, _main.y + _main.height, 12, false);
			tween.addEventListener(TweenEvent.MOTION_FINISH, onTweenUpComplete);
		}

		//tween stuff
		private static function onTweenDownComplete(e:TweenEvent):void
		{
			//kill listener
			(e.target as Tween).removeEventListener(TweenEvent.MOTION_FINISH, onTweenDownComplete);

			//start timer now
			_timer.start();
		}

		private static function onTweenUpComplete(e:TweenEvent):void
		{
			//kill listener
			(e.target as Tween).removeEventListener(TweenEvent.MOTION_FINISH, onTweenUpComplete);

			Close();
		}

		/*-------------------------------------------GETTERS and SETTERS-----------*/
	}
}