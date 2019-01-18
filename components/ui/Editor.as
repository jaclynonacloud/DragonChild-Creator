package components.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import components.*;

	public class Editor
	{
		private static var _main:MC_Editor;
		private static var _views:Vector.<MovieClip>;
		private static var _pops:Vector.<MovieClip>;

		private static var _listView:ListView;
		private static var _scrollView:ScrollView;
		private static var _scrollbar:Scrollbar;
		private static var _colourPicker:ColourPicker;

		private static var _currPart:Part;
		private static var _currSection:Section;

		private static var _lastColours:Vector.<uint> = new Vector.<uint>();

		private static var _size:Rectangle;

		/*-------------------------------------------------------METHODS-----------*/
		public static function Setup():void
		{
			//create the editor
			_main = new MC_Editor();
			_views = new <MovieClip>[_main.main, _main.list, _main.palette];
			_pops = new <MovieClip>[_main.palette.pop0, _main.palette.pop1, _main.palette.pop2, _main.palette.pop3, _main.palette.pop4, _main.palette.pop5, _main.palette.pop6, _main.palette.pop7];
			_size = new Rectangle(0, 0, _main.width, _main.height);

			//setup general
			_main.btnClose.buttonMode = true;
			_main.txtName.mouseEnabled = false;

			//setup scrollbar
			_scrollbar = new Scrollbar(Creator.Main, _main.list.scrollbar.area, _main.list.scrollbar.scrollbar);
			//setup listview
			_listView = new ListView(_main.list.content, false);
			//setup scrollview
			_scrollView = new ScrollView(_listView, _main.list.container, _scrollbar);

			//trace("0: " + _main.palette + ", 1: " + _main.palette.colourPicker.overlay + ", 2: " + _main.palett)
			//setup colour picker
			_colourPicker = new ColourPicker(_main.palette, _main.palette.colourPicker.value, _main.palette.colourPicker.hue.picker, _main.palette.colourPicker.cursor, _main.palette.colourPicker.hue.cursor);




			//add listeners
			_main.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, onClose);
			_main.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, onGoBack);
			_main.main.btnPalette.addEventListener(MouseEvent.MOUSE_DOWN, onSwitchToList);
			_main.main.btnSnap.addEventListener(MouseEvent.MOUSE_DOWN, onSnap);
			_main.main.btnReturn.addEventListener(MouseEvent.MOUSE_DOWN, onReturn);
			_main.main.btnCopy.addEventListener(MouseEvent.MOUSE_DOWN, onCopy);
			_main.main.btnUp.addEventListener(MouseEvent.MOUSE_DOWN, onShiftUp);
			_main.main.btnDown.addEventListener(MouseEvent.MOUSE_DOWN, onShiftDown);
			_main.palette.btnConfirm.addEventListener(MouseEvent.MOUSE_DOWN, onPaletteConfirm);
			_main.palette.btnRevert.addEventListener(MouseEvent.MOUSE_DOWN, onPaletteRevert);
			_main.palette.txtNewHex.addEventListener(KeyboardEvent.KEY_DOWN, onHexChange);

			_colourPicker.addEventListener(Event.CHANGE, onColourChange);
		}

		public static function Show(attach:DisplayObjectContainer, part:Part):void
		{
			if(_currPart != part)
			{

				//if the editor had already been open, revert colour picker
				if(IsVisible)
				{
					//find the last part and their respective section and set the colour back
					if(_currSection != null)
						_currSection.ChangeColour(_colourPicker.InitColour);
				}

				_currPart = part;

				//clear list
				_listView.Clear();
				//update list view with sections
				for each(var section:Section in _currPart.Sections)
				{
					//create item
					var item:Section_Item = new Section_Item();
					_listView.AddItem(item);

					item.btnVisible.buttonMode = true;
					item.btnVisible.addEventListener(MouseEvent.MOUSE_DOWN, onItemVisibilityClick);
				}
				//update items
				UpdateItems();

				//update scroller
				_scrollView.Update();
					
				//reset scrollview to top
				_scrollView.Reset();

				Move();
			}

			//show the main first
			SwitchToMain();			

			//attach to supplied parent
			attach.addChild(_main);

			_main.main.btnSnap.alpha = 1;
			_main.main.btnSnap.useHandCursor  = true;
			if(!_main.main.btnSnap.hasEventListener(MouseEvent.MOUSE_DOWN))
				_main.main.btnSnap.addEventListener(MouseEvent.MOUSE_DOWN, onSnap);
			_main.main.btnReturn.alpha = 1;
			_main.main.btnReturn.useHandCursor  = true;
			if(!_main.main.btnReturn.hasEventListener(MouseEvent.MOUSE_DOWN))
				_main.main.btnReturn.addEventListener(MouseEvent.MOUSE_DOWN, onReturn);

			//handle copy button
			_main.main.btnCopy.alpha = 0.1;
			_main.main.btnCopy.useHandCursor = false;
			if(_main.main.btnCopy.hasEventListener(MouseEvent.MOUSE_DOWN))
				_main.main.btnCopy.removeEventListener(MouseEvent.MOUSE_DOWN, onCopy);

			//handle shift buttons
			_main.main.btnUp.alpha = 1;
			_main.main.btnUp.useHandCursor = true;
			if(!_main.main.btnUp.hasEventListener(MouseEvent.MOUSE_DOWN))
				_main.main.btnUp.addEventListener(MouseEvent.MOUSE_DOWN, onShiftUp);
			_main.main.btnDown.alpha = 1;
			_main.main.btnDown.useHandCursor = true;
			if(!_main.main.btnDown.hasEventListener(MouseEvent.MOUSE_DOWN))
				_main.main.btnDown.addEventListener(MouseEvent.MOUSE_DOWN, onShiftDown);

			//read part flags to see what can be shown
			if(_currPart.BaseObject)
			{
				_main.main.btnSnap.alpha = 0.1;
				_main.main.btnSnap.useHandCursor  = false
				_main.main.btnSnap.removeEventListener(MouseEvent.MOUSE_DOWN, onSnap);
				_main.main.btnReturn.alpha = 0.1;
				_main.main.btnReturn.useHandCursor  = false;
				_main.main.btnReturn.removeEventListener(MouseEvent.MOUSE_DOWN, onReturn);

				_main.main.btnUp.alpha = 0.1;
				_main.main.btnUp.useHandCursor = false;
				_main.main.btnUp.removeEventListener(MouseEvent.MOUSE_DOWN, onShiftUp);
				_main.main.btnDown.alpha = 0.1;
				_main.main.btnDown.useHandCursor = false;
				_main.main.btnDown.removeEventListener(MouseEvent.MOUSE_DOWN, onShiftDown);
			}
			if(!_currPart.CanSnap)
			{
				_main.main.btnSnap.alpha = 0.1;
				_main.main.btnSnap.useHandCursor  = false;
				_main.main.btnSnap.removeEventListener(MouseEvent.MOUSE_DOWN, onSnap);
			}
			if(_currPart.SnapOnly)
			{
				_main.main.btnSnap.alpha = 0.1;
				_main.main.btnSnap.useHandCursor  = false
				_main.main.btnSnap.removeEventListener(MouseEvent.MOUSE_DOWN, onSnap);
			}
			if(_currPart is ManyPart)
			{
				_main.main.btnCopy.alpha = 1;
				_main.main.btnCopy.useHandCursor = true;
				_main.main.btnCopy.addEventListener(MouseEvent.MOUSE_DOWN, onCopy);
			}
		}

		public static function Hide():void
		{
			//see if we need to access anything
			if(_currSection != null)
				if(EditorCurrentView == _main.palette)
					_currSection.ChangeColour(_colourPicker.InitColour); //set to last accepted colour


			_main.parent.removeChild(_main);
		}


		public static function Move():void
		{
			//offset position
			_main.x = _currPart.x + _currPart.width + 20;
			_main.y = _currPart.y + (_currPart.height / 2) - (_size.height / 2);

			//keep within bounds of screen
			if(_main.x + _size.width > Creator.Bounds.width)
				_main.x = Creator.Bounds.width - _size.width;
			else if(_main.x < Creator.Bounds.width * 0.5)
				_main.x = Creator.Bounds.width * 0.5;

			if(_main.y + _size.height > Creator.Bounds.height)
				_main.y = Creator.Bounds.height - _size.height;
			else if(_main.y < Creator.Bounds.y)
				_main.y = Creator.Bounds.y;
		}


		private static function SwitchToMain():void
		{
			//go to main
			_main.addChild(_main.main);

			//setup details
			_main.txtName.text = _currPart.Name;

			//hide back button
			_main.btnBack.visible = false;
		}

		private static function SwitchToList():void
		{
			//go to list
			_main.addChild(_main.list);

			//setup details
			_main.txtName.text = _currPart.Name;

			//update list
			UpdateItems();

			//show back button
			_main.btnBack.visible = true;
		}

		private static function SwitchToPalette(section:Section):void
		{
			//go to palette
			_main.addChild(_main.palette);

			//setup details
			_main.txtName.text = section.Name;
			if(!_colourPicker.SetToColour(section.Colour))
				Console.Log("Sorry, couldn't find colour.", 3000);
			_colourPicker.StartSession();

			//change init swatch
			var ct:ColorTransform = new ColorTransform();
			ct.color = section.Colour;
			_main.palette.oldSwatch.transform.colorTransform = ct;

			//set old text
			_main.palette.txtOldHex.text = "#" + section.Colour.toString(16);

			//update the pops
			UpdatePops();
			

			//show back button
			_main.btnBack.visible = true;
		}

		private static function UpdateItems():void
		{
			if(_currPart == null)
				return;

			for(var i:int = 0; i < _currPart.Sections.length; i++)
			{
				var item:MovieClip = _listView.Items[i] as MovieClip;
				var section:Section = _currPart.Sections[i];

				item.txtName.text = section.Name;
				item.btnVisible.gotoAndStop(section.Visibility ? 1 : 2);
				item.btnVisible.visible = section.CanBeInvisible;
				//colour button
				var ct:ColorTransform = new ColorTransform();
				ct.color = section.Colour;
				item.btnSwatch.transform.colorTransform = ct;

				//handle swatch clicking based on whether this layer is visible
				if(item.btnVisible.currentFrame == 1)
				{
					if(!item.btnSwatch.hasEventListener(MouseEvent.MOUSE_DOWN))
						item.btnSwatch.addEventListener(MouseEvent.MOUSE_DOWN, onItemSwatchClick);
					item.btnSwatch.buttonMode = true;
					item.btnSwatch.alpha = 1.0;
					//setup eyedropper
					if(!item.eyedropper.hasEventListener(MouseEvent.MOUSE_DOWN))
						item.eyedropper.addEventListener(MouseEvent.MOUSE_DOWN, onItemEyedropper);
					item.eyedropper.buttonMode = true;
					item.eyedropper.alpha = 1;
				}
				else
				{
					if(item.btnSwatch.hasEventListener(MouseEvent.MOUSE_DOWN))
						item.btnSwatch.removeEventListener(MouseEvent.MOUSE_DOWN, onItemSwatchClick);
					item.btnSwatch.buttonMode = false;
					item.btnSwatch.alpha = 0.2;
					if(item.eyedropper.hasEventListener(MouseEvent.MOUSE_DOWN))
						item.eyedropper.removeEventListener(MouseEvent.MOUSE_DOWN, onItemEyedropper);
					item.eyedropper.buttonMode = false;
					item.eyedropper.alpha = 0.2;
				}

			}
		}

		private static function UpdatePops():void
		{
			for(var i:int = 0; i < _lastColours.length; i++)
			{
				trace("COLOUR: " + _lastColours[i].toString(16) + ", " + i);
				if(i > _pops.length - 1)
					continue;

				var ct:ColorTransform = new ColorTransform();
				ct.color = _lastColours[i];
				_pops[i].transform.colorTransform = ct;

				//if this pop hasn't been activated, activate it now
				if(!_pops[i].hasEventListener(MouseEvent.MOUSE_DOWN))
				{
					_pops[i].addEventListener(MouseEvent.MOUSE_DOWN, onPopClick);
					_pops[i].buttonMode = true;
				}
			}
		}


		public static function AddToLastColours(colour:uint):void
		{
			if(_lastColours.indexOf(colour) != -1)
				return;

			_lastColours.push(colour);
			if(_lastColours.length > _pops.length)
				_lastColours.shift();
		}


		public static function EyedropperEnded():void
		{
			//return to usual
			(_listView.Items[_currPart.Sections.indexOf(_currSection)] as Section_Item).eyedropper.alpha = 1;
		}

		/*--CHECKS--*/
		private static function FindItemIndex(child:DisplayObjectContainer):int
		{
			//get index
			var index:int = -1;
			for(var i:int = 0; i < _listView.Items.length; i++)
			{
				var item:DisplayObjectContainer = _listView.Items[i];
				if(item.contains(child))
				{
					index = i;
					break;
				}
			}

			return index;
		}

		/*-------------------------------------------------------EVENTS------------*/
		private static function onClose(e:MouseEvent):void
		{
			Hide();
		}
		private static function onGoBack(e:MouseEvent):void
		{
			if(EditorCurrentView == _main.list)
				SwitchToMain();
			else if(EditorCurrentView == _main.palette)
			{
				//session colour was not saved, revert
				_currSection.ChangeColour(_colourPicker.InitColour);
				SwitchToList();
			}
			else
				SwitchToList();
		}
		private static function onSnap(e:MouseEvent):void
		{
			_currPart.Snap();
		}
		private static function onReturn(e:MouseEvent):void
		{
			_currPart.Return();
		}

		private static function onCopy(e:MouseEvent):void
		{
			//COPY THE PART-- only if a manypart
			if(!_currPart is ManyPart)
				return;

			var copy:ManyPart = (_currPart as ManyPart).CopyWithSectionData();
			//stagger next to original
			copy.x = _currPart.x + 10;
			copy.y = _currPart.y + 10;
			//set the copy position as well
			var index:int = Creator.Result.getChildIndex(_currPart) + 1;
			if(index > Creator.Result.numChildren - 1)
				Creator.Result.addChild(copy);
			else
				Creator.Result.addChildAt(copy, index);
			//open editor to copied part
			Editor.Show(Creator.Main, copy);
		}

		private static function onShiftUp(e:MouseEvent):void
		{
			//shift current part position
			_currPart.ShiftUp();
		}
		private static function onShiftDown(e:MouseEvent):void
		{
			//shift current part position
			_currPart.ShiftDown();
		}

		private static function onSwitchToList(e:MouseEvent):void
		{
			SwitchToList();
		}

		private static function onPaletteConfirm(e:MouseEvent):void
		{
			_colourPicker.EndSession();
			AddToLastColours(_colourPicker.Colour);
			SwitchToList();
		}

		private static function onPaletteRevert(e:MouseEvent):void
		{
			//change palette
			if(!_colourPicker.SetToColour(_colourPicker.InitColour))
				Console.Log("Sorry, couldn't find colour.", 3000);
		}
		
		private static function onHexChange(e:KeyboardEvent):void
		{
			//see if this is a submit key
			if(e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.NUMPAD_ENTER)
			{
				var text:String = (e.target).text;
				if(text.indexOf("#") != -1)
					text = text.substr(1);
				//try to parse into hex
				var hex:uint = uint("0x" + text);
				//try to change the colour picker to this
				if(!_colourPicker.SetToColour(hex))
					Console.Log("Sorry, couldn't find colour.", 3000);
			}
		}

		private static function onPopClick(e:MouseEvent):void
		{
			//change palette to pop
			if(!_colourPicker.SetToColour((e.target as MovieClip).transform.colorTransform.color))
					Console.Log("Sorry, couldn't find colour.", 3000);
		}


		/*---ITEMS---*/
		private static function onItemSwatchClick(e:MouseEvent):void
		{
			//get index
			var index:int = FindItemIndex(e.target as Sprite);

			if(index == -1)
				return;
			//go to target
			_currSection = _currPart.Sections[index];
			SwitchToPalette(_currSection);
		}
		private static function onItemVisibilityClick(e:MouseEvent):void
		{
			//get index
			var index:int = FindItemIndex(e.target as Sprite);

			if(index == -1)
				return;
			//toggle visibility if we can
			var section:Section = _currPart.Sections[index];
			section.ChangeVisibility(!section.Visibility);

			UpdateItems();
		}
		private static function onItemEyedropper(e:MouseEvent):void
		{
			//get index
			var index:int = FindItemIndex(e.target as Sprite);

			if(index == -1)
				return;

			//set to current section 
			_currSection = _currPart.Sections[index];
			//dim eyedropper
			(_listView.Items[_currPart.Sections.indexOf(_currSection)] as Section_Item).eyedropper.alpha = 0.3;
			//use eyedropper to get colour
			Creator.StartEyedropper();
		}

		public static function SendColourToSection(colour:uint):void
		{
			_currSection.ChangeColour(colour);
			UpdateItems();
			//set colour
			_colourPicker.SetSessionColour(colour);
			//give to last used colours
			AddToLastColours(colour);
		}

		/*---COLOUR PICKER---*/
		private static function onColourChange(e:Event):void
		{
			//trace("CHANGED: " + "0x" + _colourPicker.Colour.toString(16));
			var cT:ColorTransform = new ColorTransform();
			cT.color = _colourPicker.Colour;
			_main.palette.newSwatch.transform.colorTransform = cT;

			_main.palette.txtNewHex.text = "#" + _colourPicker.Colour.toString(16);

			//toggle section colour
			if(_currSection != null)
				_currSection.ChangeColour(_colourPicker.Colour);
		}

		/*-------------------------------------------GETTERS and SETTERS-----------*/
		public static function get IsVisible():Boolean { return _main.parent != null; }
		public static function IsVisibleOn(part:Part):Boolean { return !IsVisible ? false : _currPart == part ? true : false; }
		public static function get EditorCurrentView():MovieClip { return _main.getChildAt(_main.numChildren - 1) as MovieClip; }

		public static function get EditorColourPicker():ColourPicker { return _colourPicker; }
	}


}