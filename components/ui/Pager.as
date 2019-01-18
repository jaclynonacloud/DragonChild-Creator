package components.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import components.*;
	import events.GridEvent;
	import events.ListEvent;
	import controllers.*;

	public class Pager
	{
		private static var _main:MovieClip;
		private static var _groups:Vector.<Group>;

		private static var _headerScrollView:ScrollView;
		private static var _groupsListView:ListView;
		private static var _partsGridView:GridView;


		private static var _currGroup:Group;
		private static var _pageIndex:int = 0;

		/*-------------------------------------------------------METHODS-----------*/
		public static function Setup(main:MovieClip):void
		{
			_main = main;
			_groups = new Vector.<Group>();

			//setup scroll header list
			var scrollbar:Scrollbar = new Scrollbar(Creator.Main, _main.headerContainer.scrollbar.area, _main.headerContainer.scrollbar.scrollbar);
			_headerScrollView = new ScrollView(_main.headerContainer.content, _main.headerContainer.container, scrollbar);

			//setup views
			_groupsListView = new ListView(_main.headerContainer.content);
			_partsGridView = new GridView(_main.container, 4, 3, true, new Point(0, 5));

			//setup buttons and mouse enables
			_main.header.txtName.mouseEnabled = false;
			_main.header.buttonMode = true;

			//add listeners
			_main.header.addEventListener(MouseEvent.MOUSE_DOWN, onHeaderClick);
			_groupsListView.addEventListener(ListEvent.ITEM_CLICK, onGroupClick);
			_partsGridView.addEventListener(GridEvent.ITEM_CLICK, onPartClick);

			_main.prev.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			_main.next.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
		}

		public static function AddGroup(group:Group):void
		{
			//create item
			var item:Pager_HeaderItem = new Pager_HeaderItem();
			item.txtName.text = group.Name;
			item.txtName.mouseEnabled = false;

			//add to list view
			_groupsListView.AddItem(item);

			//add to groups
			_groups.push(group);

			_headerScrollView.Update();

			//if this was our first item, set the name and group
			if(_currGroup == null)
				OpenGroup(group);

			//HOWEVER, if this group is called body, make it first
			if(group.Name.toLowerCase() == "body")
				OpenGroup(group);
		}

		public static function OpenGroup(group:Group):void
		{
			//if this is the same group, don't redraw
			if(group == _currGroup)
				return;

			_currGroup = group;

			_main.header.txtName.text = group.Name;

			GoToPage(0);
		}

		public static function PrevPage():void
		{
			_pageIndex--;
			GoToPage(_pageIndex);
		}

		public static function NextPage():void
		{
			_pageIndex++;
			GoToPage(_pageIndex);
		}

		private static function GoToPage(index:int):void
		{
			//clamp
			index = index < 0 ? 0 : index;
			_pageIndex = index;

			//is there a previous page?
			if(index <= 0) _main.prev.visible = false;
			else _main.prev.visible = true;

			//is there a next page?
			var anotherPage:Boolean = _partsGridView.TotalElements * (index + 1) < _currGroup.Parts.length ? true : false;
			if(anotherPage) _main.next.visible = true;
			else _main.next.visible = false;

			//clear initial
			_partsGridView.Clear();

			//setup elements on this page
			//for(var i:int = _partsGridView.TotalElements * index; i < _partsGridView.TotalElements; i++)
			var start:int = _partsGridView.TotalElements * index;
			var end:int = start + _partsGridView.TotalElements;

			for(var i:int = start; i < end; i++)
			{
				if(i > _currGroup.Parts.length - 1)
					continue;

				//add item
				_partsGridView.AddItem(_currGroup.Parts[i].Item);
			}
		}



		/*--HEADER STUFF--*/
		private static function OpenHeader():void
		{
			_main.headerContainer.visible = true;
			//hide buttons
			_main.prev.alpha = 0;
			_main.next.alpha = 0;
		}
		private static function CloseHeader():void
		{
			_main.headerContainer.visible = false;
			//show buttons
			_main.prev.alpha = 1;
			_main.next.alpha = 1;
		}

		/*-------------------------------------------------------EVENTS------------*/
		private static function onHeaderClick(e:MouseEvent):void
		{
			//toggle header
			if(_main.headerContainer.visible)
				CloseHeader();
			else
				OpenHeader();
		}

		private static function onGroupClick(e:ListEvent):void
		{
			//get group
			var index:int = e.index;
			OpenGroup(_groups[index]);
			//close header
			CloseHeader();
		}

		private static function onPartClick(e:GridEvent):void
		{
			var pos:int = _pageIndex > 0 ? (_partsGridView.TotalElements * _pageIndex) + e.index : e.index;
			var part:Part = _currGroup.Parts[pos];

			if(part == null)
				return;

			//if this is a many part, create a new instance to control
			if(part is ManyPart)
				//part = (part as ManyPart).CopyWithSectionData();
				//clip:*, name:String, pos:Point, par:DisplayObjectContainer
				part = new ManyPart(part.Clip, part.FullName, part.SnapPoint, part.Container, part.PreferredPlacement);

			part.Use();
		}

		private static function onPrev(e:MouseEvent):void
		{
			PrevPage();
		}

		private static function onNext(e:MouseEvent):void
		{
			NextPage();
		}
		/*-------------------------------------------GETTERS and SETTERS-----------*/
	}
}