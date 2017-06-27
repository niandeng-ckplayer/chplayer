package chaction.act {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-04-07
	*/
	import flash.display.Sprite;
	import flash.text.TextField;
	import chaction.act.script;
	import flash.text.TextFormat;
	import flash.display.SimpleButton;

	public class element {

		public static function newSprite(cObj: Object = null): Sprite { //建立一个圆角矩形
			var con: Object = {
				bgColor: null, //背景颜色
				borderColor: null, //边框颜色
				border:1,
				radius: 0, //圆角弧度
				bgAlpha: 1, //背景透明度
				width: 0,
				height: 0
			};
			con = script.mergeObject(con, cObj);
			//trace(con["width"], con["height"], con["radius"], con["radius"]);
			var sprite: Sprite = new Sprite();
			if (con["borderColor"]!=null) {
				sprite.graphics.lineStyle(con["border"], con["borderColor"], con["bgAlpha"]);
			}
			if (con["bgColor"]!=null) {
				sprite.graphics.beginFill(con["bgColor"], con["bgAlpha"]); //背景色，透明度
			}
			sprite.graphics.drawRoundRect(0, 0, con["width"], con["height"], con["radius"], con["radius"]);
			return sprite;
		}
		public static function newPromptText(cObj: Object = null): Sprite {
			var con: Object = {
				bgColor: 0x000000, //背景颜色
				borderColor: null, //边框颜色
				radius: 0, //圆角弧度
				bgAlpha: 1, //背景透明度
				width: 0,
				height: 0,
				text: "",
				textColor: 0xFFFFFF,
				size: 14,
				leading:0,
				face: "Microsoft YaHei,\5FAE\8F6F\96C5\9ED1,微软雅黑"
			};
			con = script.mergeObject(con, cObj);
			var text: TextField = new TextField();

			var format: TextFormat = new TextFormat();
			format.leading = con["leading"];
			format.size = con["size"];
			format.font = con["face"];
			format.color = con["textColor"];
			text.defaultTextFormat = format;
			text.text = con["text"];
			text.width = text.textWidth + 5;
			text.height = text.textHeight + con["size"] * 0.3;
			con["width"] = con["width"] > 0 ? con["width"] : text.width + 20;
			con["height"] = con["height"] > 0 ? con["height"] : text.textHeight + 10;

			var sprite: Sprite = newSprite(con);
			text.x = (sprite.width - text.width) * 0.5;
			text.y = (sprite.height - text.height) * 0.5;

			sprite.addChild(text);
			return sprite;
		}
		public static function newLine(p: Object = null): Sprite { //建立直线
			var o: Object = {
				color: 0x000000, //背景颜色
				alpha: 1, //透明度
				width: 1,
				height: 1
			};
			o = script.mergeObject(o, p);
			var s: Sprite = new Sprite();
			s.graphics.lineStyle(o["height"], o["color"]);
			s.graphics.moveTo(0, 0);
			s.graphics.lineTo(o["width"], 0);
			s.alpha = o["alpha"];
			return s;
		}
		public static function newTitle(p: Object = null): TextField { //建立一个简单的文本框
			var o: Object = {
				text: "",
				color: 0xFFFFFF,
				size: 14,
				face: "Microsoft YaHei,\5FAE\8F6F\96C5\9ED1,微软雅黑",
				width: 0,
				height: 0,
				leading:0,
				alpha: 1
			}
			o = script.mergeObject(o, p);
			var text: TextField = new TextField();
			text.wordWrap=o["width"] > 0 ?true:false;
			var format: TextFormat = new TextFormat();
			format.leading = o["leading"];
			format.size = o["size"];
			format.font = o["face"];
			format.color = o["color"];
			text.defaultTextFormat = format;
			
			text.text = o["text"];
			text.width = o["width"] > 0 ? o["width"] : text.textWidth + 5;
			text.height = o["height"] > 0 ? o["height"] : text.textHeight + 3;
			text.alpha = o["alpha"];
			return text;
		}
		public static function newButton(p: Object = null): SimpleButton { //建立一个按钮
			var o: Object = {
				text: "自动",
				size: 14,
				face: "Microsoft YaHei,微软雅黑",
				left: 15,
				right: 15,
				top: 3,
				bottom: 5,
				alpha: 1,
				alpha2: 1,
				radius: 5,
				downBg: 0x000000,
				overBg: 0x656565,
				downColor: 0xFFFFFF,
				overColor: 0x0782F5,
				over: false
			}
			o = script.mergeObject(o, p);

			var bgTextObj: Object = script.copyObject(o);
			bgTextObj["color"] = o["downColor"];
			bgTextObj["alpha"] = 1;
			var bgText: TextField = newTitle(bgTextObj);
			var bgBg: Object = script.copyObject(o);
			bgBg["bgColor"] = o["downBg"];
			bgBg["bgAlpha"] = o["alpha"];
			bgBg["width"] = bgText.width + Math.round(o["left"]) + Math.round(o["right"]);
			//trace("height",bgText.height,o["top"],o["bottom"]);
			bgBg["height"] = bgText.height + Math.round(o["top"]) + Math.round(o["bottom"]);
			var bg: Sprite = newSprite(bgBg);
			bgText.x = o["left"];
			bgText.y = o["top"];
			bg.addChild(bgText);

			var overTextObj: Object = script.copyObject(o);
			overTextObj["color"] = o["overColor"];
			overTextObj["alpha"] = 1;
			var overText: TextField = newTitle(overTextObj);
			var overBg: Object = script.copyObject(o);
			overBg["bgColor"] = o["overBg"];
			overBg["bgAlpha"] = o["alpha2"];
			overBg["width"] = overText.width + Math.round(o["left"]) + Math.round(o["right"]);
			overBg["height"] = overText.height + Math.round(o["top"]) + Math.round(o["bottom"]);
			var over: Sprite = newSprite(overBg);
			overText.x = o["left"];
			overText.y = o["top"];
			over.addChild(overText);

			var button: SimpleButton = new SimpleButton();
			if (o["over"]) {
				button.upState = over;
			} else {
				button.upState = bg;
			}

			button.overState = over;
			button.hitTestState = over;
			button.downState = over;
			return button;
		}

	}

}