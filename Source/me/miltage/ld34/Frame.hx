package me.miltage.ld34;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.Assets;

class Frame extends Sprite {

	var bmd:BitmapData;
	
	public function new(){
		super();
		bmd = Assets.getBitmapData("assets/frame.png");
		var b:Bitmap = new Bitmap(bmd);
		addChild(b);

		x = 100;
		y = 150;
	}

	public function collides(x:Int, y:Int){
		return bmd.getPixel32(x, y) != 0;
	}
}