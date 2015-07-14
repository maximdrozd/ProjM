// ActionScript file
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.utils.*;

public function keyHandlerDown(event:KeyboardEvent):void {
	for(var i:int = 0; i<hotkeys.length; i++){
		if(event.keyCode == Keyboard[hotkeys[i].key] && !mainInput.hasFocus()){	
			hotkeys[i].activate();
			handleHotkeyAction(hotkeys[i].key);
		}
	}
}

public function keyHandlerUp(event:KeyboardEvent):void {
	for(var i:int = 0; i<hotkeys.length; i++){
		if(event.keyCode == Keyboard[hotkeys[i].key] && !mainInput.hasFocus()){
			hotkeys[i].deactivate();
		}
	}
	if(globalApplicationKeyHandler(event)){
		event.stopImmediatePropagation();
	}
}

public function handleHotkeyAction(key:String):void{
	var s:String = hotkeyBindings[key] as String;
	if(s.substring(0,6) == "call::"){
		var func:String = s.substring(6, s.length);
		if(this[StringUtil.trim(func)]){
			this[StringUtil.trim(func)]();
		}
	} else {
		send(hotkeyBindings[key]);
	}
}

public function globalApplicationKeyHandler(event:KeyboardEvent):Boolean {
	switch(event.keyCode){
		case Keyboard.SLASH:
			if(!mainInput.hasFocus()){
				mainInput.setTextInputFocus();	
			}
			return true;
			break;
		case Keyboard.ESCAPE: 
			if(mainInput.hasFocus()){
				mainInput.unsetTextInputFocus();
				applicationContainer.setFocus();
			}
			break;
		case Keyboard.ENTER:
			if(!mainInput.hasFocus()){
				send(mainInput.textInp.text);
			}
			break;
		default:
			trace(" < "+event.keyCode+" ["+String.fromCharCode(event.keyCode)+"]");
			break;
	}
	return false;
}