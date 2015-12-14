package me.miltage.ld34;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Assets;

import me.miltage.ld34.Button;

class Menu extends Sprite {

	var bmd:BitmapData;
	var menuText:BitmapData;

	public function new(){
		super();
		scaleX = scaleY = 2;

		bmd = new BitmapData(400, 300, true, 0xcc75cdcf);
		var b:Bitmap = new Bitmap(bmd);
		addChild(b);

		menuText = Assets.getBitmapData("assets/menu_text.png");

		var restartButton:Button = new Button(menuText, 0, 0, Main.instance.restart);
		restartButton.y = 40;
		addChild(restartButton);

		var musicButton:Button = new Button(menuText, 64, 128, Main.instance.toggleMusic);
		musicButton.y = 64+40;
		addChild(musicButton);

		var timelapseButton:Button = new Button(menuText, 192, 256, Main.instance.toggleEffects);
		timelapseButton.y = 128+45;
		addChild(timelapseButton);

	}
}