package
{
	import coco.core.Application;
	
	[SWF(width="500" ,height="560")]
	public class sample_steam extends Application
	{
		public function sample_steam()
		{
			
			var homeView : HomeView = new HomeView();
			homeView.width = width;
			homeView.height = height;
			addChild(homeView);
		}
	}
}