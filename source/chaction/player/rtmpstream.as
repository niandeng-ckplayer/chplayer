package chaction.player {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-03-17
	*/
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import chaction.style.language;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.AsyncErrorEvent;
	public class rtmpstream {
		public var videoUrl: String = "";

		public var netStatus: Function = null,
			streamSendOut: Function = null,
			error: Function = null; //发送流状态的函数，发送流的函数，统一用来报错的函数

		private var nc: NetConnection = null;
		private var ns: NetStream = null;
		private var rtmp: String = "",
			live: String = "";
		private var isClear: Boolean = false; //默认不清除
		private var frist:Boolean=true;//确保只发送一次流
		private var ncClose:Boolean=false;
		public function rtmpstream() {
			// constructor code
		}

		public function load(): void {
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			//分析地址
			var arr: Array = videoUrl.split("mp4:");
			if (arr.length == 2) {
				rtmp = arr[0];
				live = arr[1];
			} else {
				arr = videoUrl.split("|");
				if (arr.length == 2) {
					rtmp = arr[0];
					live = arr[1];
				} else {
					var x = videoUrl.lastIndexOf("/");
					arr = [];
					if (x > 0) {
						arr.push(videoUrl.substr(0, x), videoUrl.substr(x + 1));
					}
					if (arr.length == 2) {
						rtmp = arr[0];
						live = arr[1];
					}
				}
			}
			trace(arr);
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
			nc.connect(rtmp);
		}
		private function netStatusHandler(event: NetStatusEvent): void {
			netStatus(event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetConnection.Connect.Closed": //针对rtmp流暂停后被关闭的操作
					ncClose = true;
					break;
				default:
					break;
			}
		}
		private function securityErrorHandler(event: SecurityErrorEvent): void {}
		private function netSteameErrorHandler(event: AsyncErrorEvent): void {}
		private function asyncErrorHandler(event: AsyncErrorEvent): void {}
		private function connectStream(): void {
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			var customClient = new Object();
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netSteameErrorHandler);
			customClient.onMetaData = metaDataHandler;
			ns.client = customClient;
			ns.play(live);
			//ns.
		}
		private function metaDataHandler(info: Object): void {
			info["bytesTotal"] = 0;
			var metaDataObj:Object={};
			if (frist) {
				info["bytesTotal"] = ns.bytesTotal;
				metaDataObj = {
					type: "[object NetStream]",
					metaData:info
				};
				
			}
			metaDataObj["netStream"]=ns;
			frist = false;
			if (!info.hasOwnProperty("width")) {
				clear();
				error(language.noMetadataWidth);
				return;
			}
			if (!info.hasOwnProperty("height")) {
				clear();
				error(language.noMetadataHeight);
				return;
			}
			if (!info.hasOwnProperty("duration")) {
				clear();
				error(language.noMetadataDuration);
				return;
			}
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			streamSendOut(metaDataObj);
		}
		//提供交互
		public function getTime(): Number {
			return ns.time;
		}
		public function getBytesLoaded():Number{
			return 0;
		}
		public function clear(): void {
			isClear = true; //设置清除
			if (ns) {
				if(!ncClose){
					ns.dispose();
				}
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netSteameErrorHandler);
				ns = null;
			}
			if (nc) {
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
				nc = null;
			}
			
		}

		public function videoSeek(time: Number = 0): void {
			if (ns) {
				ns.seek(time);
			}
		}
	}

}