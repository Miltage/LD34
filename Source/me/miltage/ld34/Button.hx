package me.miltage.ld34;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.geom.ColorTransform;

class Button extends Sprite {

	var normal_y:Int;
	var toggled_y:Int;

	var callback:Void->Void;
	var state:Int = 0;

	var bmd2:BitmapData;
	var bmd:BitmapData;

	public function new(bmd:BitmapData, normal:Int, toggled:Int, cb:Void->Void){
		super();

		this.bmd = bmd;
		bmd2 = new BitmapData(400, 64, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd2);
		addChild(b);

		buttonMode = true;
		normal_y = normal;
		toggled_y = toggled;
		callback = cb;

		draw();

		addEventListener(MouseEvent.ROLL_OVER, over);
		addEventListener(MouseEvent.ROLL_OUT, out);
		addEventListener(MouseEvent.MOUSE_DOWN, down);
		addEventListener(MouseEvent.MOUSE_UP, up);
	}

	private function draw(){
		bmd2.fillRect(bmd2.rect, 0x00000000);
		bmd2.copyPixels(bmd, new Rectangle(0, state==1?toggled_y:normal_y, 400, 64), new Point(), null, null, true);
	}

	private function over(m:MouseEvent){
		transform.colorTransform = new ColorTransform(62/255, 142/255, 128/255, 1);
	}

	private function out(m:MouseEvent){
		transform.colorTransform = new ColorTransform(1, 1, 1, 1);
	}

	private function down(m:MouseEvent){
		transform.colorTransform = new ColorTransform(22/255, 57/255, 51/255, 1);
	}

	private function up(m:MouseEvent){
		transform.colorTransform = new ColorTransform(62/255, 142/255, 128/255, 1);
		state = 1-state;
		draw();
		callback();
	}
	
}