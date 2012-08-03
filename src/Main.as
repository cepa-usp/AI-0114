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
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain implements IAi
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
		private var g_ysize:int = 465;
		private var g_ymin:Number = -1;
		private var g_ymax:Number;
		
		/**
		 * Área do domínio do gráfico.
		 */
		private var domain:Rectangle;
		private var domainSpr:Sprite;
		private var domainGlowBorder:Sprite;
		
		//Configuração inicial do domínio.
		private var d_xini:Number = 0;
		private var d_xend:Number = 6;
		private var d_yini:Number = 0;
		private var d_yend:Number = 3;
		
		private var inicialConfigDomain:Array = [0, 6, 0, 3];
		private var inicialCircunferencePos:Point = new Point(2, 2);
		private var inicialDelta:Number = 1;
		
		//Botões de zoom.
		private var zoomIn:ZoomIn;
		private var zoomOut:ZoomOut;
		
		override protected function init():void 
		{
			var xscale:Number = g_xsize / (g_xmax - g_ymin);
			g_ymax = (g_ysize / xscale) + g_ymin;
			
			configGraph();
			configDomain();
			addCircunference();
			configZoom();
			addListeners();
			
			iniciaTutorial();
			addExternalInterfaceCallbacks();
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
			panning(null);
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
			
			domainGlowBorder = new Sprite();
			addChild(domainGlowBorder);
			domainGlowBorder.filters = [new GlowFilter(0xFF0000)];
			setChildIndex(domainGlowBorder, 0);
			
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
			refresDomainGlowBorder();
		}
		
		private function refreshDomainSpr():void 
		{
			domainSpr.x = domain.x;
			domainSpr.y = domain.y;
			
			domainSpr.graphics.clear();
			domainSpr.graphics.beginFill(0xC0C0C0, 0.5);
			domainSpr.graphics.drawRect(0, 0, domain.width, domain.height);
		}
		
		private function refresDomainGlowBorder():void
		{
			domainGlowBorder.graphics.clear();
			
			if (circunference.onBorderX || circunference.onBorderY) {
				domainGlowBorder.graphics.lineStyle(1, 0xFF8080);
				switch(circunference.borderPosition){
					case Circunference.LEFT:
						domainGlowBorder.graphics.moveTo(domain.x, domain.y);
						domainGlowBorder.graphics.lineTo(domain.x, domain.y + domain.height);
						break;
					case Circunference.RIGHT:
						domainGlowBorder.graphics.moveTo(domain.x + domain.width, domain.y);
						domainGlowBorder.graphics.lineTo(domain.x + domain.width, domain.y + domain.height);
						break;
					case Circunference.TOP:
						domainGlowBorder.graphics.moveTo(domain.x, domain.y);
						domainGlowBorder.graphics.lineTo(domain.x + domain.width, domain.y);
						break;
					case Circunference.DOWN:
						domainGlowBorder.graphics.moveTo(domain.x, domain.y + domain.height);
						domainGlowBorder.graphics.lineTo(domain.x + domain.width, domain.y + domain.height);
						break;
					
				}
			}
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
			
			var posInicial:Point = getGraphPixels(inicialCircunferencePos.x, inicialCircunferencePos.y);
			circunference.x = posInicial.x;
			circunference.y = posInicial.y;
			posCircunferenceOnGraph = new Point(inicialCircunferencePos.x, inicialCircunferencePos.y);
			
			setDelta(1);
		}
		
		private function initDaggCircunference(e:Event):void 
		{
			circunference.addEventListener("stopDrag", refreshCircunferencePos);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, draggingCircunference);
		}
		
		private function draggingCircunference(e:MouseEvent):void 
		{
			posCircunferenceOnGraph = getGraphCoords(circunference.x, circunference.y);
			refresDomainGlowBorder();
		}
		
		private function refreshCircunferencePos(e:Event):void 
		{
			circunference.removeEventListener("stopDrag", refreshCircunferencePos);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggingCircunference);
			posCircunferenceOnGraph = getGraphCoords(circunference.x, circunference.y);
		}
		
		private function refreshCircunferenceOnGraph():void 
		{
			var posPixels:Point = getGraphPixels(posCircunferenceOnGraph.x, posCircunferenceOnGraph.y);
			circunference.x = posPixels.x;
			circunference.y = posPixels.y;
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
			
			circunference.addEventListener("initDrag", initDaggCircunference);
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
			graph.setRange(g_xmin, g_xmax, g_ymin, g_ymax);
			graph.draw();
			
			d_xini = inicialConfigDomain[0];
			d_xend = inicialConfigDomain[1];
			d_yini = inicialConfigDomain[2];
			d_yend = inicialConfigDomain[3];
			refreshDomain();
			
			var posInicial:Point = getGraphPixels(inicialCircunferencePos.x, inicialCircunferencePos.y);
			circunference.x = posInicial.x;
			circunference.y = posInicial.y;
			posCircunferenceOnGraph = new Point(inicialCircunferencePos.x, inicialCircunferencePos.y);
			
			setDelta(1);
		}
		
		//---------------- Tutorial ---------------------------------
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			
		}
		
		//---------------- Fim tutorial ------------------------------
		
		/**
		 * Adiciona os ExternalInterfaces para comunicação com o JS.
		 */
		private function addExternalInterfaceCallbacks():void 
		{
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("setCircunferenceX", setCircunferenceX);
				ExternalInterface.addCallback("getCircunferenceX", getCircunferenceX);
				ExternalInterface.addCallback("setCircunferenceY", setCircunferenceY);
				ExternalInterface.addCallback("getCircunferenceY", getCircunferenceY);
				ExternalInterface.addCallback("setDelta", setDelta);
				ExternalInterface.addCallback("getDelta", getDelta);
				ExternalInterface.addCallback("lockCircunferenceMove", lockCircunferenceMove);
				ExternalInterface.addCallback("lockDeltaChange", lockDeltaChange);
				ExternalInterface.addCallback("setGraphXmin", setGraphXmin);
				ExternalInterface.addCallback("setGraphXmax", setGraphXmax);
				ExternalInterface.addCallback("setGraphYmin", setGraphYmin);
				ExternalInterface.addCallback("setGraphYmax", setGraphYmax);
				ExternalInterface.addCallback("getGraphXmin", getGraphXmin);
				ExternalInterface.addCallback("getGraphXmax", getGraphXmax);
				ExternalInterface.addCallback("getGraphYmin", getGraphYmin);
				ExternalInterface.addCallback("getGraphYmax", getGraphYmax);
				ExternalInterface.addCallback("lockGraphPan", lockGraphPan);
				ExternalInterface.addCallback("gridVisible", gridVisible);
				ExternalInterface.addCallback("lockZoom", lockZoom);
				ExternalInterface.addCallback("domainVisible", domainVisible);
				ExternalInterface.addCallback("openDomain", openDomain);
				ExternalInterface.addCallback("setDomainXmin", setDomainXmin);
				ExternalInterface.addCallback("setDomainXmax", setDomainXmax);
				ExternalInterface.addCallback("setDomainYmin", setDomainYmin);
				ExternalInterface.addCallback("setDomainYmax", setDomainYmax);
				ExternalInterface.addCallback("getDomainXmin", getDomainXmin);
				ExternalInterface.addCallback("getDomainXmax", getDomainXmax);
				ExternalInterface.addCallback("getDomainYmin", getDomainYmin);
				ExternalInterface.addCallback("getDomainYmax", getDomainYmax);
				ExternalInterface.addCallback("insideDomain", insideDomain);
				ExternalInterface.addCallback("onBorder", onBorder);
				ExternalInterface.addCallback("reset", reset);
			}
		}
		
		/* INTERFACE IAi */
		
		public function onBorder():Boolean 
		{
			if (circunference.onBorderX || circunference.onBorderY) return true;
			else return false;
		}
		
		public function setCircunferenceX(value:Number):void 
		{
			circunference.x = graph.x2pixel(value) + graph.x;
			posCircunferenceOnGraph.x = value;
		}
		
		public function setCircunferenceY(value:Number):void 
		{
			circunference.y = graph.y2pixel(value) + graph.y;
			posCircunferenceOnGraph.y = value;
		}
		
		public function getCircunferenceX():Number 
		{
			return posCircunferenceOnGraph.x;
		}
		
		public function getCircunferenceY():Number 
		{
			return posCircunferenceOnGraph.y;
		}
		
		public function setDelta(value:Number):void 
		{
			circunference.setDelta(getGraphRangeX(0, value));
		}
		
		public function getDelta():Number 
		{
			return graph.pixel2x(circunference.x + Math.abs(circunference.getDelta())) - graph.pixel2x(circunference.x);
		}
		
		public function lockCircunferenceMove(value:Boolean):void 
		{
			circunference.moveLock = value;
		}
		
		public function lockDeltaChange(value:Boolean):void 
		{
			circunference.resizeLock = value;
		}
		
		public function setGraphXmin(value:Number):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			graph.xmin = value;
			graph.draw();
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			refreshCircunferenceOnGraph();
		}
		
		public function setGraphXmax(value:Number):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			graph.xmax = value;
			graph.draw();
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			refreshCircunferenceOnGraph();
		}
		
		public function setGraphYmin(value:Number):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			graph.ymin = value;
			graph.draw();
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			refreshCircunferenceOnGraph();
		}
		
		public function setGraphYmax(value:Number):void 
		{
			var raioCircunferenceOnGraph:Number = getGraphCoords(circunference.x + circunference.getDelta(), circunference.y).x - posCircunferenceOnGraph.x;
			graph.ymax = value;
			graph.draw();
			var newCircunferenceRadius:Number = getGraphRangeX(posCircunferenceOnGraph.x, posCircunferenceOnGraph.x + raioCircunferenceOnGraph);
			circunference.setDelta(newCircunferenceRadius);
			refreshDomain();
			refreshCircunferenceOnGraph();
		}
		
		public function getGraphXmin():Number 
		{
			return graph.xmin;
		}
		
		public function getGraphXmax():Number 
		{
			return graph.xmax;
		}
		
		public function getGraphYmin():Number 
		{
			return graph.ymin;
		}
		
		public function getGraphYmax():Number 
		{
			return graph.ymax;
		}
		
		public function lockGraphPan(value:Boolean):void 
		{
			graph.pan = !value;
		}
		
		public function gridVisible(value:Boolean):void 
		{
			graph.grid = value;
			graph.draw();
		}
		
		public function lockZoom(value:Boolean):void 
		{
			zoomIn.mouseEnabled = value;
			zoomOut.mouseEnabled = value;
		}
		
		public function setDomainXmin(value:Number):void 
		{
			d_xini = value;
			refreshDomain();
		}
		
		public function setDomainXmax(value:Number):void 
		{
			d_xend = value;
			refreshDomain();
		}
		
		public function setDomainYmin(value:Number):void 
		{
			d_yini = value;
			refreshDomain();
		}
		
		public function setDomainYmax(value:Number):void 
		{
			d_yend = value;
			refreshDomain();
		}
		
		public function getDomainXmin():Number 
		{
			return d_xini;
		}
		
		public function getDomainXmax():Number 
		{
			return d_xend;
		}
		
		public function getDomainYmin():Number 
		{
			return d_yini;
		}
		
		public function getDomainYmax():Number 
		{
			return d_yend;
		}
		
		public function domainVisible(value:Boolean):void 
		{
			domainSpr.visible = value;
		}
		
		public function openDomain(value:Boolean):void 
		{
			circunference.openDomain = value;
		}
		
		private function insideDomain():Boolean 
		{
			if (circunference.openDomain) {
				if (posCircunferenceOnGraph.x > d_xini && posCircunferenceOnGraph.x < d_xend &&
					posCircunferenceOnGraph.y > d_yini && posCircunferenceOnGraph.y < d_yend) return true;
				else return false;
			}else {
				if (posCircunferenceOnGraph.x >= d_xini && posCircunferenceOnGraph.x <= d_xend &&
					posCircunferenceOnGraph.y >= d_yini && posCircunferenceOnGraph.y <= d_yend) return true;
				else return false;
			}
		}
		
	}

}