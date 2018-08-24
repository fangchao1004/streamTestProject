package
{
	public class FMSClient
	{
		public function FMSClient()
		{
//			clientName = name;
		}
		
		private var clientName:String;
		
		public function onMetaData(info:Object):void 
		{
			//		trace(clientName + " metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		}
		public function onCuePoint(info:Object):void 
		{
			//		trace(clientName + "cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		public function onBWDone():void
		{
		}
	}
}