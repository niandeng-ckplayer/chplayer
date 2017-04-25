package chaction.style {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-03-17
	*/
	import flash.display.Stage;
	import flash.display.Sprite;
	import chaction.act.element;

	public class logo extends Sprite {
		private var S: Stage = null;
		private var L: Sprite = null;
		public function logo(s: Stage = null, f: Object = null):void {
			// constructor code
			S = s;
			if (f.hasOwnProperty("logo") && f["logo"] != "") {
				var obj: Object = {
					text: f["logo"],
					size: 28,
					bgAlpha: 0
				};
				L = element.newPromptText(obj);
				S.addChild(L);
				changeCoor();
			}
		}
		public function changeCoor(): void { //修改坐标
			var stageW:int=S.stageWidth;
			var stageH:int=S.stageHeight;
			if (L != null) {
				L.x = stageW - L.width;
				//L.y =10;
			}
		}

	}

}