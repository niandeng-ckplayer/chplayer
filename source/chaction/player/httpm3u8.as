package chaction.player {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-03-17
	*/
	import org.mangui.hls.HLS;
	import org.mangui.hls.event.HLSEvent;
	import org.mangui.hls.utils.Params2Settings;
	import org.mangui.hls.constant.HLSPlayStates;
	import org.mangui.hls.model.Level;
	import flash.display.Stage;
	import flash.events.NetStatusEvent;
	import chaction.style.language;
	import org.mangui.hls.HLSSettings;

	public class httpm3u8 {
		public var videoUrl: String = "";

		public var netStatus: Function = null,
			streamSendOut: Function = null,
			error: Function = null; //发送流状态的函数，发送流的函数，统一用来报错的函数
		public var F:Object={};
		public var stage: Stage = null;
		private var hls: HLS = null;
		private var isClear: Boolean = false; //默认不清除
		private var vWidth: int = 0,
			vHeight: int = 0,
			duration: Number = 0,
			bytesTotal: int = 0,
			bytesLoaded: int = 0;
		private var time: Number = 0
		public function httpm3u8() {
			// constructor code
		}
		public function load(eve: Boolean = true): void {
			if(F["debug"]==1){
				org.mangui.hls.HLSSettings.logInfo=true;
				org.mangui.hls.HLSSettings.logDebug2=true;
				org.mangui.hls.HLSSettings.logWarn=true;
				org.mangui.hls.HLSSettings.logError=true;
			}
			if (isClear) { //如果已被清除，则不进行下面的动作
				return;
			}
			hls = new HLS();
			hls.stage = stage;
			hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE, completeHandler);
			hls.addEventListener(HLSEvent.ERROR, errorHandler);
			hls.addEventListener(HLSEvent.MANIFEST_LOADED, manifestHandler);
			hls.addEventListener(HLSEvent.MEDIA_TIME, mediaTimeHandler);
			hls.addEventListener(HLSEvent.PLAYBACK_STATE, stateHandler);
			hls.addEventListener(HLSEvent.FRAGMENT_LOADING, fragmentHandler);
			hls.addEventListener(HLSEvent.FRAGMENT_PLAYING, fragmentPlayingHandler);
			hls.addEventListener(HLSEvent.ID3_UPDATED, ID3Handler);
			hls.stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			hls.load(videoUrl);
		}
		private function completeHandler(event: HLSEvent) {
			trace("hls:completeHandler", event);
		}
		private function errorHandler(event: HLSEvent) {
			trace("hls:errorHandler", event);
			clear();
			error(language.error);
		}
		private function manifestHandler(event: HLSEvent) { //可以播放了
			bytesTotal = event.levels[hls.startlevel].fragments.length;
			if (isClear) {
				return;
			}
			hls.stream.play();
			duration = event.levels[hls.startlevel].duration;
			netStatus("NetConnection.Connect.Success");
		}
		private function mediaTimeHandler(event: HLSEvent) {
			//监听时间改变
			time = Math.max(0, event.mediatime.position);

		}
		private function stateHandler(event: HLSEvent) {
			trace("hls:stateHandler"+ event.state);
			switch (event.state) {
				case HLSPlayStates.PLAYING_BUFFERING:
					break;
				case HLSPlayStates.PAUSED_BUFFERING:
					break;
				case HLSPlayStates.PLAYING:

					break;
				case HLSPlayStates.PAUSED:
					break;
				case HLSPlayStates.IDLE: //播放结束
					netStatus("NetStream.Play.Stop");
					break;
				default:
					break;
			}
		}
		private function fragmentHandler(event: HLSEvent) {
			trace("hls:fragmentHandler",event.playMetrics)
		}
		private function ID3Handler(event: HLSEvent) {
			trace("hls:ID3Handler", event);
		}
		private function netStatusHandler(event: NetStatusEvent): void {
			trace(event.info.code);
			netStatus(event.info.code);
		}
		private function fragmentPlayingHandler(event: HLSEvent) {
			if (vWidth == 0 && vHeight == 0) {
				vWidth = event.playMetrics.video_width;
				vHeight = event.playMetrics.video_height;
				hls.stream.pause();
				var metaDataObj: Object = {
					netStream: hls.stream,
					type: "[object HLSNetStream]",
					metaData: {
						width: vWidth,
						height: vHeight,
						duration: duration,
						bytesTotal: bytesTotal

					}
				};
				//模拟发送监听状态
				netStatus("NetStream.Play.Start");
				streamSendOut(metaDataObj);
			}
			trace("hls:fragmentPlayingHandler");

		}
		public function getTime(): Number {
			return time;
		}
		public function getBytesLoaded(): Number {
			return 0;
		}
		public function videoSeek(time: Number = 0): void {
			if (hls.stream) {
				hls.stream.seek(time);
			}
		}
		public function clear(): void {
			isClear = true;
			if (hls) {
				hls.removeEventListener(HLSEvent.PLAYBACK_COMPLETE, completeHandler);
				hls.removeEventListener(HLSEvent.ERROR, errorHandler);
				hls.removeEventListener(HLSEvent.MANIFEST_LOADED, manifestHandler);
				hls.removeEventListener(HLSEvent.MEDIA_TIME, mediaTimeHandler);
				hls.removeEventListener(HLSEvent.PLAYBACK_STATE, stateHandler);
				hls.removeEventListener(HLSEvent.FRAGMENT_LOADING, fragmentHandler);
				hls.removeEventListener(HLSEvent.FRAGMENT_PLAYING, fragmentPlayingHandler);
				hls.removeEventListener(HLSEvent.ID3_UPDATED, ID3Handler);
				hls.stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				hls.stream.close();
				hls = null;
			}

		}
	}

}