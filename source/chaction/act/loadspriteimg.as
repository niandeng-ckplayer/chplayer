package chaction.act {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-03-17
	*/
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;

	public class loadspriteimg {
		

		public static function loadimg(url: String, w: int = 0, h: int = 0,radius:int=0): Sprite {
			var load: Loader = null;
			var sprite: Sprite = new Sprite();
			loadImg();
			function loadImg(): void {
				load = new Loader();
				load.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				load.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler); //监听加载失败
				load.load(new URLRequest(url));
			}
			function completeHandler(event: Event): void {
				load.width = w;
				load.height = h;
				sprite.addChild(load);
				if(radius>0){
					var spObj:Object={
						bgColor:"#FFFFFF",
						width:w,
						height:h,
						radius:radius
					};
					var mSprite:Sprite=element.newSprite(spObj);
					sprite.addChild(mSprite);
					load.mask=mSprite;
				}
			}
			function errorHandler(event: IOErrorEvent): void {
				remove();
			}
			function remove(): void {
				load.removeEventListener(Event.COMPLETE, completeHandler);
				load.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				load = null;
			}
			return sprite;
		}

	}

}