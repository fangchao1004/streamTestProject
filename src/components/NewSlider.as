package components
{
	import flash.events.MouseEvent;
	
	import coco.component.Button;
	import coco.core.UIComponent;
	import coco.event.UIEvent;
	
	[Event(name="ui_change", type="coco.event.UIEvent")]
	
	/**
	 * ---|----------
	 * 
	 * 滑块组件
	 * 
	 * @author Coco
	 */	
	public class NewSlider extends UIComponent
	{
		public function NewSlider()
		{
			super();
		}
		
		//----------------------------------------------------------------------------------------------------------------
		//
		// Vars
		//
		//----------------------------------------------------------------------------------------------------------------
		
		protected var thumbButton:Button;
		private var thumbMaxX:Number = 0;
		private var thumbMaxY:Number = 0;
		
		private var oldMouseX:Number;
		private var oldMouseY:Number;
		private var oldThumbX:Number = 0;
		private var oldThumbY:Number = 0;
		private var valuePerX:Number = 0;
		private var valuePerY:Number = 0;
		
		private var _minValue:Number = 0;
		
		public function get minValue():Number
		{
			return _minValue;
		}
		
		public function set minValue(value:Number):void
		{
			_minValue = value;
			
			invalidateDisplayList();
		}
		
		private var _maxValue:Number = 0;
		
		public function get maxValue():Number
		{
			return _maxValue;
		}
		
		public function set maxValue(value:Number):void
		{
			_maxValue = value;
			
			invalidateDisplayList();
		}
		
		private var _value:Number = 0;
		
		public function get value():Number
		{
			if (_value < minValue)
				return minValue;
			else if (_value > maxValue)
				return maxValue;
			else
				return _value;
		}
		
		public function set value(value:Number):void
		{
			_value = value;
			
			invalidateDisplayList();
		}
		
		private var _isVertical:Boolean;

		public function get isVertical():Boolean
		{
			return _isVertical;
		}

		public function set isVertical(value:Boolean):void
		{
			_isVertical = value;
			invalidateProperties();
		}
		
		
		//----------------------------------------------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------------------------------------------
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			thumbButton = new Button();
			thumbButton.addEventListener(MouseEvent.MOUSE_DOWN, thumbButton_mouseDownHandler);
			addChild(thumbButton);
		}
		
		override protected function measure():void
		{
			measuredWidth = 100;
			measuredHeight = 40;
		}
		
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			
			if(isVertical==false)
			{
				graphics.clear();
				graphics.beginFill(0xff0000,0)
				graphics.drawRect(0,0,width,height);
				graphics.endFill();
				
				graphics.beginFill(0xeeeeee);
				
				thumbButton.width = height/4;
				thumbButton.height = height-6;
				thumbButton.y = 3;
				graphics.drawRect(thumbButton.width / 2, height/2-3, width - thumbButton.width, 6);
				
				thumbMaxX = width - thumbButton.width;
				valuePerX = (maxValue - minValue) / thumbMaxX;
				thumbButton.x = (value - minValue) / valuePerX;
				
				graphics.beginFill(0x00ff00,0.5);
				graphics.drawRect(thumbButton.width / 2, height/2-3, int((width-thumbButton.width)*(value/maxValue)), 6);
				graphics.endFill();
				
				/*trace("int(width*(value/maxValue)-thumbButton.width): "+String(int((width-thumbButton.width)*(value/maxValue))));
				trace("水平："+value);*/
			}else
			{
				graphics.clear();
				graphics.beginFill(0xff0000,0)
				graphics.drawRect(0,0,height,width);
				graphics.endFill();
				
				graphics.beginFill(0xeeeeee);
				
				thumbButton.width = height-6;
				thumbButton.height = height/4;
				thumbButton.x = 3;
				graphics.drawRect(height/2-3,thumbButton.height / 2,  6, width - thumbButton.height);
				thumbMaxY = width - thumbButton.height;
				valuePerY = (maxValue - minValue) / thumbMaxY;
				thumbButton.y = width-(value - minValue) / valuePerY-thumbButton.height;
//				trace("垂直-value:"+int(value));
				
				graphics.beginFill(0x00ff00,0.5);
				graphics.drawRect(height/2-3,(width*(1-value/maxValue)),  6, (width-thumbButton.height/2)*(value/maxValue));
				graphics.endFill();
//				trace("int(height-value)-thumbButton.height/2:"+ String(int(height-value)-thumbButton.height/2))
			}
			
			graphics.endFill();
		}
		
		protected function thumbButton_mouseDownHandler(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, this_mouseUpHandler);
			oldMouseX = mouseX;
			oldThumbX = thumbButton.x;
			oldMouseY = mouseY;
			oldThumbY = thumbButton.y;
		}
		
		protected function this_mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this_mouseUpHandler);
		}
		
		protected function this_mouseMoveHandler(event:MouseEvent):void
		{
			if(isVertical==false)
			{
				var newThumbX:Number = oldThumbX + mouseX - oldMouseX;
				if (newThumbX < 0)
					newThumbX = 0;
				else if (newThumbX > thumbMaxX)
					newThumbX = thumbMaxX;
				thumbButton.x = newThumbX;
				_value = newThumbX * valuePerX + minValue;
				dispatchEvent(new UIEvent(UIEvent.CHANGE));
			}else
			{
				var newThumbY:Number = oldThumbY + mouseY - oldMouseY;
				if (newThumbY < 0)
					newThumbY = 0;
				else if (newThumbY > thumbMaxY)
					newThumbY = thumbMaxY;
				thumbButton.y = newThumbY;
				_value = (maxValue-newThumbY * valuePerY + minValue);
				dispatchEvent(new UIEvent(UIEvent.CHANGE));
			}
			
			invalidateDisplayList();
		}
		
	}
}