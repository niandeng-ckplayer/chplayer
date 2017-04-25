package chaction.act {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-04-07
	*/
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;
	import flash.display.Bitmap;
	import flash.net.URLLoader;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Sprite;

	public class newpreview {
		private var load: Loader = null;
		private var imgArr: Array = [];
		private var com: Function = null;
		private var imageI: int = 0; //加载图片时计数，一张一张图片加载
		private var bytemapArr: Array = [];
		private var imgW:int=0,imgH:int=0;

		public function newpreview(img: Array, k: Function) {
			// constructor code
			 com = k;
			imgArr = img;
			loadimage();
		}
		private function loadimage(): void {
			load = new Loader();
			load.contentLoaderInfo.addEventListener(Event.COMPLETE, comLoad);
			load.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorLoad); //监听加载失败
			load.load(new URLRequest(imgArr[imageI]));
		}
		private function comLoad(event: Event): void {
			var o: LoaderInfo = load.contentLoaderInfo;
			var bitmapdata: BitmapData
			var bytearr: ByteArray = new ByteArray();
			var bytemap: Bitmap = new Bitmap();
			imgW=o.width*0.1;
			imgH=o.height*0.1;
			bitmapdata = new BitmapData(o.width, o.height);
			bitmapdata.draw(load);
			var temp: ByteArray = bitmapdata.getPixels(bitmapdata.rect);
			bytearr.writeBytes(temp);

			var bitmapdata2: BitmapData = new BitmapData(o.width, o.height);
			bytearr.position = 0;
			bitmapdata2.setPixels(bitmapdata.rect, bytearr);
			//bytemap.bitmapData = bitmapdata2;
			bytemapArr.push(bitmapdata2);
			//com(bytemap);
			remove();
			if (imageI < imgArr.length - 1) {
				imageI++;
				loadimage();
			}
			else {
				rectAngle(); //全部加载完进行切图
			}

		}
		private function rectAngle(): void {
			var mov:Sprite = new Sprite();
			var nx: int = 0; //新的X坐标
		

			//
			for (var i: int = 0; i < bytemapArr.length; i++) {
				var bm: BitmapData = bytemapArr[i];
				var bx: int = 0,
					by: int = 0; //定义要切的x,y
				for (var y: int = 0; y < 100; y++) {
					var picRect: Rectangle = new Rectangle(bx, by, imgW, imgH); //从哪里开始扣，扣多少？  
					var point: Point = new Point(0, 0); //将抠图放在newBitmapdata的那个位置  
					var newBitmapdata: BitmapData = new BitmapData(imgW, imgH);
					newBitmapdata.copyPixels(bm, picRect, point);
					var newmap: Bitmap = new Bitmap();
					newmap.bitmapData = newBitmapdata;
					var newc: Sprite = new Sprite();
					newc.addChild(newmap);
					newc.x = nx;
					newc.name = i + ":" + y + "";
					mov.addChild(newc);
					nx += imgW;
					bx += imgW;
					if (bx >= bm.width) {
						bx = 0;
						by += imgH;
					
					}
				}

			}
			com(mov);
		}
		private function errorLoad(event: IOErrorEvent): void {
			remove();
		}
		private function remove(): void {
			load.removeEventListener(Event.COMPLETE, comLoad);
			load.removeEventListener(IOErrorEvent.IO_ERROR, errorLoad);
			load = null;
		}
	}

}