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

	public class loadimg {
		private var load: Loader = null;
		private var img:String="";
		private var successFun: Function = null;


		public function loadimg(url:String, success: Function) {
			// constructor code
			successFun = success;
			img = url;
			loadImg();
		}
		private function loadImg(): void {
			load = new Loader();
			load.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			load.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler); //监听加载失败
			load.load(new URLRequest(img));
		}
		private function completeHandler(event: Event): void {
			var sprite:Sprite=new Sprite();
			sprite.addChild(load);
			successFun(sprite);
		}
		private function errorHandler(event: IOErrorEvent): void {
			remove();
			successFun(null);
		}
		private function remove(): void {
			load.removeEventListener(Event.COMPLETE, completeHandler);
			load.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			load = null;
		}
	}

}