package me.miltage.ld34;

import flash.display.Stage;
import me.miltage.ld34.KeyObject;
import me.miltage.ld34.physics.Constraint;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;

import me.miltage.ld34.physics.Anchor;
import openfl.geom.Point;

class Game extends Sprite {

	public static var MOVE_SPEED:Float = 2;
	public static var TURN_SPEED:Float = 5;

	var bmd:BitmapData;
	var key:KeyObject;

	var anchors:Array<Anchor>;
	var constraints:Array<Constraint>;
	var angle:Float;
	var count:Int;
	
	public function new(stage:Stage) {
		super();

		key = new KeyObject(stage);

		bmd = new BitmapData(800, 600, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd);
		addChild(b);

		anchors = [];
		for(i in 0...2){
			var a = new Anchor(Math.random()*800, Math.random()*600);
			anchors.push(a);
		}
		anchors[0].r.x = 400;
		anchors[0].r.y = 580;
		anchors[0].anchored = true;

		constraints = [];
		for(i in 1...anchors.length){
			var c = new Constraint(anchors[i-1], anchors[i], 0);
			constraints.push(c);
		}

		angle = 180;
		count = 0;

		addEventListener(Event.ENTER_FRAME, tick);
	}

	public function tick(e:Event){
		bmd.fillRect(bmd.rect, 0x00000000);

		var lastAnchor:Anchor = anchors[anchors.length-1];
		if(key.isDown(KeyObject.LEFT)){
			angle-=TURN_SPEED;
		}
		if(key.isDown(KeyObject.RIGHT)){
			angle+=TURN_SPEED;
		}
		var radians = angle * Math.PI / 180;
		var dx = Math.cos(radians);
		var dy = Math.sin(radians);
		lastAnchor.r.x += dx*MOVE_SPEED;
		lastAnchor.r.y += dy*MOVE_SPEED;

		var lastConstraint = constraints[constraints.length-1];
		lastConstraint.setLength(lastConstraint.getLength()+1);

		for(anchor in anchors){
			anchor.forces.push(new Point(0, 0.15+0.01*anchors.length));
			anchor.update();
			if(anchor.r.y > 580) anchor.r.y = 580;
			GraphicsUtil.drawCircle(bmd, anchor.r.x, anchor.r.y, 3, 0xffff3333, true);
		}

		for(constraint in constraints){
			constraint.update();
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y, constraint.b.r.x, constraint.b.r.y, 0xffff3333);
		}

		count++;
		if(count % 25 == 0){
			var a = new Anchor(lastAnchor.r.x, lastAnchor.r.y);
			anchors.push(a);
			
			var c = new Constraint(lastAnchor, a, 0);
			constraints.push(c);
		}
	}
}