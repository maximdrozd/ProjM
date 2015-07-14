// Socket related functions
import flash.events.MouseEvent;

private var globalStringCount:int = 0; //counts how many server strings we hold in log window
private var globalStringCountMax:int = 150; //how many server strings we can hold in log window
private var server:String = "neronis.ru";
private var port:Number = 9000;
private var encodingFormat:String = "koi8-r"; //default encoding, TODO: add client change option
private var colorEnabled:Boolean = true; //display colors, TODO: add client toggle option
private var socket:Socket;

private var WC_MRK:String = String.fromCharCode(20);
private var patternRoom:RegExp = new RegExp(WC_MRK+String.fromCharCode(21)+"(.+?)"+WC_MRK); //room name
private var patternRoomImg:RegExp = new RegExp(WC_MRK+String.fromCharCode(23)+"(.+?)"+WC_MRK); //room image
private var patternHMV:RegExp = new RegExp(WC_MRK+String.fromCharCode(24)+"(.+?)"+WC_MRK); //HMV
private var patternAlign:RegExp = new RegExp(WC_MRK+String.fromCharCode(25)+"(.+?)"+WC_MRK); //alignment
private var patternDSU:RegExp = new RegExp(WC_MRK+String.fromCharCode(26)+"(.+?)"+WC_MRK); //DSU
private var patternXPL:RegExp = new RegExp(WC_MRK+String.fromCharCode(31)+"(.+?)"+WC_MRK); //exp-per-lvl
private var patternName:RegExp = new RegExp(WC_MRK+String.fromCharCode(27)+"(.+?)"+WC_MRK); //name
private var patternRC:RegExp = new RegExp(WC_MRK+String.fromCharCode(28)+"(.+?)"+WC_MRK); //race-class
private var patternLvl:RegExp = new RegExp(WC_MRK+String.fromCharCode(29)+"(.+?)"+WC_MRK); //lvl
private var patternAva:RegExp = new RegExp(WC_MRK+String.fromCharCode(30)+"(.+?)"+WC_MRK); //avatar
private var patternHint:RegExp = new RegExp(WC_MRK+String.fromCharCode(32)+"(.+)"+WC_MRK, "gms"); //hint

private function init_connection(event:MouseEvent):void {
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
        outMessage("Trying to connect to "+server+":"+port);
    } catch (error:Error) {
        socket.close();
        outMessage(error.message);
    }
    
}

private function close_connection(event:MouseEvent):void{
	socket.close();
	outMessage("Connection terminated by user...");
}

public function send(string:String):void {
    socket.writeMultiByte(string+"\n", encodingFormat);
    socket.flush();
}
private function onConnect(event:Event):void {
    outMessage("Connected to "+server+":"+port);
    send("1ЪЩWEB");
}
private function onClose(event:Event):void {
    outMessage("Connection closed");
}
private function onError(event:IOErrorEvent):void {
    outMessage("Connection error");
}
private function onIOError(event:IOErrorEvent):void {
    outMessage("I/O error");
}
private function onResponse(event:ProgressEvent):void {
    var string:String = socket.readMultiByte(socket.bytesAvailable, encodingFormat);
    outMessage(string);
}
public function outMessage(msg:String):void {
	var cleanMsg:String = msg;
	cleanMsg = cleanMsg.replace(/\r/gm, "");
	
	cleanMsg = cleanMsg.replace(/</gm, "&lt;");
	cleanMsg = cleanMsg.replace(/>/gm, "&gt;");
	
	//xterm color support
	if(colorEnabled){
		//bright
		//TODO: Ideally - colors will also be set by user via client
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
	} else {
		//even if in-game color is set - override and remove it  
		cleanMsg = cleanMsg.replace(/\[[01];3[0-7]m/gm, "");
		cleanMsg = cleanMsg.replace(/\[0m/gm, "");
	}
	
	//WebPrompt detection
	var specAr:Array = new Array();
	
	if(cleanMsg.search(patternRoom) != -1){
		cleanMsg = cleanMsg.replace(patternRoom, "");
	}
	if(cleanMsg.search(patternRoomImg) != -1){
		cleanMsg = cleanMsg.replace(patternRoomImg, "");
	}
	if(cleanMsg.search(patternHMV) != -1){
		specAr = patternHMV.exec(cleanMsg);
		cleanMsg = cleanMsg.replace(patternHMV, "");
		updateBars(specAr[1]);
	}
	if(cleanMsg.search(patternAlign) != -1){
		cleanMsg = cleanMsg.replace(patternAlign, "");
	}
	if(cleanMsg.search(patternDSU) != -1){
		cleanMsg = cleanMsg.replace(patternDSU, "");
	}
	if(cleanMsg.search(patternXPL) != -1){
		cleanMsg = cleanMsg.replace(patternXPL, "");
	}
	if(cleanMsg.search(patternName) != -1){
		cleanMsg = cleanMsg.replace(patternName, "");
	}
	if(cleanMsg.search(patternRC) != -1){
		cleanMsg = cleanMsg.replace(patternRC, "");
	}
	if(cleanMsg.search(patternLvl) != -1){
		cleanMsg = cleanMsg.replace(patternLvl, "");
	}
	if(cleanMsg.search(patternAva) != -1){
		specAr = patternAva.exec(cleanMsg);
		cleanMsg = cleanMsg.replace(patternAva, "");
		avatar.source = "http://neronis.ru/webclient/pics/avatars/"+specAr[1];
	}
	if(cleanMsg.search(patternHint) != -1){
		cleanMsg = cleanMsg.replace(patternHint, "");
	}
	//Output - needs modifications
	if(globalStringCount < globalStringCountMax){
    	log.htmlText += cleanMsg;
    	globalStringCount++;
 	} else {
 		log.htmlText = cleanMsg;
    	globalStringCount = 0;
 	}
}