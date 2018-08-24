package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import coco.component.Alert;
	import coco.component.Button;
	import coco.component.Label;
	import coco.component.TextInput;
	import coco.core.UIComponent;
	import coco.event.UIEvent;
	
	import components.IconSlider;
	
	public class GetStreamView extends UIComponent
	{
		public function GetStreamView()
		{
			width = 500;
			height = 460;
			super();
			addEventListener(Event.ENTER_FRAME, this_enterFrameHandler);
		}
		
		private var video : Video
		private var netConnection : NetConnection;
		private var netStream : NetStream;
		private var client : FMSClient;
		private var urlInput : TextInput;
		private var streamName : String;
		private var streamUrl : String;
		private var soundChannel : SoundChannel;
		private var soundTrans : SoundTransform
		
		private var lab : Label;
		private var lab1 : Label;
		private var testUrl1 : TextInput ;
		private var connectBtn : Button;
		private var disConnectBtn : Button;
		private var voiceSlider : IconSlider;
		private var statusLabel : Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			lab = new Label();
			lab.fontSize = 14;
			lab.text = "拉流地址:\r(流名)";
			addChild(lab);
			
			lab1 = new Label();
			lab1.fontSize = 14;
			lab1.text = "测试地址:\r(流名)";
			addChild(lab1);
			
			testUrl1 =new TextInput();
			testUrl1.fontSize = 14;
			testUrl1.editable = false;
			testUrl1.text = "rtmp://live.hkstv.hk.lxdns.com/live/hks";
			addChild(testUrl1);
			
			urlInput = new TextInput();
			urlInput.text = "rtmp://192.168.1.2:9000/live/test";
			urlInput.fontSize = 14;
			addChild(urlInput);
			
			connectBtn = new Button();
			connectBtn.fontSize = 14;
			connectBtn.label = "连接";
			connectBtn.buttonMode = true;
			connectBtn.addEventListener(MouseEvent.CLICK,connect_Handler);
			addChild(connectBtn);
			
			disConnectBtn = new Button();
			disConnectBtn.fontSize = 14;
			disConnectBtn.label = "断开";
			disConnectBtn.buttonMode = true;
			disConnectBtn.addEventListener(MouseEvent.CLICK,disconnect_Handler);
			addChild(disConnectBtn);
			
			voiceSlider = new IconSlider();
			voiceSlider.iconSourceArray = ["voice_open.png","voice_close.png"];
			voiceSlider.x = 200;
			voiceSlider.y = 40;
			voiceSlider.width = 140;
			voiceSlider.height = 24;
			voiceSlider.icon1_height = voiceSlider.icon1_width = voiceSlider.icon2_height = voiceSlider.icon2_width = 21;
			//			voiceSlider.sliderIsVertical = true;
			voiceSlider.addEventListener(UIEvent.CHANGE,changeHandler);
			addChild(voiceSlider);
			
			statusLabel = new Label();
			statusLabel.text = '';
			statusLabel.color = 0xFF0000;
			statusLabel.fontSize = 16;
			addChild(statusLabel);
			
			video = new Video(480,320);
			addChild(video);
			
			netConnection = new NetConnection();
			netConnection.client = new FMSClient();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		}
		
		
		
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			
			lab.x = 10;
			lab.y = 10;
			
			lab1.x = 10;
			lab1.y = 50;
			
			testUrl1.x = 80;
			testUrl1.y = 50;
			testUrl1.width = 250;
			
			urlInput.x = 80;
			urlInput.y = 10;
			urlInput.width = 250;
			
			connectBtn.x = urlInput.x + urlInput.width + 20;
			connectBtn.y = 10;
			connectBtn.width = 50;
			
			disConnectBtn.x = connectBtn.x+connectBtn.width+20;
			disConnectBtn.y = 10;
			disConnectBtn.width = 50;
			
			voiceSlider.x = connectBtn.x;
			voiceSlider.y = connectBtn.y + connectBtn.height + 50;
			
			statusLabel.x = voiceSlider.x;
			statusLabel.y = voiceSlider.y + voiceSlider.height + 20;
			
			video.x =10;
			video.y = 130;
		}
		
		override protected function drawSkin():void
		{
			super.drawSkin();
			
			graphics.clear();
			graphics.beginFill(0xF8F8FF);
			graphics.drawRect(0,0,500,460);
			graphics.endFill();
		}
		
		protected function disconnect_Handler(event:MouseEvent):void
		{
			if(netConnection.connected)
			{
				trace("点击断开");
				netStream.close();
				netConnection.close();
				video.attachNetStream(null);
				video.visible = false;
			}else
			{
				Alert.show("还未连接-无需断开");
			}
		}
		
		protected function connect_Handler(event:MouseEvent):void
		{
			if(urlInput.text)
			{
				if(netConnection.connected)
				{
					Alert.show("已经连接");
				}else
				{
					getStreamNameHandler(urlInput.text); ///区分流地址和流名
				}
			}else
			{
				Alert.show("请输入rtmp视频流地址");
			}
		}	
		
		private function getStreamNameHandler(url:String):void
		{
			try
			{
				var index : int= url.lastIndexOf("\/");  
				streamName  = url.substring(index + 1, url .length);
				streamUrl = url.substring(0,index);
				var headUrl : String = url.substring(0,7);
				
				trace("headUrl："+headUrl);
				trace("流名："+streamName);
				trace("流地址："+streamUrl);
				
				if(headUrl=="rtmp://"&&streamName)
				{
					netConnection.connect(streamUrl);
				}
			} 
			catch(error:Error) 
			{
				Alert.show("输入格式可能有误，请参照测试地址");
			}
		}
		
		protected function netStatusHandler(event:NetStatusEvent):void
		{
			trace("++++++++++++++++++++++++++++++++");
			trace("connected is: " + netConnection.connected);
			trace("event.info.level: " + event.info.level);
			trace("event.info.code: " + event.info.code);
			trace("++++++++++++++++++++++++++++++++");
			if(event.info.level=="status")
			{
				switch(event.info.code)
				{
					case "NetConnection.Connect.Success":
					{
						Alert.show("地址连接成功"+netConnection);
						getVideo(netConnection);
						break;
					}
					case "NetConnection.Connect.Closed":
					{
						Alert.show("连接关闭"+netConnection);
						netConnection.close();
						netStream.close();
						video.attachNetStream(null);
						video.visible = false;
						break;
					}
					default:
					{
						break;
					}
				}
			}else if(event.info.level=="error")
			{
				Alert.show("错误信息："+event.info.code);
			}
		}
		
		protected function changeHandler(event:UIEvent):void
		{
			//			trace("voiceSlider : "+voiceSlider.sliderNumber);
			if(soundTrans && netStream)
			{
				soundTrans.volume = voiceSlider.sliderNumber/100;
				//				soundChannel.soundTransform = soundTrans;
				netStream.soundTransform = soundTrans;
			}
		}
		
		private function getVideo(nc:NetConnection):void
		{
			if(nc.connected)
			{
				netStream = new NetStream(nc);
				netStream.client = new FMSClient();
				
				//创建声道
				//				soundChannel = new SoundChannel();
				//创建声音变换
				soundTrans = new SoundTransform();
				trace("voiceSlider.sliderNumber/100的值是 :  "+voiceSlider.sliderNumber/100);
				soundTrans.volume = voiceSlider.sliderNumber/100;
				//				soundChannel.soundTransform = soundTrans;
				
				netStream.soundTransform = soundTrans;
				video.visible = true;
				video.attachNetStream(netStream);
				netStream.play(streamName);//流名
				trace("拉流完成");
			}
		}
		
		private var i:int = 0;
		
		protected function this_enterFrameHandler(event:Event):void
		{
			try
			{
				if (!netStream) return;
				
				i++;
				
				if (i == 12)
				{
					i = 0;
					if (netStream)
						var speed : int = Math.ceil(netStream.info.currentBytesPerSecond/1024);
					log("使用带宽：" + speed + " KB",speed);
				}
			} 
			catch(error:Error) 
			{
				//				log("使用带宽：**** ");
				log("",0);
			}
		}
		
		private function log(msg:String,speed:int):void
		{
			if( speed<=50)
			{
				statusLabel.color= 0xFF0000;
			}
			else if ( speed>50 && speed<300)
			{
				statusLabel.color= 0xFF8C00;
			}
			else
			{
				statusLabel.color= 0x4169E1;
			}
			
			statusLabel.text = msg;
		}
	}
}