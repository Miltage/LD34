package me.miltage.ld34;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.Assets;

class Frame extends Sprite {

	var bmd:BitmapData;
	
	public function new(asset:String){
		super();
		bmd = Assets.getBitmapData("assets/"+asset);
		var b:Bitmap = new Bitmap(bmd);
		addChild(b);
	}

	public function collides(x:Int, y:Int){
		if(scaleX < 0) x += bmd.width;
		return bmd.getPixel32(scaleX<0?bmd.width-x:x, y) != 0;
	}
}