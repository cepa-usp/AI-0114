package  
{
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public interface IAi 
	{
		//Get e set das propriedades x e y da circunferência, em coordenadas do gráfico.
		function setCircunferenceX(x:Number):void;
		function setCircunferenceY(y:Number):void;
		function getCircunferenceX():Number;
		function getCircunferenceY():Number;
		
		//Get e set do raio da circunferência
		function setDelta(delta:Number):void;
		function getDelta():Number;
		
		//Fixa a posicao da circunferência.
		function lockCircunferenceMove(lock:Boolean):void;
		
		//Fixa delta.
		function lockDeltaChange(value:Boolean):void;
		
		//Define o range do gráfico.
		function setGraphXmin(xmin:Number):void;
		function setGraphXmax(xmax:Number):void;
		function setGraphYmin(ymin:Number):void;
		function setGraphYmax(ymax:Number):void;
		function getGraphXmin():Number;
		function getGraphXmax():Number;
		function getGraphYmin():Number;
		function getGraphYmax():Number;
		
		//Permissão do pan do gráfico.
		function lockGraphPan(lock:Boolean):void;
		
		//Exibir/ocultar a grid
		function gridVisible(value:Boolean):void;
		
		//Travar o zoom
		function lockZoom(lock:Boolean):void;
		
		//Define a área do domínio.
		function setDomainXmin(xmin:Number):void;
		function setDomainXmax(xmax:Number):void;
		function setDomainYmin(ymin:Number):void;
		function setDomainYmax(ymax:Number):void;
		function getDomainXmin():Number;
		function getDomainXmax():Number;
		function getDomainYmin():Number;
		function getDomainYmax():Number;
		
		//Exibe/oculta o domínio da função.
		function domainVisible(visible:Boolean):void
		
		//Configura o domínio aberto ou fechado.
		function openDomain(open:Boolean):void
		
		
	}
	
}