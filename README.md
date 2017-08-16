# chplayer
网页视频播放器，html5优先，兼容移动端，支持mp4,flv,f4v以及m3u8格式，支持rtmp。支持点播和直播
官网：http://www.chplayer.com
演示：http://www.chplayer.com/down/v1.0/

## 调用示例
```
<script type="text/javascript">
   var videoObject = {
       logo: 'chplayer', //设置logo，非必须
       container: '#video',//“#”代表容器的ID，“.”或“”代表容器的class
       variable: 'player',//该属性必需设置，值等于下面的new chplayer()的对象
       video:'examples01.mp4'//视频地址
   };
   var player=new chplayer(videoObject);
</script>
```