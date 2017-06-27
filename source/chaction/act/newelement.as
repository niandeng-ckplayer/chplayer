package chaction.act {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.Stage;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import fl.motion.easing.Quadratic;
	import fl.motion.easing.Cubic;
	import fl.motion.easing.Quartic;
	import fl.motion.easing.Quintic;
	import fl.motion.easing.Sine;
	import fl.motion.easing.Exponential;
	import fl.motion.easing.Circular;
	import fl.motion.easing.Elastic;
	import fl.motion.easing.Back;
	import fl.motion.easing.Bounce;
	import fl.transitions.TweenEvent;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	public class newelement {
		private var pauseded: Boolean = false;
		private var S: Stage = null;
		private var T: Sprite = null;
		private var C:MovieClip=null
		private var eleArr: Array = [],
			eleNameArr: Array = []; //保存所有在改变舞台尺寸时需要调整位置的元件的数组
		private var animateArray: Array = [],
			animateElementArray: Array = [],
			animatePauseArray: Array = []; //缓动tween数组，缓动的元件ID数组，暂停时需要停止的元件ID数组
		public function newelement(stage: Stage, sp: Sprite,cm:MovieClip) {
			S = stage;
			T = sp;
			C=cm;
		}
		public function addelement(newObj): Sprite {
			var obj = {
				list: [],
				x: "100%",
				y: "50%",
				position: [],
				alpha: 1,
				backgroundColor: null,
				backAlpha: 1,
				backRadius: 0
			}
			obj = script.mergeObject(obj, newObj);
			var list: Array = obj["list"];
			if (list.length == 0) {
				return null;
			}
			var bObj: Object = {};
			var elementArr: Array = [];
			var i: int = 0;
			var ele: Object = {};
			var cx: int = 0,
				maxH: int = 0;
			for (i = 0; i < list.length; i++) {
				ele = list[i];
				var mH: int = 0;
				var eleSprite: Sprite = null;
				switch (ele["type"]) {
					case "image":
						bObj = {
							type: "image",
							url: "",
							radius: 0, //圆角弧度
							width: 30, //定义宽，必需要定义
							height: 30, //定义高，必需要定义
							alpha: 1, //透明度
							marginLeft: 0,
							marginRight: 0,
							marginTop: 0,
							marginBottom: 0
						};
						list[i] = ele = script.mergeObject(bObj, ele);
						eleSprite = loadspriteimg.loadimg(bObj["url"], bObj["width"], bObj["height"], bObj["radius"]);
						cx += ele["marginLeft"];
						eleSprite.x = cx;
						cx += (eleSprite.width || ele["width"]) + ele["marginRight"];
						mH = ele["marginTop"];
						eleSprite.y = mH;
						mH += (eleSprite.height || ele["height"]) + ele["marginBottom"];
						if (maxH < mH) {
							maxH = mH;
						}
						elementArr.push(eleSprite);
						eleNameArr.push();
						break;
					case "text":
						bObj = {
							type: "text", //说明是文本
							text: "", //文本内容
							fontColor: "#FFFFFF",
							fontSize: 14,
							fontFamily: "Microsoft YaHei,\5FAE\8F6F\96C5\9ED1,微软雅黑",
							lineHeight: 0,
							alpha: 1, //透明度
							paddingLeft: 0, //左边距离
							paddingRight: 0, //右边距离
							paddingTop: 0,
							paddingBottom: 0,
							marginLeft: 0,
							marginRight: 0,
							marginTop: 0,
							marginBottom: 0,
							backgroundColor: null,
							backAlpha: 1,
							backRadius: 0
						};
						list[i] = ele = script.mergeObject(bObj, ele);
						var textObj: Object = {
							text: bObj["text"],
							color: bObj["fontColor"].split("#").join("0x"),
							size: bObj["fontSize"],
							face: bObj["fontFamily"],
							width: 0,
							height: 0,
							alpha: bObj["alpha"]
						};
						var text: TextField = element.newTitle(textObj);
						var textBgWidth: int = text.width + bObj["paddingLeft"] + bObj["paddingRight"];
						var textBgHeight: int = bObj["lineHeight"] > 0 ? bObj["lineHeight"] : 0;
						text.y = textBgHeight > 0 ? (textBgHeight - text.height) * 0.5 + bObj["paddingTop"] : bObj["paddingTop"];
						textBgHeight += (bObj["paddingTop"] + bObj["paddingBottom"]);
						text.x = bObj["paddingLeft"];
						var textBgObj: Object = {
							bgColor: bObj["backgroundColor"], //背景颜色
							radius: bObj["backRadius"], //圆角弧度
							bgAlpha: bObj["backAlpha"], //背景透明度
							width: textBgWidth,
							height: textBgHeight
						};
						eleSprite = element.newSprite(textBgObj);
						eleSprite.addChild(text);
						cx += ele["marginLeft"];
						eleSprite.x = cx;
						cx += eleSprite.width + ele["marginRight"];
						mH = ele["marginTop"];
						eleSprite.y = mH;
						mH += eleSprite.height + ele["marginBottom"];
						if (maxH < mH) {
							maxH = mH;
						}
						elementArr.push(eleSprite);
						break;
					default:
						break;
				}



			}
			var spBgObj: Object = {
				bgColor: obj["backgroundColor"]!=null?obj["backgroundColor"].split("#").join("0x"):null, //背景颜色
				radius: obj["backRadius"], //圆角弧度
				bgAlpha: obj["backAlpha"], //背景透明度
				width: cx,
				height: maxH
			};
			var sprite: Sprite = element.newSprite(spBgObj);
			for (i = 0; i < elementArr.length; i++) {
				sprite.addChild(elementArr[i]);
			}
			sprite.name = obj["x"] + "$" + obj["y"] + "$" + obj["position"].join(",") + "$" + script.randomString();
			var eleCoor: Object = calculationCoor(sprite);
			sprite.x = eleCoor["x"];
			sprite.y = eleCoor["y"];
			sprite.alpha = obj["alpha"];
			T.addChildAt(sprite, T.getChildIndex(C)+1);
			eleArr.push(sprite);
			eleNameArr.push(sprite.name);
			return sprite;
		}
		private function calculationCoor(ele: Sprite): Object {
			var arr = ele.name.split("$");
			var obj = {
				x: arr[0],
				y: arr[1],
				position: arr[2] != "" ? arr[2].split(",") : []
			}
			var x: int = Number(obj["x"].toString().split("%").join("")),
				y: int = Number(obj["y"].toString().split("%").join("")),
				position: Array = obj["position"];
			var w: int = S.stageWidth,
				h: int = S.stageHeight;
			var ew: int = ele.width,
				eh: int = ele.height;
			if (position.length > 0) {
				position.push(null, null, null, null);
				var i = 0;
				for (i = 0; i < position.length; i++) {
					if (position[i] == "null" || position[i] == "") {
						position[i] = null;
					}
					if (position[i] != null) {
						position[i] = Number(position[i]);
					}


				}
				if (position[2] == null) {
					switch (position[0]) {
						case 0:
							x = 0;
							break;
						case 1:
							x = (w - ew) * 0.5;
							break;
						default:
							x = w - ew;
							break;
					}
				} else {
					switch (position[0]) {
						case 0:
							x = position[2];
							break;
						case 1:
							x = w * 0.5 + position[2];
							break;
						default:
							x = w + position[2];
							break;
					}
				}
				if (position[3] == null) {
					switch (position[1]) {
						case 0:
							y = 0;
							break;
						case 1:
							y = (h - eh) * 0.5;
							break;
						default:
							y = h - eh;
							break;
					}
				} else {
					switch (position[1]) {
						case 0:
							y = position[3];
							break;
						case 1:
							y = h * 0.5 + position[3];
							break;
						default:
							y = h + position[3];
							break;
					}
				}
			} else {
				if (obj["x"].toString().search("%") > -1) {
					x = Math.floor(Number(obj["x"].toString().split("%").join("")) * w * 0.01);
				}
				if (obj["y"].toString().search("%") > -1) {
					y = Math.floor(Number(obj["y"].toString().split("%").join("")) * h * 0.01);
				}
			}

			return {
				x: x,
				y: y
			}
		}
		public function getElement(name: String): Object {
			var num: int = eleNameArr.indexOf(name);
			if (num > -1) {
				var sprite: Sprite = eleArr[num];
				return {
					x: sprite.x,
					y: sprite.y,
					width: sprite.width,
					height: sprite.height,
					alpha: sprite.alpha
				}
			}
			return null;
		}
		public function animate(ob: Object): String {
			var obj: Object = {
				element: null,
				parameter: "x",
				static: false,
				effect: "None.easeIn",
				start: null,
				end: null,
				speed: 0,
				overStop: false,
				pauseStop: false,
				callBack: null
			};
			obj = script.mergeObject(obj, ob);
			
			if (obj["element"] == null || obj["speed"] == 0) {
				return "";
			}
			var w: int = S.stageWidth,
				h: int = S.stageHeight;
			var eleCoor = {
				x: 0,
				y: 0
			};

			var run: Boolean = true;
			var pm = getElement(obj["element"]); //包含x,y,width,height,alpha属性
			//将该元件从元件数组里删除，让其不再跟随播放器的尺寸改变而改变位置
			var num = eleNameArr.indexOf(obj["element"]);
			var sprite: Sprite = null;
			if (num > -1) {
				sprite = eleArr[num];
				eleNameArr.splice(num, 1);
				eleArr.splice(num, 1);
			}
			if (sprite == null) {
				return "";
			}
			var b: Number = 0; //初始值
			var c: Number = 0; //变化后的值
			var d = obj["speed"]; //持续时间
			//var setTimeOut = null;
			//var tweenObj = null;
			var start: String = obj["start"] == null ? "" : obj["start"].toString();
			var end: String = obj["end"] == null ? "" : obj["end"].toString();
			switch (obj["parameter"]) {
				case "x":
					if (obj["start"] == null) {
						b = pm["x"];
					} else {
						if (start.substr(start.length - 1, start.length) == "%") {
							b = Number(start.substr(0, start.length - 1)) * w * 0.01;
						} else {
							b = Number(start);
						}

					}
					if (obj["end"] == null) {
						c = pm["x"];
					} else {
						if (end.substr(end.length - 1, end.length) == "%") {
							c = Number(end.substr(0, end.length - 1)) * w * 0.01;
						} else if (end.substr(0, 1) == "-" || end.substring(0, 1) == "+") {
							if (typeof (obj["end"]) == "number") {
								c = obj["end"];
							} else {
								c = b + Number(end);
							}
						} else {
							c = Number(end);
						}
					}
					b = Math.floor(b);
					c = Math.floor(c);
					break;
				case "y":
					if (obj["start"] == null) {
						b = pm["y"];
					} else {
						if (start.substr(start.length - 1, start.length) == "%") {
							b = Number(start.substr(0, start.length - 1)) * h * 0.01;
						} else {
							b = Number(start);
						}

					}
					if (obj["end"] == null) {
						c = pm["y"];
					} else {
						if (end.substr(end.length - 1, end.length) == "%") {
							c = Number(end.substr(0, end.length - 1)) * h * 0.01;
						} else if (end.substr(0, 1) == "-" || end.substring(0, 1) == "+") {
							if (typeof (obj["end"]) == "number") {
								c = obj["end"];
							} else {
								c = b + Number(end);
							}
						} else {
							c = Number(end);
						}
					}
					b = Math.floor(b);
					c = Math.floor(c);

					break;
				case "alpha":
					if (obj["start"] == null) {
						b = pm["alpha"];
					} else {
						if (start.substr(start.length - 1, start.length) == "%") {
							b = Number(start.substr(0, start.length - 1));
						} else {
							b = Number(obj["start"]);
						}

					}
					if (obj["end"] == null) {
						c = pm["alpha"];
					} else {
						if (end.substr(end.length - 1, end.length) == "%") {
							c = Number(end.substr(0, end.length - 1));
						} else if (end.substr(0, 1) == "-" || end.substring(0, 1) == "+") {
							if (typeof (obj["end"]) == "number") {
								c = obj["end"];
							} else {
								c = b + Number(end);
							}
						} else {
							c = Number(end);
						}
					}
					break;

			}
			var effArr: Array = [None, Quadratic, Cubic, Quartic, Quintic, Sine, Exponential, Circular, Elastic, Back, Bounce];
			var effNameArr: Array = ["None", "Quadratic", "Cubic", "Quartic", "Quintic", "Sine", "Exponential", "Circular", "Elastic", "Back", "Bounce"];
			var arr: Array = obj["effect"].split(".");
			num = effNameArr.indexOf(arr[0]);
			var effectFun = effArr[num][arr[1]];
			var tween: Tween = new Tween(sprite, obj["parameter"], effectFun, b, c, d, true);

			if (obj["static"]) {
				function changeHandler(event: TweenEvent) {
					var coor = calculationCoor(sprite);
					switch (obj["parameter"]) {
						case "x":
							sprite.y = coor["y"];
							break;
						case "y":
							sprite.x = coor["x"];
							break;
						case "alpha":
							sprite.x = coor["x"];
							sprite.y = coor["y"];
							break;
					}
				};
				tween.addEventListener(TweenEvent.MOTION_CHANGE, changeHandler);
			}
			function backCall(): void {
				eleNameArr.push(sprite.name);
				eleArr.push(sprite);
				tween.removeEventListener(TweenEvent.MOTION_FINISH, finishHandler);
				tween=null;
				if (obj["callBack"] != null && typeof (obj["callBack"]) == "string") {
					script.callJs(obj["callBack"], sprite.name);
				}
			}
			function finishHandler(event: TweenEvent): void {
				switch (obj["parameter"]) {
					case "x":
						if (sprite.x != c) {
							tween.resume();
						} else {
							backCall();
						}
						break;
					case "y":
						if (sprite.y != c) {
							tween.resume();
						} else {
							backCall();
						}
						break;
					case "alpha":
						if (sprite.alpha != c) {
							tween.resume();
						} else {
							backCall();
						}
						break;
				}
			}
			tween.addEventListener(TweenEvent.MOTION_FINISH, finishHandler);
			
			if (obj["overStop"]) {
				function overHandler(event: MouseEvent) {
					tween.stop();
					sprite.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
					sprite.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				};
				function outHandler(event: MouseEvent) {
					var start = true;
					if (obj["pauseStop"] && pauseded) {
						start = false;
					}
					if (start) {
						tween.resume();
					}
					sprite.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
					sprite.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
				};
				sprite.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			}
			tween.start();
			var animateId = "animate" + script.randomString();
			animateArray.push(tween);
			animateElementArray.push(animateId);
			if (obj["pauseStop"]) {
				animatePauseArray.push(animateId);
			}
			return animateId;
		}
		/*
			接口函数
			继续运行animate
		*/
		public function animateResume(id: String = "") {
			var arr: Array = [];
			if (id!="" && id!="undefined" && id != "pause") {
				arr.push(id);
			} else {
				if (id === "pause") {
					arr = animatePauseArray;
				} else {
					arr = animateElementArray;
				}
			}
			for (var i: int = 0; i < arr.length; i++) {
				var index: int = animateElementArray.indexOf(arr[i]);

				if (index > -1) {
					animateArray[index].resume();
				}
			}

		}
		/*
			接口函数
			暂停运行animate
		*/
		public function animatePause(id: String = "") {
			
			var arr: Array = [];
			if (id!="" && id!="undefined" && id != "pause") {
				arr.push(id);
			} else {
				if (id === "pause") {
					arr = animatePauseArray;
				} else {
					arr = animateElementArray;
				}
			}
			for (var i: int = 0; i < arr.length; i++) {
				var index: int = animateElementArray.indexOf(arr[i]);
				if (index > -1) {
					animateArray[index].stop();
				}
			}
		}
		/*
			内置函数
			根据元件删除数组里对应的内容
		*/
		public function deleteAnimate(id) {
			var index = animateElementArray.indexOf(id);
			if (index > -1) {
				animateArray.splice(index, 1);
				animateElementArray.splice(index, 1);
			}
		}
		/*
			内置函数
			删除外部新建的元件
		*/
		public function deleteElement(name: String): void {
			var num: int = eleNameArr.indexOf(name);
			if (num > -1) {
				T.removeChild(eleArr[num]);
				eleNameArr.splice(num, 1);
				eleArr.splice(num, 1);
			}
			deleteAnimate(name);
		}
		public function changePauseded(b: Boolean): void {
			pauseded = b;
			if(animatePauseArray.length==0){
				return;
			}
			if (b) {
				animatePause("pause");
			} else {
				animateResume("pause");
			}
		}
		public function resize(): void {
			if (eleArr.length > 0) {
				for (var i: int = 0; i < eleArr.length; i++) {
					var coor: Object = calculationCoor(eleArr[i]);
					eleArr[i].x = coor["x"];
					eleArr[i].y = coor["y"];
				}
			}
		}

	}

}