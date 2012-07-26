package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Circunference extends Sprite
	{
		private const ALCANCE_REDIMENSIONAMENTO = 80 //PORCENTAGEM (80%). ACIMA DESSA % DO RAIO DE DISTANCIA DO CENTRO ATIVA O REDIMENSIONAMENTO DO CIRCULO.
		private const ALCANCE_MOVIMENTO = 40 //PORCENTAGEM (40%). ABAIXO DESSA % DO RAIO DE DISTANCIA DO CENTRO ATIVA O MOVIMENTO DO CIRCULO.
		private var circle:Sprite;
		private var circleBkg:Sprite;
		private var raioCircle:Number = 50;
		
		private var floatingPoint:Sprite;
		private var centerPoint:Sprite;
		private var arrow:Sprite;
		
		private var distanceToFloatingPoint:Number = 5;
		private var distanceToCenter:Number = 20;
		private var distanceToBoard:Number = raioCircle - 5;
		
		/**
		 * Domínio aberto ou fechado.
		 */
		private var openDomain:Boolean = true;
		
		public function Circunference() 
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
            //if (ExternalInterface.available) {
				//ExternalInterface.addCallback("setDelta", setDelta);
			//}
			
			createSprites();
			createArrow();
			drawCircle(raioCircle);
			//addFloatingPoint();
			addMainPoint();
			addDelta();
			addListeners();
		}
		
		private function addDelta():void
		{
			coords = new TextField();
			coords.defaultTextFormat = new TextFormat("Verdana", 11);
			coords.autoSize = TextFieldAutoSize.CENTER;
			coords.text = "(x,y)";
			coords.selectable = false;
			addChild(coords);
			coords.x = -30;
			coords.y = -20;
			
			delta = new TextField();
			delta.defaultTextFormat = new TextFormat("Symbol", 20);
			delta.autoSize = TextFieldAutoSize.CENTER;
			delta.text = "d";
			delta.selectable = false;
			addChild(delta);
			delta.x = (raioCircle / 2) * Math.cos(135 * Math.PI / 180);
			delta.y = -delta.x;
		}
		
		public function updateDelta(text:String):void
		{
			if (text == "") {
				coords.text = "(x,y)";
			}else {
				coords.text = text;
			}
		}
		
		private function createArrow():void 
		{
			arrow.graphics.beginFill(0x000000);
			arrow.graphics.lineStyle(1, 0x000000, 1, false, "none");
			arrow.graphics.moveTo(0, 0);
			arrow.graphics.lineTo(5, - 10);
			arrow.graphics.lineTo(5, - 5);
			arrow.graphics.lineTo(10, - 5);
			arrow.graphics.lineTo(0, 0);
		}
		
		private function createSprites():void 
		{
			circleBkg = new Sprite();
			addChild(circleBkg);
			
			circle = new Sprite();
			addChild(circle);
			
			centerPoint = new Sprite();
			addChild(centerPoint);
			
			arrow = new Sprite();
			addChild(arrow);
			
			floatingPoint = new Sprite();
			addChild(floatingPoint);
			floatingPoint.x = 20;
			floatingPoint.y = 20;
		}
		
		private function drawCircle(raio:Number):void 
		{
			circleBkg.graphics.clear();
			circleBkg.graphics.beginFill(0x808080, 0);
			circleBkg.graphics.drawCircle(0, 0, raio + 10);
			circleBkg.graphics.endFill();
			
			circle.graphics.clear();
			circle.graphics.beginFill(0x808080, 0.6);
			circle.graphics.drawCircle(0, 0, raio);
			circle.graphics.endFill();
			
			var angle:Number = 135 * Math.PI / 180;
			var finalPosArrow:Point = new Point((raio)* Math.cos(angle), (raio) * Math.sin(angle));
			circle.graphics.lineStyle(1, 0x000000,1, false,"none");
			circle.graphics.moveTo(0, 0);
			circle.graphics.lineTo(finalPosArrow.x, finalPosArrow.y);
			addArrow(raio);
		}
		
		private function addMainPoint():void 
		{
			centerPoint.graphics.beginFill(0x000000);
			centerPoint.graphics.drawCircle(0, 0, 2);
			//circle.graphics.endFill();
		}
		
		private function addArrow(raio:Number):void
		{
			var angle:Number = 135 * Math.PI / 180;
			var finalPosArrow:Point = new Point((raio)* Math.cos(angle), (raio) * Math.sin(angle));
				
			arrow.x = finalPosArrow.x;
			arrow.y = finalPosArrow.y;
		}
		
		private function addFloatingPoint():void 
		{
			floatingPoint.graphics.beginFill(0x000000);
			floatingPoint.graphics.drawCircle(0, 0, 2);
		}
		
		private function addListeners():void 
		{
			addChild(mouseMoveForm);
			addChild(mouseResizeForm);
			mouseMoveForm.visible = false;
			mouseResizeForm.visible = false;
			//mouseMoveForm.x = mouseResizeForm.x = stage.mouseX;
			//mouseMoveForm.y = mouseResizeForm.y = stage.mouseY;
			//mouseMoveForm.startDrag();
			//mouseResizeForm.startDrag();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		private var mouseMoveForm:MoveForm = new MoveForm();
		private var mouseResizeForm:ResizeForm = new ResizeForm();
		
		private function moveHandler(e:MouseEvent):void 
		{
			mouseMoveForm.x = mouseResizeForm.x = this.mouseX;
			mouseMoveForm.y = mouseResizeForm.y = this.mouseY;
			
			mouseResizeForm.rotation = Math.atan2(this.mouseY, this.mouseX) * 180 / Math.PI;
			
			if(Point.distance(new Point(this.mouseX, this.mouseY), new Point(0,0)) < raioCircle + 10){
				var centerDistance:Number = Point.distance(new Point(this.mouseX, this.mouseY), new Point(0, 0));
				var distanceToBoard:Number = raioCircle - centerDistance;
				
				if (centerDistance < distanceToBoard) {
					if (mouseMoveForm.visible == false) {
						mouseResizeForm.visible = false;
						mouseMoveForm.visible = true;
						dispatchEvent(new Event("mouseHide"));
					}
				}else {
					if (mouseResizeForm.visible == false) {
						mouseMoveForm.visible = false;
						mouseResizeForm.visible = true;
						dispatchEvent(new Event("mouseHide"));
					}
				}
			}else {
				if (mouseMoveForm.visible || mouseResizeForm.visible) {
					mouseMoveForm.visible = false;
					mouseResizeForm.visible = false;
					dispatchEvent(new Event("mouseShow"));
				}
			}
		}
		
		private var actualScale:Number = 1;
		
		public function changeComponentsScale(scale:Number):void
		{
			arrow.scaleX = arrow.scaleY = 1/scale;
			centerPoint.scaleX = centerPoint.scaleY = 1/scale;
			floatingPoint.scaleX = floatingPoint.scaleY = 1 / scale;
			coords.scaleX = coords.scaleY = 1 / scale;
			delta.scaleX = delta.scaleY = 1 / scale;
			actualScale = scale;
			
			coords.x = - 30 / scalePlano;
			coords.y = - 20 / scalePlano;
			
			delta.x = (raioCircle / 2) * Math.cos(135 * Math.PI / 180);
			delta.y = -delta.x;
			
			if (raioCircle < 30 / scalePlano) coords.visible = false;
			else coords.visible = true;
			if (raioCircle < 35 / scalePlano) delta.visible = false;
			else delta.visible = true;
			if (raioCircle < 10 / scalePlano) arrow.visible = false;
			else arrow.visible = true;
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			var centerDistance:Number = Point.distance(new Point(this.mouseX, this.mouseY), new Point(0, 0));
			//var floatingPointDistance:Number = Point.distance(new Point(this.mouseX, this.mouseY), new Point(floatingPoint.x, floatingPoint.y));
			var distanceToBoard:Number = raioCircle - centerDistance;
			
			if (centerDistance < distanceToBoard) {
				dispatchEvent(new Event("initDrag"));
				startDragingThis();
			}else {
				redrawCircle();
			}
			
			
			
			//var centerDistance:Number = Point.distance(new Point(this.mouseX, this.mouseY), new Point(0, 0));
			//var floatingPointDistance:Number = Point.distance(new Point(this.mouseX, this.mouseY), new Point(floatingPoint.x, floatingPoint.y));
			//trace("centerDistance: " + String(centerDistance), "distanceToCenter: " + String(distanceToCenter) ,"distanceToBoard: " + String(distanceToBoard), "raioCircle: " + String(raioCircle));
			//
			///*if (floatingPointDistance <= distanceToFloatingPoint) { //Arrasta o ponto flutuante
				//startDragingFloatingPoint();
			//}else */if (centerDistance <= distanceToCenter) { //Arrasta tudo
				//startDragingThis();
			//}else if (centerDistance >= distanceToBoard && centerDistance <= raioCircle + 5) { //Arrasta a borda
				//redrawCircle();
			//}
		}
		
		private var correcao:Point;
		
		//----------------------------------- Arraste da classe ----------------------------------
		public var allowXDrag:Boolean = true;
		public var allowYDrag:Boolean = true;
		public var allowResize:Boolean = true;
		public var dragging:Boolean = false;
		private function startDragingThis():void 
		{
			dragging = true;
			//correcao = new Point(stage.mouseX - this.x, stage.mouseY - this.y);
			correcao = new Point(this.parent.mouseX - this.x, this.parent.mouseY - this.y);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove_this);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp_this);
		}
		
		public var domain:Rectangle;
		private var minDist:Number = 4;
		private function mouseMove_this(e:MouseEvent):void 
		{
			if (allowXDrag) {
				if (openDomain) {
					this.x = Math.max(10, Math.min(690, this.parent.mouseX - correcao.x));
					this.y = Math.max(10, Math.min(490, this.parent.mouseY - correcao.y));
				}else{
					if (Math.abs((stage.mouseX - correcao.x) - domain.x) <= minDist) {
						this.x = domain.x;
					}else if (Math.abs((stage.mouseX - correcao.x) - (domain.x + domain.width)) <= minDist) {
						this.x = domain.x + domain.width;
					}else {
						this.x = Math.max(10, Math.min(690, this.parent.mouseX - correcao.x));
					}
					
					if (Math.abs((stage.mouseY - correcao.y) - domain.y) <= minDist) {
						this.y = domain.y;
					}else if (Math.abs((stage.mouseY - correcao.y) - (domain.y + domain.height)) <= minDist) {
						this.y = domain.y + domain.height;
					}else{
						this.y = Math.max(10, Math.min(490, this.parent.mouseY - correcao.y));
					}
				}
			}
		}
		
		private function mouseUp_this(e:MouseEvent):void 
		{
			dragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove_this);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_this);
			dispatchEvent(new Event("stopDrag"));
		}
		//----------------------------------- Fim do arraste da classe ---------------------------
		
		
		//----------------------------------- Arraste do ponto flutuante -------------------------
		private function startDragingFloatingPoint():void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove_FloatingPoint);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp_FloatingPoint);
		}
		
		private function mouseMove_FloatingPoint(e:MouseEvent):void 
		{
			var radius:Number = Math.min(raioCircle, Math.sqrt(Math.pow(this.mouseX, 2) + Math.pow(this.mouseY, 2))) - 1 * (1/actualScale);
			var angle:Number = Math.atan2(this.mouseY, this.mouseX);
			
			floatingPoint.x = radius * Math.cos(angle);
			floatingPoint.y = radius * Math.sin(angle);
		}
		
		private function mouseUp_FloatingPoint(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove_FloatingPoint);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_FloatingPoint);
		}
		//----------------------------------- Fim do arraste do ponto flutuante ------------------
		
		//----------------------------------- Redesenha o círculo --------------------------------
		private var correcaoRaio:Number;
		private var maxRaio:Number;
		public var scalePlano:Number = 1;
		private var minRaio:Number;
		private var delta:TextField;
		private var coords:TextField;
		
		private function redrawCircle():void 
		{
			if (!allowResize) return;
			correcaoRaio = raioCircle - Point.distance(new Point(this.mouseX, this.mouseY), new Point(0, 0));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove_redrawCircle);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp_redrawCircle);
		}
		
		private function mouseMove_redrawCircle(e:MouseEvent):void 
		{
			minRaio = 5 / scalePlano;
			maxRaio = 1000000 / scalePlano;
			distanceToCenter = (ALCANCE_MOVIMENTO / 100) * raioCircle;
			distanceToBoard = (ALCANCE_REDIMENSIONAMENTO / 100) * raioCircle;
 			raioCircle = Math.max(minRaio, Math.min(Point.distance(new Point(this.mouseX, this.mouseY), new Point(0, 0)) + correcaoRaio, maxRaio));
			drawCircle(raioCircle);
			moveFloatingPoint();
			
			delta.x = (raioCircle / 2) * Math.cos(135 * Math.PI / 180);
			delta.y = -delta.x;
			
			if (raioCircle < 30 / scalePlano) coords.visible = false;
			else coords.visible = true;
			if (raioCircle < 35 / scalePlano) delta.visible = false;
			else delta.visible = true;
			if (raioCircle < 10 / scalePlano) arrow.visible = false;
			else arrow.visible = true;
		}
		
		private function mouseUp_redrawCircle(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove_redrawCircle);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_redrawCircle);
		}
		//----------------------------------- Fim redesenha o círculo ---------------------------
		
		public function setDelta(size:Number):void
		{
 			raioCircle = size;
			minRaio = 5 / scalePlano;
			maxRaio = 1000000 / scalePlano;
			distanceToCenter = (ALCANCE_MOVIMENTO / 100) * raioCircle;
			distanceToBoard = (ALCANCE_REDIMENSIONAMENTO / 100) * raioCircle;
 			raioCircle = size;
			drawCircle(raioCircle);
			moveFloatingPoint();
			
			delta.x = (raioCircle / 2) * Math.cos(135 * Math.PI / 180);
			delta.y = -delta.x;
			
			if (raioCircle < 30 / scalePlano) coords.visible = false;
			else coords.visible = true;
			if (raioCircle < 35 / scalePlano) delta.visible = false;
			else delta.visible = true;
			if (raioCircle < 10 / scalePlano) arrow.visible = false;
			else arrow.visible = true;
		}
		
		public function getDelta():Number
		{
			return raioCircle;
		}
		
		private function moveFloatingPoint():void 
		{
			if (Point.distance(floatingPointPos, new Point(0, 0)) > raioCircle) {
				var angle:Number = Math.atan2(floatingPoint.y, floatingPoint.x);
				
				floatingPoint.x = (raioCircle - 1 * (1/actualScale)) * Math.cos(angle);
				floatingPoint.y = (raioCircle - 1 * (1/actualScale)) * Math.sin(angle);
			}
		}
		
		public function get floatingPointPos():Point
		{
			return new Point(floatingPoint.x, floatingPoint.y);
		}
	}

}