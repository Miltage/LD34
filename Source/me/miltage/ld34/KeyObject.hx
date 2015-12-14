package me.miltage.ld34;

import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class KeyObject {

	private static var stage:Stage;
	private static var keysDown:Dynamic;
	private static var nextStates:Dynamic;

	public static var UP:UInt = Keyboard.UP;
	public static var DOWN:UInt = Keyboard.DOWN;
	public static var LEFT:UInt = Keyboard.LEFT;
	public static var RIGHT:UInt = Keyboard.RIGHT;
	public static var W:UInt = Keyboard.W;
	public static var A:UInt = Keyboard.A;
	public static var S:UInt = Keyboard.S;
	public static var D:UInt = Keyboard.D;
	public static var Z:UInt = Keyboard.Z;
	public static var X:UInt = Keyboard.X;
	public static var C:UInt = Keyboard.C;
	public static var SPACE:UInt = Keyboard.SPACE;
	public static var ESCAPE:UInt = Keyboard.ESCAPE;
	public static var NUMPAD_0:UInt = Keyboard.NUMPAD_0;
	public static var NUMPAD_1:UInt = Keyboard.NUMPAD_1;
	public static var NUMPAD_2:UInt = Keyboard.NUMPAD_2;
	public static var NUMPAD_3:UInt = Keyboard.NUMPAD_3;
	public static var NUMPAD_4:UInt = Keyboard.NUMPAD_4;
	public static var NUMPAD_5:UInt = Keyboard.NUMPAD_5;
	public static var NUMPAD_6:UInt = Keyboard.NUMPAD_6;
	public static var NUMPAD_7:UInt = Keyboard.NUMPAD_7;
	public static var NUMPAD_8:UInt = Keyboard.NUMPAD_8;
	public static var NUMPAD_9:UInt = Keyboard.NUMPAD_9;

	public function new(stage:Stage) {
		construct(stage);
	}
	
	public function construct(stage:Stage) {
		KeyObject.stage = stage;
		keysDown = new Array();
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
	}

	public function isDown(keyCode:UInt):Bool {
		return keysDown[keyCode];
	}

	private function keyPressed(evt:KeyboardEvent) {
		keysDown[evt.keyCode] = true;
	}
	
	private function keyReleased(evt:KeyboardEvent) {
		keysDown[evt.keyCode] = false;
	}
}