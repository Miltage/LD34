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
	public static var TURN_SPEED:Float = 10;

	var bmd:BitmapData;
	var key:KeyObject;

	var anchors:Array<Anchor>;
	var oldAnchors:Array<Anchor>;
	var constraints:Array<Constraint>;
	var frames:Array<Frame>;
	var angle:Float;
	var count:Int;

	var drawOffset:Int;
	
	public function new(stage:Stage) {
		super();

		key = new KeyObject(stage);

		frames = [];
		var f = new Frame();
		frames.push(f);
		var f2 = new Frame();
		f2.y = 0;
		frames.push(f2);

		bmd = new BitmapData(400, 300, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd);
		b.scaleX = b.scaleY = 2;
		addChild(b);

		oldAnchors = [];
		anchors = [];
		for(i in 0...2){
			var a = new Anchor(200, 280);
			anchors.push(a);
		}
		anchors[0].anchored = true;

		constraints = [];
		for(i in 1...anchors.length){
			var c = new Constraint(anchors[i-1], anchors[i], 0);
			constraints.push(c);
		}

		angle = 180;
		count = 0;
		drawOffset = 0;

		addEventListener(Event.ENTER_FRAME, tick);
	}

	public function tick(e:Event){
		bmd.fillRect(bmd.rect, 0x00000000);
		bmd.fillRect(new flash.geom.Rectangle(0, 0, 120, 300), 0xff4455cc);
		bmd.fillRect(new flash.geom.Rectangle(280, 0, 120, 300), 0xff4455cc);
		for(frame in frames){
			bmd.draw(frame, new openfl.geom.Matrix(1, 0, 0, 1, frame.x, frame.y+drawOffset));
		}

		var lastAnchor:Anchor = anchors[anchors.length-1];
		if(key.isDown(KeyObject.LEFT) || key.isDown(KeyObject.A)){
			angle-=TURN_SPEED;
		}
		if(key.isDown(KeyObject.RIGHT) || key.isDown(KeyObject.D)){
			angle+=TURN_SPEED;
		}
		var radians = angle * Math.PI / 180;
		var dx = Math.cos(radians);
		var dy = Math.sin(radians);
		lastAnchor.r.x += dx*MOVE_SPEED;
		lastAnchor.r.y += dy*MOVE_SPEED;

		var lastConstraint = constraints[constraints.length-1];
		lastConstraint.setLength(lastConstraint.getLength()+1);

		var gravity = new Point(0, 0.1+0.006*anchors.length); 

		for(anchor in anchors){
			anchor.forces.push(gravity);
			anchor.update();
			if(anchor.r.y > 280) anchor.r.y = 280;
			if(anchor.r.x < 120) anchor.r.x = 120;
			else if(anchor.r.x > 280) anchor.r.x = 280;
			GraphicsUtil.drawCircle(bmd, anchor.r.x, anchor.r.y+drawOffset, 2, 0xffff3333, true);
		}

		for(anchor in oldAnchors){
			anchor.forces.push(gravity);
			anchor.update();
		}

		for(constraint in constraints){
			constraint.update();
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y+drawOffset, constraint.b.r.x, constraint.b.r.y+drawOffset, 0xffff3333);
		}

		for(frame in frames){
			if(frame.collides(Std.int(lastAnchor.r.x-frame.x), Std.int(lastAnchor.r.y-frame.y))){
				lastAnchor.anchored = true;
				oldAnchors = oldAnchors.concat(anchors);
				anchors = [];
			}
		}

		if(lastAnchor.r.y < 100) drawOffset++;

		count++;
		if(count % 10 == 0 || lastAnchor.anchored){
			var a = new Anchor(lastAnchor.r.x, lastAnchor.r.y);
			anchors.push(a);
			
			var c = new Constraint(lastAnchor, a, 0);
			constraints.push(c);
		}
	}
}