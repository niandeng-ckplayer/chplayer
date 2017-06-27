package chaction.act {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-03-17
	*/
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import chaction.style.language;
	import flash.events.ErrorEvent;

	public class script {

		public static function formatTime(seconds: Number = 0, ishours: Boolean = false): String { //格式化秒数为时分秒
			var tSeconds: String = "",
				tMinutes: String = "",
				tHours: String = "";
			var s: int = Math.floor(seconds % 60),
				m: int = 0,
				h: int = 0;
			if (ishours) {
				m = Math.floor(seconds / 60) % 60;
				h = Math.floor(seconds / 3600);
			} else {
				m = Math.floor(seconds / 60);
			}
			tSeconds = (s < 10) ? "0" + s : s + "";
			tMinutes = (m > 0) ? ((m < 10) ? "0" + m + ":" : m + ":") : "00:";
			tHours = (h > 0) ? ((h < 10) ? "0" + h + ":" : h + ":") : "";

			if (ishours) {
				return tHours + tMinutes + tSeconds;
			} else {
				return tMinutes + tSeconds;
			}
		}
		public static function getNowDate(): String { //获取当前时间
			var nowDate: Date = new Date();
			var month: int = nowDate.month + 1;
			var date: int = nowDate.date;
			var hours: int = nowDate.hours;
			var minutes: int = nowDate.minutes;
			var seconds: int = nowDate.seconds;
			var tMonth: String = "",
				tDate: String = "",
				tHours: String = "",
				tMinutes: String = "",
				tSeconds: String = ""
			tSeconds = (seconds < 10) ? "0" + seconds : seconds + "";
			tMinutes = (minutes < 10) ? "0" + minutes : minutes + "";
			tHours = (hours < 10) ? "0" + hours : hours + "";
			tDate = (date < 10) ? "0" + date : date + "";
			tMonth = (month < 10) ? "0" + month : month + "";
			return tMonth + "/" + tDate + " " + tHours + ":" + tMinutes + ":" + tSeconds;
		}
		public static function getFileExt(filepath: String = null): String { //判断后缀
			if (filepath != "") {
				if (filepath.indexOf("?") > -1) {
					filepath = filepath.split("?")[0];
				}
				var pos: String = "." + filepath.replace(/.+\./, "");
				return pos;
			}
			return "";
		}
		public static function arrSort(arr: Array): Array { //对二维数组进行冒泡排序
			var temp: Array = [];
			for (var i: int = 0; i < arr.length; i++) {
				for (var j: int = 0; j < arr.length - i; j++) {
					if (arr[j + 1] && arr[j][3] < arr[j + 1][3]) {
						temp = arr[j + 1];
						arr[j + 1] = arr[j];
						arr[j] = temp;
					}
				}
			}
			return arr;
		}
		public static function getCoor(stageW: int, stageH: int, vw: int, vh: int): Object { //根据宽高计算元素的长宽和坐标
			var w: int = 0,
				h: int = 0,
				x: int = 0,
				y: int = 0;
			if (stageW / stageH < vw / vh) {
				w = stageW;
				h = w * vh / vw;
			} else {
				h = stageH;
				w = h * vw / vh;
			}
			x = (stageW - w) * 0.5;
			y = (stageH - h) * 0.5;
			return {
				width: w,
				height: h,
				x: x,
				y: y
			};
		}
		public static function mergeObject(obj: Object = null, old: Object = null): Object { //把旧数组合并到新数组里
			var nObj: Object = obj;
			for (var k: String in old) {
				nObj[k] = old[k];
			}
			return nObj;
		}
		public static function getStringLen(str): int { //计算字符长度，中文算2，字母数字算1
			var len: int = 0;
			for (var i: int = 0; i < str.length; i++) {
				if (str.charCodeAt(i) > 127 || str.charCodeAt(i) == 94) {
					len += 2;
				} else {
					len++;
				}
			}
			return len;
		}
		public static function copyObject(obj: Object): * { //复制对象
			var newObj: ByteArray = new ByteArray()
			newObj.writeObject(obj);
			newObj.position = 0;
			return newObj.readObject();
		}
		public static function getLen(str: String = ""): Number { //获取字符的长度
			if (!str) {
				return 0;
			}
			var digital: int = 0; //数字  
			var character: int = 0; //字母  
			var space: int = 0; //空格  
			var other: int = 0; //其它字符 
			for (var i: int = 0; i < str.length; i++) {
				if (str.charAt(i) >= '0' && str.charAt(i) <= '9') {
					digital++;
				} else if ((str.charAt(i) >= 'a' && str.charAt(i) <= 'z') || (str.charAt(i) >= 'A' && str.charAt(i) <= 'Z')) {
					character++;
				} else if (str.charAt(i) == ' ') {
					space++;
				} else {
					other++;
				}
			}
			return (digital + character + space + other * 2) * 0.5
		}
		public static function amendedLanguage(obj: Object = null): void { //修改语言包
			if (obj) {
				for (var k in obj) {
					language[k] = obj[k];
				}
			}

		}

		public static function addListenerArr(listenerArr: Array, ele: String = "", fun: String = ""): Array { //添加监听函数数组
			if (ele != "" && fun != "") {
				var have: Boolean = false;
				for (var i: int = 0; i < listenerArr.length; i++) {
					var arr = listenerArr[i];
					if (arr[0] == ele && arr[1] == fun) {
						have = true;
						break;
					}
				}
				if (!have) {
					listenerArr.push([ele, fun]);
				}
			}
			return listenerArr;
		}

		public static function removeListenerArr(listenerArr: Array, ele: String = "", fun: String = ""): Array { //删除监听函数数组
			if (ele != "" && fun != "") {
				var n: int = -1;
				for (var i: int = 0; i < listenerArr.length; i++) {
					var arr = listenerArr[i];
					if (arr[0] == ele && arr[1] == fun) {
						n = i
						break;
					}
				}
				if (!n > -1) {
					listenerArr.splice(n, 1);
				}
			}
			return listenerArr;
		}
		public static function log(val: * ): void {
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", val);
			}
		}
		public static function callJs(js: String, val: *= null): void {
			var arr:Array=js.split(".");
			if (arr[0]=="" || !ExternalInterface.available) {
				return;
			}
			if (val != null) {
				try {
					ExternalInterface.call(js, val);
				} catch (event) {
					log(event)
				}
			} else {
				try {
					ExternalInterface.call(js);
				} catch (event) {
					log(event)
				}
			}
		}
		public static function openLink(url: String, target: String = '_blank', features: String = ""): void {
			var myURL: URLRequest = new URLRequest(url);
			try {
				ExternalInterface.call("window.open", url, target, features);
			} catch (event: ErrorEvent) {
				try {
					ExternalInterface.call("function setWMWindow() {window.open('" + url + "', '" + target + "', '" + features + "');}");
				} catch (event: ErrorEvent) {
					navigateToURL(myURL, target);
				}
			}
		}
		public static function getHttpKey(info: Object): Object {
			var k: String = "";
			var vf: Array = [],
				vt: Array = [];
			if (info.hasOwnProperty("keyframes")) {
				var keyframes: Object = info["keyframes"];
				for (k in keyframes) {
					switch (k) {
						case "times":
							vt.push(keyframes[k]);
							break;
						case "filepositions":
							vf.push(keyframes[k]);
							break;
						default:
							break;
					}
				}
			} else if (info.hasOwnProperty("seekpoints")) {
				var seekpoints:Object=info["seekpoints"];
				for (k in seekpoints) {
					var seekpoints2=seekpoints[k];
					for (var k2: String in seekpoints2) {
						switch (k2) {
							case "time":
								vt.push(seekpoints2[k2]);
								break;
							case "offset":
								vf.push(seekpoints2[k2]);
								break;
							default:
								break;
						}
					} //end for k2
				} //end for k
			}
			if(vt.length>0){
				info["keytime"]=vt;
				info["keyframes"]=vf;
			}
			return info;
		}
		public static function randomString(len:int=16):String {//获取一个随机值
			var chars:String = "abcdefghijklmnopqrstuvwxyz";
			var maxPos:int = chars.length;　　
			var val:String = "";
			for(var i:int = 0; i < len; i++) {
				val += chars.charAt(Math.floor(Math.random() * maxPos));
			}
			return 'ckv' + val;
		}
	}

}