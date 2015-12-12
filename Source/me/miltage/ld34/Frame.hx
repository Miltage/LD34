package me.miltage.ld34;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class Frame extends Sprite {

	var bmd:BitmapData;
	var b:Bitmap;
	
	public function new(asset:String){
		super();
		bmd = Assets.getBitmapData("assets/"+asset);
		b = new Bitmap(bmd);
		addChild(b);
	}

	public function setRect(rect:Rectangle){
		var bmd = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x00000000);
		bmd.copyPixels(this.bmd, rect, new Point(0, 0));
		this.bmd = bmd;
		removeChild(b);
		b = new Bitmap(bmd);
		addChild(b);
	}

	public function collides(x:Int, y:Int){
		if(scaleX < 0) x += bmd.width;
		return bmd.getPixel32(scaleX<0?bmd.width-x:x, y) != 0;
	}
}