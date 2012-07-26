package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.rectangular.SimpleGraph;
	import fl.controls.Slider;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		/**
		 * Área que será manipulada dentro do gráfico.
		 */
		private var circunference:Circunference;
		
		/**
		 * Gráfico onde serão adicionados os objetos.
		 */
		private var graph:SimpleGraph;
		
		//Definições iniciais do gráfico
		private var g_xmin:Number = -1;
		private var g_xmax:Number = 7;
		private var g_xsize:int = 670;
		private var g_ymin:Number = -1;
		private var g_ymax:Number = 5;
		private var g_ysize:int = 465;
		
		/**
		 * Área do domínio do gráfico.
		 */
		private var domain:Rectangle;
		private var domainSpr:Sprite;
		
		//Configuração inicial do domínio.
		private var d_xini:Number = 0;
		private var d_xend:Number = 6;
		private var d_yini:Number = 0;
		private var d_yend:Number = 3;
		
		//Botões de zoom.
		private var zoomIn:ZoomIn;
		private var zoomOut:ZoomOut;
		
		override protected function init():void 
		{
			configGraph();
			configDomain();
			addCircunference();
			configZoom();
			addExternalInterfaceCallbacks();
			addListeners();
			
			iniciaTutorial();
		}
		
		/**
		 * Configura e adiciona o gráfico.
		 */
		private function configGraph():void 
		{
			graph = new SimpleGraph(g_xmin, g_xmax, g_xsize, g_ymin, g_ymax, g_ysize);
			graph.draw();
			graph.pan = true;
			
			addChild(graph);
			graph.x = 20;
			graph.y = 10;
		}
		
		private var posCircunferenceOnGraph:Point;
		private function initPan(e:Event):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
			graph.addEventListener("endPan", endPan);
		}
		
		private function panning(e:MouseEvent):void 
		{
			var posCircunferenceOnScreen:Point = getGraphPixels(posCircunferenceOnGraph.x, posCircunferenceOnGraph.y);
			circunference.x = posCircunferenceOnScreen.x;
			circunference.y = posCircunferenceOnScreen.y;
			refreshDomain();
		}
		
		private function endPan(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			graph.removeEventListener("endPan", endPan);
		}
		
		private function getGraphPixels(x:Number, y:Number):Point
		{
			return new Point(graph.x2pixel(x) + graph.x, graph.y2pixel(y) + graph.y);
		}
		
		private function getGraphCoords(x:Number, y:Number):Point
		{
			return new Point(graph.pixel2x(x - graph.x), graph.pixel2y(y - graph.y));
		}
		
		private function getGraphRangeX(xmin:Number, xmax:Number):Number
		{
			//return Math.abs(graph.x2pixel(xmax) - graph.x2pixel(xmin));
			return graph.x2pixel(xmax) - graph.x2pixel(xmin);
		}
		
		private function getGraphRangeY(ymin:Number, ymax:Number):Number
		{
			//return Math.abs(graph.y2pixel(ymax) - graph.y2pixel(ymin));
			return graph.y2pixel(ymax) - graph.y2pixel(ymin);
		}
		
		/**
		 * Configura e adiciona o domínio.
		 */
		private function configDomain():void 
		{
			domainSpr = new Sprite();
			addChild(domainSpr);
			setChildIndex(domainSpr, 0);
			
			var grapshCoord:Point = getGraphPixels(d_xini, d_yini);
			domain = new Rectangle(grapshCoord.x, grapshCoord.y, getGraphRangeX(d_xini, d_xend), getGraphRangeY(d_yini, d_yend));
			refreshDomainSpr();
		}
		
		private function refreshDomain():void
		{
			var grapshCoord:Point = getGraphPixels(d_xini, d_yini);
			domain = new Rectangle(grapshCoord.x, grapshCoord.y, getGraphRangeX(d_xini, d_xend), getGraphRangeY(d_yini, d_yend));
			circunference.domain = domain;
			refreshDomainSpr();
		}
		
		private function refreshDomainSpr():void 
		{
			domainSpr.x = domain.x;
			domainSpr.y = domain.y;
			
			domainSpr.graphics.clear();
			domainSpr.graphics.beginFill(0xC0C0C0, 0.5);
			domainSpr.graphics.drawRect(0, 0, domain.width, domain.height);
		}
		
		var zoomSlider:Slider;
		/**
		 * Adiciona a interface do zoom.
		 */
		private function configZoom():void 
		{
			zoomIn = new ZoomIn();
			addChild(zoomIn);
			zoomIn.x = 34;
			zoomIn.y = 20;
			
			zoomOut = new ZoomOut();
			addChild(zoomOut);
			zoomOut.x = 34;
			zoomOut.y = 45;
		}
		
		/**
		 * Adiciona a circunferência no gráfico.
		 */
		private function addCircunference():void 
		{
			circunference = new Circunference();
			addChild(circunference);
			circunference.domain = domain;
			
			var posInicial:Point = getGraphPixels(2, 2);
			circunference.x = posInicial.x;
			circunference.y = posInicial.y;
			posCircunferenceOnGraph = new Point(2, 2);
			
		}
		
		private function refreshCircunferencePos(e:Event):void 
		{
			posCircunferenceOnGraph = getGraphCoords(circunference.x, circunference.y);
		}
		
		/**
		 * Adiciona os ExternalInterfaces para comunicação com o JS.
		 */
		private function addExternalInterfaceCallbacks():void 
		{
			
		}
		
		private var zoomFactor:Number = 0.9;
		private var sliderZoomValue:Number = 1;
		private var zoomTimer:Timer = new Timer(200);
		
		private function zoomInFunc(e:MouseEvent):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			
			var dxLeft:Number = posCircunferenceOnGraph.x - graph.xmin;
			var dxRight:Number = graph.xmax - posCircunferenceOnGraph.x;
			var dyUp:Number = graph.ymax - posCircunferenceOnGraph.y;
			var dyDown:Number = posCircunferenceOnGraph.y - graph.ymin;
			
			var newXmin:Number = posCircunferenceOnGraph.x - (dxLeft * zoomFactor);
			var newXmax:Number = posCircunferenceOnGraph.x + (dxRight * zoomFactor);
			var newYmin:Number = posCircunferenceOnGraph.y - (dyDown * zoomFactor);
			var newYmax:Number = posCircunferenceOnGraph.y + (dyUp * zoomFactor);
			
			graph.setRange(newXmin, newXmax, newYmin, newYmax);
			graph.draw();
			
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			
			if (!zoomTimer.running) {
				zoomTimer.addEventListener(TimerEvent.TIMER, doZoomIn);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopZoom);
				zoomTimer.start();
			}
		}
		
		private function doZoomIn(e:TimerEvent):void 
		{
			zoomInFunc(null);
		}
		
		private function zoomOutFunc(e:MouseEvent):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			
			var dxLeft:Number = posCircunferenceOnGraph.x - graph.xmin;
			var dxRight:Number = graph.xmax - posCircunferenceOnGraph.x;
			var dyUp:Number = graph.ymax - posCircunferenceOnGraph.y;
			var dyDown:Number = posCircunferenceOnGraph.y - graph.ymin;
			
			var newXmin:Number = posCircunferenceOnGraph.x - (dxLeft / zoomFactor);
			var newXmax:Number = posCircunferenceOnGraph.x + (dxRight / zoomFactor);
			var newYmin:Number = posCircunferenceOnGraph.y - (dyDown / zoomFactor);
			var newYmax:Number = posCircunferenceOnGraph.y + (dyUp / zoomFactor);
			
			graph.setRange(newXmin, newXmax, newYmin, newYmax);
			graph.draw();
			
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			
			if (!zoomTimer.running) {
				zoomTimer.addEventListener(TimerEvent.TIMER, doZoomOut);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopZoom);
				zoomTimer.start();
			}
		}
		
		private function doZoomOut(e:TimerEvent):void 
		{
			zoomOutFunc(null);
		}
		
		private function stopZoom(e:MouseEvent):void 
		{
			zoomTimer.stop();
			zoomTimer.reset();
			zoomTimer.removeEventListener(TimerEvent.TIMER, doZoomOut);
			zoomTimer.removeEventListener(TimerEvent.TIMER, doZoomIn);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopZoom);
		}
		
		/**
		 * Adiciona os listeners da atividade.
		 */
		private function addListeners():void 
		{
			zoomIn.addEventListener(MouseEvent.MOUSE_DOWN, zoomInFunc);
			zoomOut.addEventListener(MouseEvent.MOUSE_DOWN, zoomOutFunc);
			
			zoomIn.addEventListener(MouseEvent.MOUSE_OVER, overZoomBtn);
			zoomIn.addEventListener(MouseEvent.MOUSE_OUT, outZoomBtn);
			zoomOut.addEventListener(MouseEvent.MOUSE_OVER, overZoomBtn);
			zoomOut.addEventListener(MouseEvent.MOUSE_OUT, outZoomBtn);
			botoes.addEventListener(MouseEvent.MOUSE_OVER, overZoomBtn);
			botoes.addEventListener(MouseEvent.MOUSE_OUT, outZoomBtn);
			
			circunference.addEventListener("stopDrag", refreshCircunferencePos);
			circunference.addEventListener("mouseHide", mouseHide);
			circunference.addEventListener("mouseShow", mouseShow);
			graph.addEventListener("initPan", initPan);
			//zoomSlider.addEventListener(Event.CHANGE, changeZoomSlider);
		}
		
		private function overZoomBtn(e:MouseEvent):void 
		{
			if (mouseHided) {
				Mouse.show();
			}
		}
		
		private function outZoomBtn(e:MouseEvent):void 
		{
			if (mouseHided) {
				Mouse.hide();
			}
		}
		
		private var mouseHided:Boolean = false;
		private function mouseShow(e:Event):void 
		{
			if(mouseHided){
				mouseHided = false;
				Mouse.show();
			}
		}
		
		private function mouseHide(e:Event):void 
		{
			if(!mouseHided){
				mouseHided = true;
				Mouse.hide();
			}
		}
		
		private function changeZoomSlider(e:Event):void 
		{
			if (zoomSlider.value > sliderZoomValue) {
				sliderZoomValue = zoomSlider.value;
				zoomInFunc(null);
			}else if (zoomSlider.value < sliderZoomValue) {
				sliderZoomValue = zoomSlider.value;
				zoomOutFunc(null);
			}
		}
		
		private function changeInfo(e:MouseEvent):void 
		{
			infoBar.info = "";
		}
		
		
		override public function reset(e:MouseEvent = null):void
		{
			
		}
		
		//---------------- Tutorial -----------------------
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			
		}
		
	}

}