package me.miltage.ld34;

import me.miltage.ld34.physics.Constraint;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;

import me.miltage.ld34.physics.Anchor;
import openfl.geom.Point;

class Game extends Sprite {

	var bmd:BitmapData;
	var anchors:Array<Anchor>;
	var constraints:Array<Constraint>;
	
	public function new() {
		super();

		bmd = new BitmapData(800, 600, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd);
		addChild(b);

		anchors = [];
		for(i in 0...10){
			var a = new Anchor(Math.random()*800, Math.random()*600);
			anchors.push(a);
		}
		anchors[0].anchored = true;

		constraints = [];
		for(i in 1...10){
			var c = new Constraint(anchors[i-1], anchors[i], 25);
			constraints.push(c);
		}

		addEventListener(Event.ENTER_FRAME, tick);
	}

	public function tick(e:Event){
		bmd.fillRect(bmd.rect, 0x00000000);
		for(anchor in anchors){
			anchor.forces.push(new Point(0, 1));
			anchor.update();
			if(anchor.r.y > 580) anchor.r.y = 580;
			GraphicsUtil.drawCircle(bmd, anchor.r.x, anchor.r.y, 3, 0xffff3333, true);
		}

		for(constraint in constraints){
			constraint.update();
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y, constraint.b.r.x, constraint.b.r.y, 0xffff3333);
		}
	}
}