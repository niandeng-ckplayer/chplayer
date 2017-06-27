package chaction.style {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-04-07
	*/
	import flash.display.MovieClip;
	import flash.display.Stage;
	import chaction.act.script;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.StageDisplayState;
	import flash.display.Sprite;
	import chaction.act.element;
	import flash.text.TextField;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import chaction.act.newpreview;

	public class style extends MovieClip {

		private var S: Stage = null;
		private var M: MovieClip = null,
			CM: MovieClip = null;
		private var DE: SimpleButton = null; //清晰度的容器
		private var T: Sprite = null;
		private var DEBG: Sprite = null,
			DEBGBG: Sprite = null;
		private var DEArr: Array = [],
			DELine: Array = []; //用来保存当前所有的清晰度的按钮
		private var F: Object = {};
		private var stageW: int = 0,
			stageH: int = 0;
		private var chplayer: String = "";
		private var buttonClickFun: Function = null,
			changeVolumeFun: Function = null,
			playOrPauseFun: Function = null,
			getVideoUrlFun: Function = null,
			changeDefFun: Function = null,
			listenerJsFun: Function = null;
		public var nowFull: Boolean = false;
		private var deOver: Boolean = false;
		//MOver: Boolean = false;
		private var setTimeClick: Timer = null; //用来监听单击还是双击的
		private var setTimeDe: Timer = null,
			setTimerS: Timer = null; //用来判断是否离开清晰度,鼠标坐标监听
		private var oldMouseXY: Array = [0, 0]; //鼠标坐标
		private var isClick: Boolean = false; //正在单击
		private var point: Point = null; //进度按钮音量调节按钮坐标
		private var mDownName: String = ""; //鼠标在进度栏和音量调节栏按下时的名称，用来做判断
		private var seTimerLive: Timer = null; //如果是直播，则进行当前时间的读取
		private var seekTime: int = 0;
		private var nowDef: String = "";
		private var mTween: Tween = null; //控制栏隐藏缓动
		private var pTween: Tween = null; //预览图片缓动
		private var preview: Sprite = null,
			previewTop: Sprite = null; //预览图片
		private var previewLoad: Boolean = false;
		private var promptArr: Array = [];
		private var prompt: Array = [],
			promptTime: Array = [];
		private var promptText: TextField = null;
		public var isFollow: Boolean = true;
		public var isPause: Boolean = true,
			isLoading: Boolean = false;
		public var duration: Number = 0,
			bytesTotal: Number = 0; //总时间,总字节
		public var seekFun: Function = null;
		public var config: Object = {
			videoClick: true, //是否支持单击播放/暂停动作
			videoDbClick: true //是否支持双击全屏/退出全屏动作
		};
		/*
			
		*/

		public function style(s: Stage = null, t: Sprite = null, c: String = "chplayer", m: MovieClip = null, cm: MovieClip = null, f: Object = null, bc: Function = null, volume: Function = null, seek: Function = null, playOrPause: Function = null, getVideoUrl: Function = null, changeDef: Function = null, listenerJs: Function = null): void {
			// constructor code
			S = s;
			T = t;
			M = m;
			CM = cm;
			F = f;
			chplayer = c;
			buttonClickFun = bc;
			changeVolumeFun = volume;
			seekFun = seek;
			playOrPauseFun = playOrPause;
			getVideoUrlFun = getVideoUrl;
			changeDefFun = changeDef;
			listenerJsFun = listenerJs;
			//初始化
			isPause = F["autoplay"] == 1 ? false : true;
			M.EscFullButton.visible = false;
			M.dlineDef.visible = false;
			M.Loading.visible = false;
			M.Tips.visible = false;
			//如果是直播，则建立一个定时器
			reset();
			addEventListenerAll(); //注册按钮的单击事件
			//初始化结束
			M.visible = true;
		}
		public function reset(): void { //重置计时器
			if (seTimerLive) {
				seTimerLive.stop();
				seTimerLive.removeEventListener(TimerEvent.TIMER, seTimerLiveHandler);
				seTimerLive = null;
			}
			duration = 0;
			M.CenterPauseButton.visible = false;
			if (F["live"]) {
				M.TimeText.htmlText = script.getNowDate();
				seTimerLive = new Timer(1000);
				seTimerLive.addEventListener(TimerEvent.TIMER, seTimerLiveHandler);
				seTimerLive.start();
			} else {
				changeTime(0); //初始时间显示
			}
			showFrontNext();
			if (F["autoplay"] == 1) {
				M.PlayButton.visible = false;
				M.CenterPauseButton.visible = false;
			} else {
				M.PauseButton.visible = false;
			}
			changeVolume(F["volume"], false); //初始音量元件
			playButton(F["autoplay"]);
			definition();
			changeCoor();

		}
		public function changeCoor(): void { //修改各元素坐标
			stageW = S.stageWidth;
			stageH = S.stageHeight;
			try {
				var TimeTextX = 0;
				var DEBGW: int = 0;
				M.Bar.width = stageW;
				M.PlayButton.x = M.PauseButton.x = 0;
				TimeTextX = M.PlayButton.x + M.PlayButton.width;
				if (M.FrontButton.visible) {
					M.FrontButton.x = TimeTextX;
					TimeTextX += M.PlayButton.width;
				}
				if (M.NextButton.visible) {
					M.NextButton.x = TimeTextX;
					TimeTextX += M.NextButton.width;
				}
				M.TimeText.x = TimeTextX + 10;
				M.FullButton.x = M.EscFullButton.x = M.Bar.width - M.FullButton.width;
				if (DEArr.length > 1) {
					DEBGW = DEBG.width;
				}
				if (DE != null) {
					DE.y = M.FullButton.y + (M.FullButton.height - DE.height) * 0.5;
					DE.x = M.FullButton.x - DEBGW + (DEBGW - DE.width) * 0.5;
					M.dlineDef.x = M.FullButton.x - DEBGW - M.dlineDef.width;
				}
				if (DEArr.length > 1) {
					DEBG.x = DE.x - (DEBG.width - DE.width) * 0.5;
					DEBG.y = M.FullButton.y - DEBG.height;
				}

				M.VolumeAdjust.x = M.FullButton.x - (DE != null ? (DEBGW + M.dlineDef.width) : 0) - M.VolumeAdjust.width - 10;
				M.MuteButton.x = M.EscMuteButton.x = M.FullButton.x - (DE != null ? (DEBGW + M.dlineDef.width) : 0) - M.MuteButton.width - M.VolumeAdjust.width - 10;

				M.ProgressBackground.width = stageW;
				M.PlayProgress.x = 0;
				M.LoadProgress.x = 0;
				CM.width = stageW;
				CM.height = stageH;
				CM.x = 0;
				CM.y = 0;
				M.CenterPauseButton.x = (stageW - M.CenterPauseButton.width) * 0.5;
				M.CenterPauseButton.y = -(M.y - (stageH - M.CenterPauseButton.height) * 0.5);
				M.Loading.x = (stageW - M.Loading.width) * 0.5;

				M.Loading.y = -(M.y - (stageH - M.Loading.height) * 0.5);

				checkFullScreen();
				changePrompt();
			} catch (event: Error) {
				trace("event:", event);
			}
		}
		public function changeFlashVars(obj: Object): void {
			F = obj;
		}
		private function showFrontNext(): void {
			if (F["front"] != "") {
				M.FrontButton.visible = true;
			} else {
				M.FrontButton.visible = false;
			}
			if (F["next"] != "") {
				M.NextButton.visible = true;
			} else {
				M.NextButton.visible = false;
			}
		}
		private function addEventListenerAll(): void {
			var buttonArr: Array = [M.PlayButton, M.CenterPauseButton, M.PauseButton, M.FrontButton, M.NextButton, M.FullButton, M.EscFullButton, M.MuteButton, M.EscMuteButton, M.ProgressBackground, M.PlayProgress, M.LoadProgress, CM];
			for (var i: int = 0; i < buttonArr.length; i++) {
				buttonArr[i].addEventListener(MouseEvent.CLICK, buttonClickHandler);
				buttonArr[i].addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
				buttonArr[i].addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			}
			var progressArr: Array = [M.ProgressBackground, M.PlayProgress, M.LoadProgress, M.ProgressButton, M.VolumeAdjust.VolumeLower, M.VolumeAdjust.VolumeUpper, M.VolumeAdjust.VolumeButton];
			for (i = 0; i < progressArr.length; i++) {
				progressArr[i].addEventListener(MouseEvent.MOUSE_MOVE, progressMoveHandler);
				progressArr[i].addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				progressArr[i].addEventListener(MouseEvent.CLICK, progressClickHandler);

			}
			M.ProgressBackground.buttonMode = true;
			M.PlayProgress.buttonMode = true;
			M.LoadProgress.buttonMode = true;
			M.VolumeAdjust.buttonMode = true;
			M.ProgressButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			M.VolumeAdjust.VolumeButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			S.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
			M.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
			S.addEventListener(MouseEvent.MOUSE_OUT, SOutHandler);
			setTimerS = new Timer(2000);
			setTimerS.addEventListener(TimerEvent.TIMER, setTimerSHandler);
			setTimerS.start();

		}
		private function setTimerSHandler(event: TimerEvent): void {
			var mx: int = S.mouseX,
				my: int = S.mouseY;
			if (my < stageH - 50 || my >= stageH - 1) {
				if (M.alpha == 1) {
					if (oldMouseXY[1] == my) {
						mShow(false);
					}
				} else {
					if (oldMouseXY[1] != my) {
						mShow(true);
					}
				}
			} else {
				if (M.alpha == 0) {
					mShow(true);

				}
			}
			oldMouseXY = [mx, my];
		}
		private function SOutHandler(event: MouseEvent): void {
			if (setTimerS && setTimerS.running) {
				setTimerS.stop();
				mShow(false);
			}
		}
		private function mShow(b: Boolean): void {
			if (mTween) {
				mTween.stop();
				mTween = null;
			}
			if (b) {
				mTween = new Tween(M, "alpha", None.easeOut, M.alpha, 1, 0.5, true);
			} else {
				if (!isPause && !isLoading) {
					mTween = new Tween(M, "alpha", None.easeOut, M.alpha, 0, 0.2, true);
				}
			}
		}
		private function buttonOverHandler(event: MouseEvent): void {
			switch (event.currentTarget) {
				case M.PlayButton:
					showTips(M.PlayButton, language.play);
					break;
				case M.PauseButton:
					showTips(M.PauseButton, language.pause);
					break;
				case M.FullButton:
					showTips(M.FullButton, language.full);
					break;
				case M.EscFullButton:
					showTips(M.EscFullButton, language.escFull);
					break;
				case M.MuteButton:
					showTips(M.MuteButton, language.mute);
					break;
				case M.EscMuteButton:
					showTips(M.EscMuteButton, language.escMute);
					break;
				case DE:
					deOver = true;
					removeSetTimeDe();
					if (DEBG && !DEBG.visible) {
						showTips(DE, language.definition);
					}
					break;
				case DEBG:
					deOver = true;
					removeSetTimeDe();
					break;
				case M.FrontButton:
					showTips(M.FrontButton, language.front);
					break;
				case M.NextButton:
					showTips(M.NextButton, language.next);
					break;
				case S:
				case M:
					if (setTimerS && !setTimerS.running) {
						setTimerS.start();
						mShow(true);
					}
					break;
					/*
				case M:
					MOver = true;
					if (mTween) {
						mTween.stop();
						mTween = null;
					}
					mTween = new Tween(M, "alpha", None.easeOut, M.alpha, 1, 0.5, true);
					removeSetTimeM();
					break;
				*/
				default:
					break;
			}
		}
		private function buttonClickHandler(event: MouseEvent): void {
			buttonClickFun(event);
			switch (event.currentTarget) {
				case M.FullButton:
				case M.EscFullButton:
					fullScreen();
					break;
				case CM:
					clickMoveClickHanler();
					break;
				case DE:
					showTips(null, "");
					DEBG.visible = true;
					break;
				case M.FrontButton:
					script.callJs(F["front"]);
					break;
				case M.NextButton:
					script.callJs(F["next"]);
					break;
				default:
					break;
			}
		}
		private function clickMoveClickHanler(): void { //单击视频事件
			if (setTimeClick) {
				setTimeClick.removeEventListener(TimerEvent.TIMER, setTimeClickHandler);
				setTimeClick = null;
			}
			if (isClick) {
				//说明是双击
				isClick = false;
				if(config["videoDbClick"]){
					fullScreen();
				}

			} else {
				setTimeClick = new Timer(300, 1);
				setTimeClick.addEventListener(TimerEvent.TIMER, setTimeClickHandler);
				setTimeClick.start();
				isClick = true;
			}
		}
		private function setTimeClickHandler(event: TimerEvent): void {
			isClick = false;
			//说明仅仅是单击
			if(config["videoClick"]){
				playOrPauseFun();
			}

		}
		private function checkFullScreen(): void { //检查是否全屏
			if (S.displayState == "normal") {
				M.FullButton.visible = true;
				M.EscFullButton.visible = false;
				if (nowFull) {
					script.callJs(chplayer + ".sendFull", false);
					nowFull = false;
					listenerJsFun("full");
				}
			} else {
				M.FullButton.visible = false;
				M.EscFullButton.visible = true;
				if (!nowFull) {
					script.callJs(chplayer + ".sendFull", true);
					nowFull = true;
					listenerJsFun("full");
				}
			}
		}
		public function fullScreen(): void { //操作全屏/退出全屏
			switch (S.displayState) {
				case "normal":
					if (F["interactive"] == 1) {
						S.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					} else {
						S.displayState = "fullScreen";
					}
					break;
				default:
					S.displayState = "normal";
					break;
			}
			checkFullScreen()
		}
		private function mouseOutHandler(event: MouseEvent): void {
			showTips(null, "");
			if (previewTop != null) {
				previewTop.visible = false;
			}
			if (preview != null) {
				preview.visible = false;
			}
			if (promptText != null) {
				M.removeChild(promptText);
				promptText = null
			}
		}
		//鼠标经过提示点
		private function promptOverHandler(event: MouseEvent): void {
			var num = Number(event.currentTarget.name);
			var time: int = promptTime[num];
			var words: String = prompt[num];
			if (duration > 0 && !F["live"]) {
				var timeString: String = script.formatTime(time);
				showTips(null, timeString);
				if (F.hasOwnProperty("preview") && F["preview"] != "" && F.hasOwnProperty("previewscale") && F["previewscale"] > 0) {
					showPreview(time);
				}
			}
			var obj: Object = {
				text: words,
				width: previewTop != null ? previewTop.width - 5 : 120,
				leading: 5
			};
			if (promptText != null) {
				M.removeChild(promptText);
				promptText = null;
			}
			promptText = element.newTitle(obj);
			M.addChild(promptText);
			var x: int = M.mouseX - 60,
				y: int = M.ProgressButton.y - promptText.textHeight;
			if (previewTop != null) {
				x = previewTop.x;
				y -= previewTop.height;
			}
			if (x < 0) {
				x = 0;
			}
			if (x > M.width - promptText.textWidth) {
				x = M.width - promptText.textWidth;
			}
			promptText.x = x;
			promptText.y = y;

		}
		//提示点单击事件
		private function promptClickHandler(event: MouseEvent): void {
			var num = Number(event.currentTarget.name);
			var time: int = promptTime[num];
			isFollow = true;
			changeTime(time, true);
		}
		//鼠标经过进度栏和音量调节栏时的动作
		private function progressMoveHandler(event: MouseEvent): void {
			switch (event.currentTarget) {
				case M.ProgressBackground:
				case M.PlayProgress:
				case M.LoadProgress:
				case M.ProgressButton:
					if (duration == 0 || F["live"]) {
						break;
					}
					var time = M.mouseX * duration / M.ProgressBackground.width;
					var timeString: String = script.formatTime(time);
					showTips(null, timeString);
					if (F.hasOwnProperty("preview") && F["preview"] != "" && F.hasOwnProperty("previewscale") && F["previewscale"] > 0) {
						showPreview(time);
					}
					break;
				case M.VolumeAdjust.VolumeLower:
				case M.VolumeAdjust.VolumeUpper:
				case M.VolumeAdjust.VolumeButton:
					var vol: int = (Math.round(M.VolumeAdjust.VolumeLower.mouseX - M.VolumeAdjust.VolumeLower.x) * 100 / M.VolumeAdjust.VolumeLower.width);
					if (vol > 100) {
						vol = 100;
					}
					if (vol < 0) {
						vol = 0;
					}
					showTips(null, language.volume + (vol >= 0 ? vol : 0));
					break;
				default:
					break;
			}
		}
		//鼠标在进度栏和音量调节栏上单击事件
		private function progressClickHandler(event: MouseEvent): void {
			switch (event.currentTarget) {
				case M.ProgressBackground:
				case M.PlayProgress:
				case M.LoadProgress:
					if (duration == 0 || F["live"]) {
						break;
					}
					var time: int = Math.round(M.mouseX * duration / M.ProgressBackground.width);
					isFollow = true;
					changeTime(time, true);
					break;
				case M.VolumeAdjust.VolumeLower:
				case M.VolumeAdjust.VolumeUpper:
					var vol: int = (Math.round(M.VolumeAdjust.VolumeLower.mouseX - M.VolumeAdjust.VolumeLower.x) * 100 / M.VolumeAdjust.VolumeLower.width);
					changeVolume(vol * 0.01, true);
					break;
				default:
					break;
			}
		}
		//鼠标在进度栏和音量调节栏按钮按下去时的监听
		private function mouseDownHandler(event: MouseEvent): void {
			point = new Point(event.localX, event.localY);
			//trace(event.currentTarget);
			switch (event.currentTarget) {
				case M.ProgressButton:
					if (duration == 0 || F["live"]) {
						return;
					}
					mDownName = "progress";
					isFollow = false;
					M.ProgressButton.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					break;
				case M.VolumeAdjust.VolumeButton:
					mDownName = "volume";
					M.VolumeAdjust.VolumeButton.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					break;
				default:
					break;
			}
			S.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		private function enterFrameHandler(event: Event): void {
			if (point != null) {
				switch (mDownName) {
					case "progress":
						if (duration == 0 || F["live"]) {
							return;
						}
						M.ProgressButton.x = (M.mouseX - M.ProgressBackground.x) - point.x + (M.ProgressBackground.x - M.x);
						if (M.ProgressButton.x < M.ProgressBackground.x) {
							M.ProgressButton.x = M.ProgressBackground.x;
						}
						if (M.ProgressButton.x > M.ProgressBackground.x + M.ProgressBackground.width - M.ProgressButton.width) {
							M.ProgressButton.x = M.ProgressBackground.x + M.ProgressBackground.width - M.ProgressButton.width;
						}
						M.PlayProgress.x = M.ProgressBackground.x;
						M.PlayProgress.width = M.ProgressButton.x - M.ProgressBackground.x + M.ProgressButton.width * 0.5;
						seekTime = (M.ProgressButton.x - M.ProgressBackground.x) * duration / (M.ProgressBackground.width - M.ProgressButton.width);
						showTips(null, seekTime.toString() != "" ? script.formatTime(seekTime) : "");
						break;
					case "volume":
						//trace(point, M.VolumeAdjust.VolumeLower.mouseX, M.VolumeAdjust.VolumeLower.x);
						M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeLower.mouseX - point.x + M.VolumeAdjust.VolumeLower.x;
						if (M.VolumeAdjust.VolumeButton.x < M.VolumeAdjust.VolumeLower.x) {
							M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeLower.x;
						}
						if (M.VolumeAdjust.VolumeButton.x > M.VolumeAdjust.VolumeLower.x + M.VolumeAdjust.VolumeLower.width - M.VolumeAdjust.VolumeButton.width) {
							M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeLower.x + M.VolumeAdjust.VolumeLower.width - M.VolumeAdjust.VolumeButton.width;
						}
						var vol: int = (M.VolumeAdjust.VolumeButton.x - M.VolumeAdjust.VolumeLower.x) * 100 / (M.VolumeAdjust.VolumeLower.width - M.VolumeAdjust.VolumeButton.width);
						changeVolume(vol * 0.01, true, true, false);
						if (vol > 100) {
							vol = 100;
						}
						if (vol < 0) {
							vol = 0;
						}
						showTips(null, language.volume + (vol >= 0 ? vol : 0));
						break;
					default:
						break;
				}
			}
		}
		private function mouseUpHandler(event: MouseEvent): void {
			point = null;
			switch (mDownName) {
				case "progress":
					if (duration == 0 || F["live"]) {
						return;
					}
					M.ProgressButton.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
					changeTime(seekTime, true);
					isFollow = true;
					break;
				case "volume":
					M.VolumeAdjust.VolumeButton.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
					break;
				default:
					break;
			}
			showTips(null, "");
			S.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		private function showPrompt(): void {
			var i: int = 0;
			if (promptArr.length > 0) {
				for (i = 0; i < promptArr.length; i++) {
					M.removeChild(promptArr[i]);
				}
				promptArr = [];
			}
			if (F["prompt"] == "") {
				return;
			}
			prompt = F["prompt"].toString().split("|");
			promptTime = F["prompttime"].toString().split("|");
			for (i = 0; i < promptTime.length; i++) {
				var obj: Object = {
					bgColor: 0xFFFFFF,
					width: 6,
					height: 6
				};
				var ele: Sprite = element.newSprite(obj);
				ele.buttonMode = true;
				M.addChildAt(ele, M.getChildIndex(M.PlayProgress) + 1);
				ele.y = M.ProgressBackground.y;
				ele.name = i.toString();
				ele.addEventListener(MouseEvent.MOUSE_OVER, promptOverHandler);
				ele.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				ele.addEventListener(MouseEvent.CLICK, promptClickHandler);
				promptArr.push(ele);
			}
			changePrompt();
		}
		private function changePrompt(): void { //计算提示点的位置坐标
			if (promptArr.length == 0) {
				return;
			}
			var bw: int = M.ProgressBackground.width;
			for (var i = 0; i < promptArr.length; i++) {
				var time: int = Number(promptTime[i]);
				var left: int = time * bw / duration - promptArr[i].width * 0.5;
				if (left < 0) {
					left = 0;
				}
				if (left > bw - promptArr[i].width * 0.5) {
					left = bw - promptArr[i].width * 0.5
				}
				promptArr[i].x = left;
				promptArr[i].y = M.ProgressBackground.y;
			}


		}
		private function deletePreview(): void {
			if (preview != null) {
				T.removeChild(preview);
				T.removeChild(previewTop);
				preview = null;
				previewTop = null;
				previewLoad = false;
			}
		}
		private function showPreview(time: Number): void {
			if (F["preview"].toString() == "" || F["preview"].toString() == "null") {
				return;
			}
			if (preview == null) {
				if (!previewLoad) {
					previewLoad = true;
					new newpreview(F["preview"].toString().split("|"), function (sp: Sprite) {
						if (sp != null) {
							preview = sp;
							T.addChildAt(preview, 3);
							preview.visible = false;
						}
					});
				}
			} else {
				var x: int = M.mouseX;
				var nowNum: int = time / F["previewscale"];
				var numTotal: int = duration / F["previewscale"];
				var imgW: int = preview.width * 0.01 / F["preview"].toString().split("|").length;
				var imgH: int = preview.height;
				var left: int = (imgW * nowNum) - x + imgW * 0.5,
					top: int = M.y - imgH - M.ProgressBackground.height;
				var topLeft: int = x - imgW * 0.5;
				var timepieces: int = 0;
				var isTween: Boolean = true;
				if (previewTop == null) {
					var obj: Object = {
						width: imgW,
						height: imgH - 5,
						border: 5,
						borderColor: 0x0782F5
					}
					previewTop = element.newSprite(obj);
					T.addChildAt(previewTop, T.getChildIndex(preview) + 1);
					previewTop.visible = false;
				}
				if (topLeft < 0) {
					topLeft = 0;
					timepieces = x - topLeft - imgW * 0.5;
				}
				if (topLeft > S.stageWidth - imgW) {
					topLeft = S.stageWidth - imgW;
					timepieces = x - topLeft - imgW * 0.5;
				}
				if (left < 0) {
					left = 0;
				}
				if (left > numTotal * imgW - S.stageWidth) {
					left = numTotal * imgW - S.stageWidth;
				}
				if (preview.visible == false) {
					isTween = false;
				}
				previewTop.x = topLeft;
				previewTop.y = top + 2.5;
				previewTop.visible = true;
				preview.visible = true;
				preview.y = top;
				if (pTween != null) {
					pTween.stop();
					pTween = null;
				}
				if (isTween) {
					pTween = new Tween(preview, "x", None.easeOut, preview.x, -(left + timepieces), 0.3, true);
				} else {
					preview.x = -(left + timepieces);
				}
			}
		}
		public function changeVolume(volume: Number = 0, change: Boolean = true, upper: Boolean = true, adjust: Boolean = true, button: Boolean = true) { //根据音量调节元件
			if (upper) {
				M.VolumeAdjust.VolumeUpper.width = M.VolumeAdjust.VolumeLower.width * volume;
			}
			if (adjust) {
				M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeUpper.x + M.VolumeAdjust.VolumeUpper.width - M.VolumeAdjust.VolumeButton.width * 0.5;
				if (M.VolumeAdjust.VolumeButton.x < M.VolumeAdjust.VolumeLower.x) {
					M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeLower.x;
				}
				if (M.VolumeAdjust.VolumeButton.x > M.VolumeAdjust.VolumeLower.x + M.VolumeAdjust.VolumeLower.width - M.VolumeAdjust.VolumeButton.width) {
					M.VolumeAdjust.VolumeButton.x = M.VolumeAdjust.VolumeLower.x + M.VolumeAdjust.VolumeLower.width - M.VolumeAdjust.VolumeButton.width;
				}
			}
			if (button) {
				if (volume > 0) {
					M.MuteButton.visible = true;
					M.EscMuteButton.visible = false;
				} else {
					M.MuteButton.visible = false;
					M.EscMuteButton.visible = true;
				}
			}
			if (change) {
				changeVolumeFun(volume, false);
			}
		}
		public function playButton(b: Boolean): void { //切换播放/暂停按钮接口-外部使用
			if (b) {
				M.PauseButton.visible = true;
				M.PlayButton.visible = false;
				M.CenterPauseButton.visible = false;
				isPause = false;
			} else {
				M.PauseButton.visible = false;
				M.PlayButton.visible = true;
				M.CenterPauseButton.visible = true;
				if (M.Loading.visible) {
					M.Loading.visible = false;
				}
				isPause = true;
				mShow(true);
			}
		}
		public function changeDuration(time: Number): void {
			duration = time;
			deletePreview();
			showPrompt();
			if (F.hasOwnProperty("preview") && F["preview"] != "" && F.hasOwnProperty("previewscale") && F["previewscale"] > 0) {
				showPreview(time);
			}
		}
		public function changeTime(time: Number = 0, notice: Boolean = false): void { //改变时间显示,仅针对点播
			var text: String = "";
			if (!duration) {
				time = 0;
			}
			if (F["timerep"] == 0) {
				text = script.formatTime(time, true) + " / " + script.formatTime(duration, true);
			} else if (F["timerep"] == 1) {
				text = script.formatTime(time) + " / " + script.formatTime(duration);
			} else {
				text = F["timerep"];
			}
			if (text) {
				M.TimeText.htmlText = text;
			}
			if (isFollow) {
				M.PlayProgress.width = M.ProgressBackground.width * time / duration;
				M.ProgressButton.x = M.PlayProgress.x + M.PlayProgress.width - M.ProgressButton.width * 0.5;
				if (M.ProgressButton.x < M.ProgressBackground.x) {
					M.ProgressButton.x = M.ProgressBackground.x;
				}
				if (M.ProgressButton.x > M.ProgressBackground.x + M.ProgressBackground.width - M.ProgressButton.width) {
					M.ProgressButton.x = M.ProgressBackground.x + M.ProgressBackground.width - M.ProgressButton.width;
				}
			}
			if (notice) {
				seekFun(time, false);
			}
		}
		public function changeBytesLoaded(bytesLoaded: Number = 0): void {
			if (bytesLoaded >= 0) {
				M.LoadProgress.width = M.ProgressBackground.width * bytesLoaded / bytesTotal;
			} else {
				M.LoadProgress.width = M.ProgressBackground.width;
			}
		}
		//构建清晰度按钮
		public function definition(): void {
			var i: int = 0;
			if (DE != null) {
				DE.removeEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
				DE.removeEventListener(MouseEvent.MOUSE_OUT, DEBGOutHandler);
				DE.removeEventListener(MouseEvent.CLICK, buttonClickHandler);
				M.removeChild(DE);
				DE = null;
				M.dlineDef.visible = false;
			}
			if (DEBGBG != null) {
				DEBG.removeChild(DEBGBG);
				DEBGBG = null;
			}
			if (DEArr.length > 1) {
				for (i = 0; i < DEArr.length; i++) {
					DEArr[i].removeEventListener(MouseEvent.CLICK, defClickHandler);
					DEBG.removeChild(DEArr[i]);
					DEBG.removeChild(DELine[i]);
				}
				DEBG.removeEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
				DEBG.removeEventListener(MouseEvent.MOUSE_OUT, DEBGOutHandler);
				M.removeChild(DEBG);
				DEBG = null;
			}

			DEArr = [];
			DELine = [];
			if (!F.hasOwnProperty("video") || !F["video"]) {
				changeCoor();
				return;
			}
			nowDef = "";
			var defArr: Array = [];
			var video: Array = F["video"];
			var nowUrl: String = getVideoUrlFun();
			for (i = 0; i < video.length; i++) {
				var v: Array = video[i];
				if (v[0] == nowUrl) {
					nowDef = v[1];
				}
				if (defArr.indexOf(v[1]) == -1) {
					defArr.push(v[1]);
				}
			}
			if (!nowDef && defArr.length > 1) {
				nowDef = defArr[0];
			}
			if (defArr.length > 1 && defArr[0] != "") {
				//建立一个普通的清晰度按钮
				var nowObj: Object = {
					text: nowDef,
					alpha: 0,
					alpha2: 0,
					radius: 0,
					over: false
				}
				DE = element.newButton(nowObj);
				DEBG = element.newSprite();
				M.addChild(DE);
				M.setChildIndex(DE, M.getChildIndex(M.EscFullButton))
				M.dlineDef.visible = true;
				var zlen: int = 0;
				for (i = 0; i < defArr.length; i++) {
					var nowObj2: Object = {
						text: defArr[i],
						size: 14,
						face: "Microsoft YaHei,微软雅黑",
						alpha: 0,
						alpha2: 0,
						radius: 0,
						top: 2,
						bottom: 5,
						over: false
					}
					if (defArr[i] == nowDef) {
						nowObj2["downColor"] = 0x0782F5;
					}
					var de2: SimpleButton = element.newButton(nowObj2);
					de2.name = defArr[i];
					DEArr.push(de2);
					de2.addEventListener(MouseEvent.CLICK, defClickHandler);
					var dlen: int = de2.width;
					if (dlen > zlen) {
						zlen = dlen;
					}
				}
				for (i = 0; i < defArr.length; i++) {
					//画直线
					var lineObj: Object = {
						color: 0x282828, //背景颜色
						alpha: 1, //透明度
						width: zlen,
						height: 1
					};
					var line: Sprite = element.newLine(lineObj);
					DEBG.addChild(DEArr[i]);
					DEBG.addChild(line);
					DELine.push(line);
					DEArr[i].x = (zlen - DEArr[i].width) * 0.5;
					DEArr[i].y = (defArr.length - 1 - i) * (DEArr[i].height + 1);
					line.y = DEArr[i].y + DEArr[i].height;

				}
				if (DEBG) {
					DEBG.visible = false;
					DEBGBG = element.newSprite({
						width: DEBG.width,
						height: DEBG.height,
						bgColor: 0x000000
					});
					DEBG.addChildAt(DEBGBG, 0);
					M.addChild(DEBG);
					DE.addEventListener(MouseEvent.CLICK, buttonClickHandler);
					DE.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
					DE.addEventListener(MouseEvent.MOUSE_OUT, DEBGOutHandler);
					DEBG.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
					DEBG.addEventListener(MouseEvent.MOUSE_OUT, DEBGOutHandler);
				}
			}
			changeCoor();
		}
		private function defClickHandler(event: MouseEvent): void {
			if (nowDef != event.currentTarget.name) {
				changeDefFun(event.currentTarget.name);
			}
			DEBG.visible = false;
		}
		private function DEBGOutHandler(event: MouseEvent): void {
			deOver = false;
			removeSetTimeDe()
			setTimeDe = new Timer(500, 1);
			setTimeDe.addEventListener(TimerEvent.TIMER, setTimeDeHandler);
			setTimeDe.start();
			showTips(null, "");
		}
		private function setTimeDeHandler(event: TimerEvent): void {
			if (!deOver) {
				DEBG.visible = false;
			}

		}
		private function removeSetTimeDe(): void {
			if (setTimeDe != null) {
				if (setTimeDe.running) {
					setTimeDe.stop();
				}
				setTimeDe.removeEventListener(TimerEvent.TIMER, setTimeDeHandler);
				setTimeDe = null;
			}
		}

		private function seTimerLiveHandler(event: TimerEvent): void {
			M.TimeText.htmlText = script.getNowDate();
		}
		//显示loading
		public function showLoading(b: Boolean = true): void {
			M.Loading.visible = b;
			isLoading = b;
			if (b) {
				M.CenterPauseButton.visible = false;
				mShow(true);
			}
		}
		//显示提示语
		private function showTips(button: Object = null, title: String = "", correctX: Number = 0, correctY: Number = 0): void {
			var nowX: Number = 0,
				nowY: Number = 0,
				nowW: Number = 0;
			var xMin: int = 0,
				xMax: int = M.Bar.x + M.Bar.width - M.Tips.width;
			var titleLen: int = script.getStringLen(title);
			if (button != null) {
				nowX = button.x;
				nowY = button.y;
				nowW = button.width;
			} else {
				nowX = S.mouseX - M.Bar.x;
				nowY = M.Bar.mouseY;
			}
			nowX += correctX;
			nowY += correctY;
			if (title == "") {
				M.Tips.visible = false;
				return;
			}
			M.Tips.Title.width = titleLen * 8;
			M.Tips.Title.text = title;
			M.Tips.Title.x = M.Tips.left.width;
			M.Tips.bg.width = titleLen * 8;
			M.Tips.right.x = M.Tips.bg.x + M.Tips.bg.width;
			M.Tips.x = nowX + (nowW - M.Tips.width) * 0.5;
			if (M.Tips.x < xMin) {
				M.Tips.x = xMin + 2;
			}
			if (M.Tips.x > xMax) {
				M.Tips.x = xMax - 2;
			}
			M.Tips.y = nowY - M.Tips.height - 10;
			M.Tips.visible = true;

		}
	}

}