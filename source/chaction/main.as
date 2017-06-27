package chaction {
	/*
		软件名称：chplayer
		软件版本：V1.0
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		---------------------------------------------------------------------------------------------
		开发说明：
		使用的主要程序语言：javascript(js)及actionscript3.0(as3.0)(as3.0主要用于flashplayer部分的开发)
		功能：播放视频
		特点：兼容HTML5-VIDEO(优先)以及FlashPlayer
		=====================================================================================================================
	*/
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.system.Security;
	import flash.external.ExternalInterface;
	import chaction.act.configure;
	import chaction.style.style;
	import chaction.style.logo;
	import flash.media.Video;
	import chaction.act.script;
	import chaction.player.httpstream;
	import chaction.act.element;
	import chaction.style.language;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import chaction.act.loadimg;
	import flash.events.MouseEvent;
	import chaction.player.httpm3u8;
	import chaction.player.rtmpstream;
	import flash.events.ErrorEvent;
	import chaction.style.menu;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import chaction.act.newelement;


	public class main extends Sprite {
		//界面上所有用到的元件结束
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		private var stageW: int = stage.stageWidth,
			stageH: int = stage.stageHeight;
		private var chplayer: String = "";
		private var flashVars: Object = {}; //从外部接受到的变量对象
		private var M: style = null; //控制栏配置操作包
		private var Logo: logo = null; //logo
		private var promptText: Sprite = null;
		private var config: Object = {
			controlBarHeight: 38, //控制栏的高
			videoBottom: 0 //视频离底部的强制距离
		};
		private var video: Video = null;
		private var V: Object = {
			player: null, //播放器对象
			netStream: null,
			type: "[object NetStream]"
		}; //定义一个流对象
		private var videoMeta: Object = {
			width: stageW,
			height: stageH,
			paused: false
		};
		private var videoUrl: String = "";
		private var volume: Number = 0; //音量
		private var setTimerTime: Timer = null,
			setTimerBytes: Timer = null; //点播时计算音量，加载进度计算
		private var setTimerNewVideo: Timer = null; //清除视频延迟播放新视频
		private var seeking: Boolean = false; //是否在进行seek()
		private var poster: Sprite = null;
		private var posterMeta: Object = {
			width: 0,
			height: 0
		};
		private var playUrlTemp: Array = []; //当前要播放的数组
		private var playNumber: int = 0; //当前要播放的编号
		private var autoPlay: Boolean = true;
		private var loop: Boolean = true;
		private var m3u8Pause: Boolean = false; //单独用来控制m3u8结束暂停或播放的动作，如果=true则强制暂停
		private var end: Boolean = false; //播放结束修改该值为true，用来做为m3u8重新连接的需要
		private var needSeek: int = 0;
		private var listenerArr: Array = []; //要监听的事件列表
		private var ncClose: Boolean = false; //rtmp流是否关闭
		private var newElement: newelement = null; //专门用来做弹幕的类
		//private var controlBar:
		public function main() {
			// constructor code
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			flashVars = configure.getConfigure(stage.loaderInfo.parameters);
			ControlBar.visible = false;
			chplayer = flashVars["variable"];
			M = new style(stage,this, chplayer, ControlBar,ClickMove, flashVars, buttonClick, changeVolume, videoSeek, playOrPause, getVideoUrl, changeDef, listenerJs);
			
			Logo = new logo(stage, flashVars);
			addCallback(); //注册js控制播放器函数
			//向页面发送播放器加载成功的函数
			script.callJs(chplayer + ".loadedHandler");
			resize();
			stage.addEventListener(Event.RESIZE, resizeHandler); //监听舞台尺寸改变
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler); //监听键盘事件
			initialize();
		}
		private function initialize(): void {
			autoPlay = flashVars["autoplay"] == 0 ? false : true;
			videoMeta["paused"] = autoPlay ? false : true;
			loop = flashVars["loop"] == 0 ? false : true;
			needSeek = flashVars["seek"];
			volume = flashVars["volume"];
			M.showLoading();
			loadPoster();
			playNumber = 0;
			playUrlTemp = script.copyObject(flashVars["video"]);
			ncClose = false;
			loadVideo();
		}
		private function resizeHandler(event: Event) {
			resize();
			showPoster(false); //改变封面图
		}
		private function resize(): void {
			stageW = stage.stageWidth;
			stageH = stage.stageHeight;
			videoMeta["width"] = stageW;
			videoMeta["height"] = stageH;
			ControlBar.y = stageH - config["controlBarHeight"];
			if (promptText) {
				promptText.x = (stageW - promptText.width) * 0.5;
				promptText.y = (stageH - promptText.height) * 0.5;
			}
			if (video && V.hasOwnProperty("metaData")) {
				var coor = script.getCoor(stageW, stageH - config["videoBottom"], V["metaData"]["width"], V["metaData"]["height"]);
				video.width = coor["width"];
				video.height = coor["height"];
				video.x = coor["x"];
				video.y = coor["y"];
			}
			M.changeCoor();
			Logo.changeCoor();
			if (setTimerBytes == null) {
				M.changeBytesLoaded(-1);
			}
			if (newElement) {
				newElement.resize();
			}
		}
		private function loadPoster(): void {
			//加载封面图片
			if (poster) {
				this.removeChild(poster);
				poster = null;
			}
			if (flashVars["poster"] != "" && !autoPlay) {
				var load: loadimg = new loadimg(flashVars["poster"], completeLoadPoster);
			}
		}
		private function completeLoadPoster(sp: Sprite = null): void {
			if (sp != null) {
				poster = sp;
				posterMeta = {
					width: sp.width,
					height: sp.height
				};
				showPoster();
			}
		}
		private function changeDef(def: String): void {
			playUrlTemp = [];
			var v: Array = flashVars["video"];
			for (var i: int = 0; i < v.length; i++) {
				if (v[i][1] == def) {
					playUrlTemp.push(v[i]);
				}
			}
			if (playUrlTemp) {
				playNumber = 0;
				autoPlay = true;
				needSeek = videoMeta["time"];
				loadVideo();

			}
		}
		private function loadVideo(): void {

			//重置相关内容
			error(); //关闭提示
			//重置相关内容结束
			playUrlTemp = script.arrSort(playUrlTemp); //对要播放的视频地址进行排序
			videoUrl = playUrlTemp[playNumber][0];
			loadNetStream();
		}
		private function loadNetStream(): void {
			if (!videoUrl) {
				error(language.error);
				return;
			}
			if (V["player"] != null) {
				clear();
			}
			var protocol: String = videoUrl.substr(0, 4);
			trace(protocol);
			switch (protocol) {
				case "rtmp":
					var rtmpStream: rtmpstream = new rtmpstream();
					V["player"] = rtmpStream;
					break;
				default:
					if (playUrlTemp[playNumber][2] == ".m3u8") {
						var httpM3u8: httpm3u8 = new httpm3u8();
						httpM3u8.stage = stage;
						V["player"] = httpM3u8;
					} else { //如果不是m3u8格式则一律认为是普通的视频
						var httpStream: httpstream = new httpstream();
						V["player"] = httpStream;
						
					}
					V["player"].F = flashVars;
					break;
			}

			if (V["player"] != null) {
				V["player"].error = error;
				V["player"].videoUrl = videoUrl;
				V["player"].netStatus = netStatusHandler;
				V["player"].streamSendOut = connectStream;
				V["player"].load();
			}
		}
		private function netStatusHandler(state: String = ""): void {
			//trace(state);
			//script.log(state);
			switch (state) {
				case "NetConnection.Connect.Closed": //针对rtmp流暂停后被关闭的操作
					if (videoUrl.substr(0, 4) == "rtmp") {
						ncClose = true;
					}
					break;
				case "NetStream.Play.Start":
					M.showLoading(false);
					M.definition();
					listenerJs("loadedmetadata");
					break;
				case "NetStream.Play.StreamNotFound": //加载出错
					streamNotFound();
					break;
				case "NetStream.SeekStart.Notify":
				case "NetStream.Seek.seeking":
					seeking = true;
					listenerJs("seeking");
					M.showLoading();
					break;
				case "NetStream.Seek.Notify":
				case "NetStream.Seek.seeked":
				case "NetStream.Seek.Complete":
					seeking = false;
					listenerJs("seeked");
					script.callJs(chplayer + ".resetTrack");
					videoPlay();
					M.showLoading(false);
					break;
				case "NetStream.Buffer.Empty": //开始缓冲
					break;
				case "NetStream.Pause.Notify":
					listenerJs("pause");
					//listenerJs("loadedmetadata");
					if(newElement){
						newElement.changePauseded(true);
					}
					break;
				case "NetStream.Unpause.Notify":
					listenerJs("play");
					//listenerJs("loadedmetadata");
					if(newElement){
						newElement.changePauseded(false);
					}
					hidePoster();
					break;
				case "NetStream.Buffer.Full": //缓冲完成，进行播放
					seeking = false;
					M.showLoading(false);
					break;
				case "NetStream.Play.Stop": //播放完毕
					ended();
					break;
				default:
					break;
			}

		}
		private function streamNotFound(): void {
			if (playNumber < playUrlTemp.length - 1) {
				playNumber++;
				loadVideo();
			} else {
				error(language.error);
			}
		}
		private function connectStream(streamObject: Object): void {
			V = script.mergeObject(V, streamObject);
			var coor: Object = {};
			if (V.hasOwnProperty("metaData")) {
				coor = script.getCoor(stageW, stageH - config["videoBottom"], V["metaData"]["width"], V["metaData"]["height"]);
			}
			if (video != null) {
				this.removeChild(video);
			}
			video = new Video(coor["width"], coor["height"]);
			video.x = coor["x"];
			video.y = coor["y"];
			this.addChildAt(video,0);
			video.attachNetStream(V["netStream"]);
			video.smoothing=true;
			if (!streamObject.hasOwnProperty("metaData")) {
				return;
			}
			if (!end) {
				if (!autoPlay) {
					videoPause();
				} else {
					if (needSeek > 0) {
						videoSeek(needSeek);
						needSeek = 0;
					} else {
						videoPlay();
					}
				}
			} else {
				if (m3u8Pause) {
					videoPause();
				} else {
					videoPlay();
				}
			}
			//初始化音量
			changeVolume(flashVars["volume"], false);
			videoMeta["volume"] = flashVars["volume"];
			videoMeta["videoWidth"] = V["metaData"]["width"];
			videoMeta["videoHeight"] = V["metaData"]["height"];
			videoMeta["duration"] = V["metaData"]["duration"];
			if (V["metaData"].hasOwnProperty("bytesTotal")) {
				videoMeta["bytesTotal"] = V["metaData"]["bytesTotal"];
			}
			listenerJs("videochange");
			listenerJs("loadedmetadata");
			showPoster();
			//运行时间/加载量计时

			if (!flashVars["live"]) {
				M.changeDuration(videoMeta["duration"]);
				M.changeTime(0);
				closeSetTimerTime();
				closeSetTimeBytes();
				setTimerTime = new Timer(300);
				setTimerTime.addEventListener(TimerEvent.TIMER, setTimerTimeHandler);
				setTimerTime.start();
				if (videoMeta.hasOwnProperty("bytesTotal") && videoMeta["bytesTotal"] > 0) {
					M.bytesTotal = videoMeta["bytesTotal"];
					M.changeBytesLoaded();
					setTimerBytes = new Timer(300);
					setTimerBytes.addEventListener(TimerEvent.TIMER, setTimerBytesHandler);
					setTimerBytes.start();
				}
			}
			else{
				M.changeDuration(0);
			}
		}
		private function ended(): void { //播放结束执行的动作
			end = true;
			listenerJs("ended");
			M.showLoading(false);
			if (playUrlTemp[playNumber][2] != ".m3u8") {
				if (!loop) {
					videoPause();
				} else {
					videoSeek(0);
				}
			} else {
				if (!loop) {
					m3u8Pause = true;
				}
				newVideo();
			}

		}
		private function showPoster(add: Boolean = true): void {
			if (poster && video && poster.visible) {
				var coor = script.getCoor(stageW, stageH, posterMeta.width, posterMeta.height);
				poster.width = coor["width"];
				poster.height = coor["height"];
				poster.x = coor["x"];
				poster.y = coor["y"];
				if (add) {
					this.addChildAt(poster,2);
					this.addChildAt(ClickMove,2);
				}
			}
		}
		private function hidePoster(): void {
			if (poster != null && this.contains(poster)) {
				this.removeChild(poster);
				poster = null;
			}
		}
		private function setTimerTimeHandler(event: TimerEvent): void {
			if (!videoMeta["paused"] && !seeking) {
				var time = V["player"].getTime();
				videoMeta["time"] = time;
				M.changeTime(time);
				script.callJs(chplayer + ".sendTime", time);
				listenerJs("timeupdate");
			}
		}
		private function setTimerBytesHandler(event: TimerEvent): void {
			var bytesLoaded: Number = V["player"].getBytesLoaded();
			M.changeBytesLoaded(bytesLoaded);
			if (bytesLoaded >= M.bytesTotal && setTimerBytes != null) {
				closeSetTimeBytes();
			}
		}
		private function closeSetTimerTime(): void {
			if (setTimerTime) {
				if (setTimerTime.running) {
					setTimerTime.stop();
				}
				setTimerTime.removeEventListener(TimerEvent.TIMER, setTimerTimeHandler);
				setTimerTime = null;
			}
		}
		private function closeSetTimeBytes(): void {
			if (setTimerBytes) {
				if (setTimerBytes.running) {
					setTimerBytes.stop();
				}
				setTimerBytes.removeEventListener(TimerEvent.TIMER, setTimerBytesHandler);
				setTimerBytes = null;
			}
		}
		private function buttonClick(event: Event): void {
			switch (event.currentTarget) {
				case ControlBar.PlayButton:
				case ControlBar.CenterPauseButton:
					videoPlay();
					break;
				case ControlBar.PauseButton:
					videoPause();
					break;
				case ControlBar.MuteButton:
					videoMute(true);
					break;
				case ControlBar.EscMuteButton:
					videoMute(false);
					break;
				default:
					break;
			}
		}
		//注册外部控制函数
		private function addCallback(): void {
			if (!ExternalInterface.available) {
				return;
			}
			var arr: Array = [
				["playOrPause", playOrPause],
				["videoPlay", videoPlay],
				["videoPause", videoPause],
				["mute", videoMute],
				["cancelMute", cancelMute],
				["changeVolume", changeVolume],
				["getMetaDate", getMetaDate],
				["seek", videoSeek],
				["newVideo", newVideo],
				["changeLanguage", script.amendedLanguage],
				["addListener", addListener],
				["removeListener", removeListener],
				["newMenu", newMenu],
				["config", mConfig],
				["addElement", addElement],
				["getElement", getElement],
				["deleteElement", deleteElement],
				["animate", animate],
				["animateResume", animateResume],
				["animatePause", animatePause]
			];
			for (var i: int = 0; i < arr.length; i++) {
				ExternalInterface.addCallback(arr[i][0], arr[i][1]);
			}
		}
		//菜单右键点击
		private function menuClick(str: String): void {
			switch (str) {
				case "playOrPause":
					playOrPause();
					break;
				case "play":
					videoPlay();
					break;
				case "pause":
					videoPause();
					break;
				case "mute":
					videoMute(true);
					break;
				case "cancelMute":
					videoMute(false);
					break;
				default:
					break;
			}
		}
		//注册外部监听函数
		private function addListener(ele: String = "", fun: String = "") {
			listenerArr = script.addListenerArr(listenerArr, ele, fun);
			//script.log(listenerArr);
		}
		//删除外部监听函数
		private function removeListener(ele: String = "", fun: String = "") {
			listenerArr = script.removeListenerArr(listenerArr, ele, fun);
		}
		//统一的向数组里发送监听部分
		private function listenerJs(eve: String, val: *= null): void {
			//script.log(listenerArr);
			if (listenerArr.length == 0) {
				return;
			}
			try {
				for (var i: int = 0; i < listenerArr.length; i++) {
					var arr: Array = listenerArr[i];
					if (arr[0] == eve) {
						script.callJs(arr[1], val)
					}
				}
			} catch (event) {
				script.log(event);
			}
		}
		//可接受外部交互的部分
		public function playOrPause(): void { //播放和暂停之间切换
			if (videoMeta["paused"]) {
				videoPlay();
			} else {
				videoPause();
			}
		}
		public function videoPlay(): void { //播放
			if (V["netStream"] != null) {
				if (ncClose) { //说明是Nc被关闭了
					flashVars["autoplay"] = 1;
					var fvars: Object = {
						autoplay: 1
					}
					try {
						fvars["seek"] = V["player"].getTime() || V["netStream"].time;
					} catch (event: ErrorEvent) {}
					newVideo(fvars);
				} else {
					if (!end) {
						V["netStream"].resume();
					} else {
						videoSeek(0);
						end = false;
					}
					M.playButton(true);
					videoMeta["paused"] = false;
					hidePoster();
				}
			}
		}
		public function videoPause(): void { //暂停
			if (V["netStream"] != null) {
				videoMeta["paused"] = true;
				V["netStream"].pause();
				M.playButton(false);

			}
		}
		public function videoMute(b: Boolean = true): void { //静音
			if (V["netStream"] != null) {
				if (b) {
					changeVolume(0);
				} else {
					if (volume <= 0) {
						volume = flashVars["volume"];
					}
					changeVolume(volume);
				}

			}
		}
		public function cancelMute(): void {
			videoMute(false);
		}
		public function changeVolume(vol: Number = -1, changeStyle: Boolean = true): Number { //设置或获取音量
			volume = vol;
			if (V["netStream"] != null) {
				var v: SoundTransform = V["netStream"].soundTransform;
				v.volume = vol;
				V["netStream"].soundTransform = v;
				if (changeStyle) {
					M.changeVolume(vol, false);
				}
				script.callJs(chplayer + ".sendVolume", vol);
				videoMeta["volume"] = vol;
				listenerJs("volumechange");
				listenerJs("loadedmetadata");
			}
			return 0;
		}
		public function getMetaDate(): Object { //获取元数据
			return videoMeta;
		}
		public function videoSeek(time: Number = 0, isStyle: Boolean = true): void {
			if (V["netStream"] != null) {
				end = false;
				netStatusHandler("NetStream.Seek.seeking");
				V["player"].videoSeek(time);
				if (isStyle) {
					M.changeTime(time);
				}
			}
		}
		public function newVideo(obj: Object = null): void {
			if (obj) {
				flashVars = configure.getConfigure(obj);
				M.changeFlashVars(flashVars);
			}
			clear();
			if (setTimerNewVideo != null) {
				if (setTimerNewVideo.running) {
					setTimerNewVideo.stop();
				}
				setTimerNewVideo.removeEventListener(TimerEvent.TIMER, setTimerNewVideoHandler);
				setTimerNewVideo = null;
			}
			setTimerNewVideo = new Timer(200, 1);
			setTimerNewVideo.addEventListener(TimerEvent.TIMER, setTimerNewVideoHandler);
			setTimerNewVideo.start();
		}
		private function setTimerNewVideoHandler(event: TimerEvent): void {
			setTimerNewVideo.removeEventListener(TimerEvent.TIMER, setTimerNewVideoHandler);
			setTimerNewVideo = null;
			initialize();
		}
		public function clear(): void { //清空视频流及相关运行操作
			closeSetTimerTime();
			closeSetTimeBytes();
			if (V["player"]) {
				V["player"].clear();
				V["player"] = null;
			}
			if (V["netStream"] != null) {
				if (!ncClose) {
					V["netStream"].dispose();
				}
				V["netStream"] = null;
			}
			hidePoster(); //关闭封面图
			M.reset();
		}
		private function error(er: String = ""): void {
			if (promptText) {
				this.removeChild(promptText);
				promptText = null;
			}
			if (!er) {
				return;
			}
			var con: Object = {
				radius: 8, //圆角弧度
				bgAlpha: 1, //背景透明度
				text: er,
				height: 100,
				bgColor: 0x000000 //背景颜色
			};
			promptText = element.newPromptText(con);
			promptText.x = (stageW - promptText.width) * 0.5;
			promptText.y = (stageH - promptText.height) * 0.5;
			this.addChild(promptText);
			M.showLoading(false);
			listenerJs("error");
			clear();
		}
		private function addElement(obj: Object): String {
			if (!newElement) {
				newElement = new newelement(stage,this,ClickMove);
				
			}
			var sp:Sprite= newElement.addelement(obj);
			return sp.name;
		}
		private function getElement(name: String): Object {
			if (newElement) {
				return newElement.getElement(name);
			}
			return false;
		}
		private function deleteElement(name: String): void {
			if (newElement) {
				newElement.deleteElement(name);
			}
		}
		private function animate(obj: Object):String {
			if (newElement) {
				return newElement.animate(obj);
			}
			return "";
		}
		private function animateResume(id:String=""):void {
			if (newElement) {
				newElement.animateResume(id);
			}
		}
		private function animatePause(id:String=""):void {
			if (newElement) {
				newElement.animatePause(id);
			}
		}
		private function newMenu(arr: Array): void {
			new menu(this, menuClick, arr);
		}
		private function mConfig(obj:Object): void {
			M.config=obj;
		}
		private function keyDownHandler(event: KeyboardEvent): void {
			var now: Number = 0;
			switch (event.keyCode) {
				case 32:
					playOrPause();
					break;
				case 37:
					now = videoMeta["time"] - 10;
					videoSeek(now < 0 ? 0 : now);
					break;
				case 39:
					now = videoMeta["time"] + 10;
					videoSeek(now);
					break;
				case 38:
					now = volume + 0.1;
					changeVolume(now > 1 ? 1 : now);
					break;
				case 40:
					now = volume - 0.1;
					changeVolume(now < 0 ? 0 : now);
					break;
				default:
					break;
			}
		}
		public function getVideoUrl(): String {
			return videoUrl;
		}

	}

}