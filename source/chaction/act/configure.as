package chaction.act {
	/*
		软件名称：chplayer
		软件作者：http://www.chplayer.com
		开源软件协议：Mozilla Public License, version 2.0(MPL 2.0)
		MPL 2.0协议英文（原文，正本）查看地址：https://www.mozilla.org/en-US/MPL/2.0/
		MPL 2.0协议中文（翻译）查看地址：http://www.chplayer.com/res/Mozilla_Public_License_2.0_Simplified_Chinese_Reference.txt
		文件最后更新日期：2017-04-07
	*/
	public class configure {
		public static function getConfigure(flashvars: Object = null): Object {
			// constructor code
			var config: Object = {
				variable:"chplayer",
				video: "",
				poster:"",
				volume: 0.8,
				autoplay: 0,
				loop:0,
				timerep:0,//时间表示形式,0=分：秒，1=时：分：秒，2=显示内容
				live:0,//是否是直播，0=不是，1=是
				interactive:0,//指示全屏模式下是否可交互
				seek:0,//默认跳转的时间
				drag:"",//
				front:"",//点击上一集执行的动作
				next:"",//点击下一集执行的动作
				weight:"",//权重
				definition:"",//清晰度
				preview:"",//预览图列表
				previewscale:6,//预览图时间间隔
				prompt:"",//提示点内容
				prompttime:"",//提示点时间
				logo:"chplayer",
				debug:0
			}
			config=script.mergeObject(config,flashvars);
			config["autoplay"]=Number(config["autoplay"]);
			config["volume"]=Number(config["volume"]);
			config["live"]=Number(config["live"]);
			config["seek"]=Number(config["seek"]);
			var videoArr:Array=config["video"].split("|"),
			definitionArr:Array=config["definition"].split("|"),
			weightArr:Array=config["weight"].split("|");
			var vArr:Array=[];
			for(var i:int=0;i<videoArr.length;i++){
				vArr.push([videoArr[i],definitionArr[i],script.getFileExt(videoArr[i]),weightArr[i]]);
			}
			config["video"]=vArr;
			return config;
		}

	}

}