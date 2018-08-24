package
{
	import coco.core.UIComponent;
	
	public class HomeView extends UIComponent
	{
		public function HomeView()
		{
			super();
		}
		
		private var pushView : PushStreamView;
		private var getView : GetStreamView;
		override protected function createChildren():void
		{
		   super.createChildren();
		   
		   pushView = new PushStreamView();
		   addChild(pushView);
		   
		   getView = new GetStreamView();
		   addChild(getView);
		}
		
		override protected function updateDisplayList():void
		{
		   super.updateDisplayList();
		   
		   pushView.x = 0;
		   pushView.y = 0;
		   
		   getView.x = 0;
		   getView.y = 102;
		}
	}
}