package
{
	import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import coco.component.Alert;
	import coco.component.Button;
	import coco.component.Label;
	import coco.component.TextInput;
	import coco.core.UIComponent;
	import coco.event.UIEvent;
	
	import components.IconSlider;
	
	public class PushStreamView extends UIComponent
	{
		public function PushStreamView()
		{
			width = 500;
			height = 100
			super();
		}
		
		private var nc : NetConnection;
		private var ns : NetStream ;
		private var cam : Camera;
		private var mic : Microphone;
		private var soundTrans : SoundTransform;
		
		private var lab1 : Label;
		private var urlInput : TextInput;
		private var lab2 : Label;
		private var stNameInput : TextInput;
		private var startBtn : Button;
		private var stopBtn : Button;
		private var micSlider : IconSlider;
		
		private var streamName : String;
		private var streamUrl : String;
		
		override protected function createChildren():void
		{
		    super.createChildren();
			
			lab1 = new Label();
			lab1.text = "推流地址:\r(流名)";
			lab1.fontSize = 14;
			addChild(lab1);
			
			urlInput = new TextInput();
			urlInput.fontSize = 14;
			urlInput.text = "rtmp://192.168.1.2:9000/live/test";
			addChild(urlInput);
			
			startBtn = new Button();
			startBtn.label = "开始";
			startBtn.fontSize = 14;
			startBtn.buttonMode = true;
			startBtn.addEventListener(MouseEvent.CLICK,start_handler);
			addChild(startBtn);
			
			stopBtn = new Button();
			stopBtn.label = "终止";
			stopBtn.fontSize = 14;
			stopBtn.buttonMode = true;
			stopBtn.addEventListener(MouseEvent.CLICK,stop_handler);
			addChild(stopBtn);
			
			micSlider = new IconSlider();
			micSlider.iconSourceArray = ["mic_open.png","mic_close.png"];
			micSlider.x = 40;
			micSlider.y = 40;
			micSlider.width = 140;
			micSlider.height = 24;
			micSlider.icon1_height = micSlider.icon1_width = micSlider.icon2_height = micSlider.icon2_width = 21;
			//			micSlider.sliderIsVertical = true;
			micSlider.addEventListener(UIEvent.CHANGE,changeHandler);
			addChild(micSlider);
			
			nc = new NetConnection();
			nc.client = new FMSClient();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);  
		}
		
		protected function changeHandler(event:UIEvent):void
		{
//			trace(" 滑块值  ："+Math.ceil(micSlider.sliderNumber));
			if(mic) mic.gain = Math.ceil(micSlider.sliderNumber);
		}
		
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			
			lab1.x = 10;
			lab1.y = 10;
			
			urlInput.width = 250;
			urlInput.x = 80;
			urlInput.y = 10;
			
			
			startBtn.width = 50;
			startBtn.x = urlInput.width+urlInput.x+20 ;
			startBtn.y = 10;
			
			stopBtn.width = 50;
			stopBtn.x = startBtn.x + startBtn.width+20 ;
			stopBtn.y = 10;
			
			micSlider.x = startBtn.x;
			micSlider.y = startBtn.y + startBtn.height + 50;
		}
		
		override protected function drawSkin():void
		{
			super.drawSkin();
			
			graphics.clear();
			graphics.beginFill(0xFFFAF0);
			graphics.drawRect(0,0,500,100);
			graphics.endFill();
		}
		
		protected function stop_handler(event:MouseEvent):void
		{
			stopPush();
		}
		
		protected function start_handler(event:MouseEvent):void
		{
			if(urlInput.text!="")
			{
				getStreamUrl(urlInput.text);
			}else
			{
				Alert.show("请检查地址和流名");
			}
			
		}
		
		private function getStreamUrl(url:String):void
		{
			try
			{
				trace("输入："+url);
				var headUrl : String = url.substring(0,7);
				var index : int= url.lastIndexOf("\/");  
				streamName  = url.substring(index + 1, url .length);
				streamUrl = url.substring(0,index);
				
				if(headUrl=="rtmp://"&&streamName)
				{
					trace("头："+headUrl);
					trace("流名："+streamName);
					trace("地址："+streamUrl);
					
					nc.connect(streamUrl);
				}
			} 
			catch(error:Error) 
			{
				Alert.show("输入格式可能有误，请参照测试地址");
			}
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetConnection.Connect.Success":
				{
					startPush();
					break;
				}
				case "NetConnection.Connect.Failed":
				{
					Alert.show("连接失败");
					stopPush();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private function stopPush():void
		{
			if(nc.connected)
			{
				nc.close();
				ns.attachCamera(null);
			}else
			{
				Alert.show("己断开连接");
			}
		}
		
		private function startPush():void
		{
			cam = Camera.getCamera();
			cam.setMode(480,320,15);
			cam.setKeyFrameInterval(15);
			cam.setQuality(0,100);
			
			mic = Microphone.getMicrophone();
			mic.setUseEchoSuppression(true);  
//			mic.setLoopBack(true);    //将麦克风捕获的音频传送到本地扬声器。
			mic.gain = micSlider.sliderNumber;
			mic.addEventListener(ActivityEvent.ACTIVITY, this.onMicActivity);  
			mic.addEventListener(StatusEvent.STATUS, this.onMicStatus);  
			
//			var micDetails:String = "Sound input device name: " + mic.name + '\n';  
//			micDetails += "Gain: " + mic.gain + '\n';  
//			micDetails += "Rate: " + mic.rate + " kHz" + '\n';  
//			micDetails += "Muted: " + mic.muted + '\n';  
//			micDetails += "Silence level: " + mic.silenceLevel + '\n';  
//			micDetails += "Silence timeout: " + mic.silenceTimeout + '\n';  
//			micDetails += "Echo suppression: " + mic.useEchoSuppression + '\n';  
//			trace(micDetails);  
			
			
			
			ns = new NetStream(nc);
			ns.client = new FMSClient();
			ns.attachCamera(cam);
			ns.attachAudio(mic);
			ns.publish(streamName,"live");
		}
		
		protected function onMicActivity(event:ActivityEvent):void  
		{  
//			trace("activating=" + event.activating + ", activityLevel=" + mic.activityLevel);  
		}  
		
		protected function onMicStatus(event:StatusEvent):void  
		{  
//			trace("status: level=" + event.level + ", code=" + event.code);  
		} 
	}
	
	
}