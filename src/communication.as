// ActionScript file
import flash.events.*;
import flash.net.Socket;

private var socket:Socket;
private var server:String = "aladon.sovintel.ru";
private var port:Number = 9000;
private var encodingFormat:String = "koi8-r";
private var colorEnabled:Boolean = true;

public function send(line:String):void{
	var sentLine:String = parseMacros(decolorize(line));
	if(socket){
		socket.writeMultiByte(sentLine+"\n", encodingFormat);
		socket.flush();
		trace("[>>>] "+sentLine);
	} else {
		trace("You are not connected!");
	}
}

public function onReceived(line:String):void{
	var cleanMsg:String = line;
	cleanMsg = cleanMsg.replace(/\r/gm, "");
	cleanMsg = cleanMsg.replace(/</gm, "&lt;");
	cleanMsg = cleanMsg.replace(/>/gm, "&gt;");
	
	var receivedLine:String = parseTriggers(decolorize(cleanMsg));
	if(colorEnabled){
		receivedLine = colorize(cleanMsg);
	}
	mainDisplayArea.addLine(receivedLine);
	trace("[<<<] "+cleanMsg);
}

public function decolorize(line:String):String{
	var cleanMsg:String = line;
	cleanMsg = cleanMsg.replace(/\[[01];3[0-7]m/gm, "");
	cleanMsg = cleanMsg.replace(/\[0m/gm, "");
	return cleanMsg;
}

public function colorize(line:String):String{
	var cleanMsg:String = line;
	cleanMsg = cleanMsg.replace(/\[1;31m/gm, "<font color=\"#FF0000\">");
	cleanMsg = cleanMsg.replace(/\[1;32m/gm, "<font color=\"#00FF00\">");
	cleanMsg = cleanMsg.replace(/\[1;33m/gm, "<font color=\"#FFFF00\">");
	cleanMsg = cleanMsg.replace(/\[1;34m/gm, "<font color=\"#0000FF\">");
	cleanMsg = cleanMsg.replace(/\[1;35m/gm, "<font color=\"#FF00FF\">");
	cleanMsg = cleanMsg.replace(/\[1;36m/gm, "<font color=\"#00FFFF\">");
	cleanMsg = cleanMsg.replace(/\[1;37m/gm, "<font color=\"#FFFFFF\">");
	cleanMsg = cleanMsg.replace(/\[1;30m/gm, "<font color=\"#7F7F7F\">");
	//not so bright
	cleanMsg = cleanMsg.replace(/\[0;31m/gm, "<font color=\"#CD0000\">");
	cleanMsg = cleanMsg.replace(/\[0;32m/gm, "<font color=\"#00CD00\">");
	cleanMsg = cleanMsg.replace(/\[0;33m/gm, "<font color=\"#CDCD00\">");
	cleanMsg = cleanMsg.replace(/\[0;34m/gm, "<font color=\"#0000CD\">");
	cleanMsg = cleanMsg.replace(/\[0;35m/gm, "<font color=\"#CD00CD\">");
	cleanMsg = cleanMsg.replace(/\[0;36m/gm, "<font color=\"#00CDCD\">");
	cleanMsg = cleanMsg.replace(/\[0;37m/gm, "<font color=\"#CDCDCD\">");
	cleanMsg = cleanMsg.replace(/\[0;30m/gm, "<font color=\"#000000\">");
	//close color
	cleanMsg = cleanMsg.replace(/\[0m/gm, "<font color=\"#CDCDCD\">");
	var count:int = cleanMsg.split("<font").length-1;
	for(var i:int = 0;i<count;i++){
		cleanMsg += "</font>";
	}
	return cleanMsg;
}

public function parseTriggers(line:String):String{
	return line;
}

public function parseMacros(line:String):String{
	return line;
}

private function initConnection():void {
	socket = new Socket();
	socket.addEventListener(Event.CONNECT, onConnect);
	socket.addEventListener(Event.CLOSE, onClose);
	socket.addEventListener(ErrorEvent.ERROR, onError);
	socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
	socket.addEventListener(ProgressEvent.SOCKET_DATA, onResponse);
	//Security.allowDomain(server);
	//Security.loadPolicyFile("http://"+server+"/crossdomain.xml");
	try {
		socket.connect(server, port);
		trace("Connecting to "+server+":"+port);
	} catch (error:Error) {
		socket.close();
		trace(error.message);
	}
	
}

private function onConnect(event:Event):void {
	send("1");
	trace("onConnect");	
}
private function onClose(event:Event):void {
	trace("onClose");
	socket = null;
}
private function onError(event:IOErrorEvent):void {
	trace("onError");
}
private function onIOError(event:IOErrorEvent):void {
	trace("onIOError");
}
private function onResponse(event:ProgressEvent):void {
	var string:String = socket.readMultiByte(socket.bytesAvailable, encodingFormat);
	onReceived(string);
}