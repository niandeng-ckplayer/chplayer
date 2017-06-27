package chaction.style {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-04-12
	*/
	import flash.display.Stage;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import chaction.act.script;

	public class menu {
		private var mArr:Array=[];
		private var menuClick:Function=null
		public function menu(sp: Sprite,eve:Function, arr: Array = null) {
			// constructor code
			mArr=arr;
			menuClick=eve;
			if (!mArr) {
				return;
			}
			var newContextMenu: ContextMenu = new ContextMenu();
			newContextMenu.hideBuiltInItems();
			for (var i: int = 0; i < mArr.length; i++) {
				var m: Array = mArr[i];
				var click: Boolean = m[1] != "default" ? true : false;
				var item: ContextMenuItem = new ContextMenuItem(m[0], false, click);
				if(m.length>=4 && m[3]=="line"){
					item.separatorBefore=true;
				}
				if (m[1] != "default") {
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, itemClickHandler);
				}
				newContextMenu.customItems.push(item);
			}
			sp.contextMenu = newContextMenu;

		}
		private function itemClickHandler(event: ContextMenuEvent):void{
			var itemText: String = event.target.caption;
			for (var i: int = 0; i < mArr.length; i++) {
				var m: Array = mArr[i];
				if(m[0]==itemText){
					switch(m[1]){
						case "link":
							script.openLink(m[2]);
							break;
						case "function":
							menuClick(m[2]);
							break;
						case "javascript":
							script.callJs(m[2]);
							break;
						default:
							break;
					}
				}
			}
		}

	}

}