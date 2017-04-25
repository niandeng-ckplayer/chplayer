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
	import chaction.act.script;

	public class httpstream {
		public var videoUrl: String = "";
		public var F: Object = {
			drag: ""
		};
		public var netStatus: Function = null,
			streamSendOut: Function = null,
			error: Function = null; //发送流状态的函数，发送流的函数，统一用来报错的函数
		private var nc: NetConnection = null;
		private var ns: NetStream = null;
		private var videoMeta: Object = null;
		private var playUrl: String = ""; //实际要播放的视频地址
		private var startTime: Number = 0,
			startBytes: Number = 0; //用来修正播放时间
		private var startTimeNum: int = 0; //用来做3次计数，用来确认是否需要修正时间
		private var isClear: Boolean = false; //默认不清除
		private var frist: Boolean = true;
		public function httpstream() {
			// constructor code

		}
		public function load(): void {
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			nc.connect(null);
		}
		private function netStatusHandler(event: NetStatusEvent): void {
			netStatus(event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				default:
					break;
			}
		}
		private function securityErrorHandler(event: SecurityErrorEvent): void {}
		private function netSteameErrorHandler(event: AsyncErrorEvent): void {}
		private function connectStream(): void {
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			if (!playUrl) {
				playUrl = videoUrl;
			}
			var customClient = new Object();
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netSteameErrorHandler);
			customClient.onMetaData = metaDataHandler;
			ns.client = customClient;
			ns.play(playUrl);
		}
		private function metaDataHandler(info: Object): void {
			var metaDataObj:Object={};
			if (frist) {
				info = script.getHttpKey(info);
				info["bytesTotal"] = ns.bytesTotal;
				videoMeta = info;
				if (!info.hasOwnProperty("keytime")) {
					F["drag"] = "";
				}
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
			var time: Number = ns.time;
			if (time < startTime || startTimeNum > 6) {
				startTimeNum++;
				time += startTime;
			}
			return time;
		}
		public function getBytesLoaded(): Number {
			var bytesLoaded: Number = ns.bytesLoaded;
			if (bytesLoaded < startBytes || startTimeNum > 6) {
				bytesLoaded += startBytes;
			}
			return bytesLoaded;
		}
		public function clear(): void {
			isClear = true; //设置清除
			if (nc) {
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				nc = null;
			}
			if (ns) {
				ns.dispose();
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netSteameErrorHandler);
				ns = null;
			}
		}

		public function videoSeek(time: Number = 0): void {
			if (ns) {
				if (F["drag"] == "") {
					ns.seek(getNewTime(time));
				} else {
					if (playUrl.indexOf(F["drag"] + "=") > -1) {
						newPlayUrl(time);
					} else {
						if (time <= getNewTime(time)) {
							ns.seek(time);
						} else {
							newPlayUrl(time);
						}
					}
				}
			}
		}
		private function newPlayUrl(time: Number = 0): void {
			var keytime: Array = videoMeta["keytime"];
			var keyframes: Array = videoMeta["keyframes"];
			var index: int = 0;
			var start: String = "";
			for (var i: int = 0; i < keytime.length; i++) {
				if (time < keytime[i]) {
					index = i > 0 ? i - 1 : i;
					break;
				}
			}
			if (time > keytime[keytime.length - 1]) {
				index = keytime.length - 1;
			}
			//script.log(time);
			//script.log(keytime);
			//mp4文件按关键时间点
			var drag:String=F["drag"].toString().replace("time_","").replace("frames_","");
			if (script.getFileExt(videoUrl) == ".mp4") {
				start = drag + "=" + keytime[index];
			} else {
				start = drag + "=" + keyframes[index];
			}
			if(F["drag"].indexOf("time_")>-1){
				start = drag + "=" + keytime[index];
			}
			if(F["drag"].indexOf("frames_")>-1){
				start = drag + "=" + keyframes[index];
			}
			startTime = keytime[index];
			startBytes = keyframes[index];
			if (videoUrl.indexOf("?") > -1) {
				playUrl = videoUrl + "&" + start;
			} else {
				playUrl = videoUrl + "?" + start;
			}
			startTimeNum = 0; //重置计数
			ns.close();
			ns.play(playUrl);
		}
		private function getNewTime(time: Number): Number { //根据当前加载量计算跳转时间
			var bytesLoaded: Number = ns.bytesLoaded;
			var bytesTotal: Number = ns.bytesTotal;
			var duration: Number = videoMeta["duration"];
			var limitTime: Number = bytesLoaded * duration / bytesTotal;
			if (time > limitTime) {
				return limitTime;
			}
			return time;
		}
	}

}