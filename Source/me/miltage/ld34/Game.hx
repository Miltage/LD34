package me.miltage.ld34;

import openfl.display.Stage;
import me.miltage.ld34.KeyObject;
import me.miltage.ld34.physics.Constraint;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;

import me.miltage.ld34.physics.Anchor;
import openfl.geom.Point;
import openfl.geom.Rectangle;

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
	var walls:BitmapData;
	var backWalls:BitmapData;
	var street:BitmapData;
	
	public function new(stage:Stage) {
		super();

		key = new KeyObject(stage);

		frames = [];
		var f = new Frame("street_frame.png");
		frames.push(f);

		bmd = new BitmapData(400, 300, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd);
		b.scaleX = b.scaleY = 2;
		addChild(b);

		walls = Assets.getBitmapData("assets/walls.png");
		backWalls = Assets.getBitmapData("assets/background.png");
		street = Assets.getBitmapData("assets/street.png");
		setupWalls();

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

		angle = 270;
		count = 0;
		drawOffset = 0;

		addEventListener(Event.ENTER_FRAME, tick);
	}

	public function tick(e:Event){
		bmd.fillRect(bmd.rect, 0x00000000);
		// repeat back wall
		var bwp:Int = Std.int(drawOffset/2-8*Math.floor(drawOffset/16));
		bmd.copyPixels(backWalls, new Rectangle(0, 0, backWalls.width, 148), new Point(0, bwp-8));
		bmd.copyPixels(backWalls, new Rectangle(0, 0, backWalls.width, 148), new Point(0, bwp+64));
		bmd.copyPixels(backWalls, new Rectangle(0, 0, backWalls.width, 148), new Point(0, bwp+152));
		bmd.draw(backWalls, new openfl.geom.Matrix(1, 0, 0, 1, 0, Std.int(drawOffset/2)));
		// end back wall
		bmd.draw(street, new openfl.geom.Matrix(1, 0, 0, 1, 0, drawOffset));
		drawWalls();

		// draw background vines
		for(constraint in constraints){
			//constraint.update();
			if(constraint.b.position == 0) continue;
			var diff = constraint.b.r.subtract(constraint.a.r);
			diff.normalize(1);
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y+drawOffset, constraint.b.r.x+diff.x, constraint.b.r.y+diff.y+drawOffset, 0xff5ea55d);
		}

		// draw background leaves
		for(anchor in anchors.concat(oldAnchors)){
			if(anchor.position == 1)
				anchor.drawLeaf(bmd, drawOffset);
		}

		for(object in wallObjects){
			bmd.draw(object, new openfl.geom.Matrix(object.scaleX, 0, 0, 1, object.x, object.y+drawOffset));
		}
		for(frame in frames){
			//bmd.draw(frame, new openfl.geom.Matrix(frame.scaleX, 0, 0, 1, frame.x, frame.y+drawOffset), new openfl.geom.ColorTransform(0, 0, 1, 1, 1, 1, 1, 1));
		}

		var lastAnchor:Anchor = anchors[anchors.length-1];
		if(key.isDown(KeyObject.LEFT) || key.isDown(KeyObject.A)){
			angle-=TURN_SPEED;
		}
		if(key.isDown(KeyObject.RIGHT) || key.isDown(KeyObject.D)){
			angle+=TURN_SPEED;
		}
		angle += Math.random()*10-5;
		var radians = angle * Math.PI / 180;
		var dx = Math.cos(radians);
		var dy = Math.sin(radians);
		lastAnchor.r.x += dx*MOVE_SPEED;
		lastAnchor.r.y += dy*MOVE_SPEED;

		var lastConstraint = constraints[constraints.length-1];
		lastConstraint.setLength(lastConstraint.getLength()+1);

		var gravity = new Point(0, 0.1+0.006*anchors.length);

		// update new anchors
		for(anchor in anchors){
			anchor.forces.push(gravity);
			anchor.update();
			if(anchor.r.y > 280) anchor.r.y = 280;
			if(anchor.r.x < 120) anchor.r.x = 120;
			else if(anchor.r.x > 280) anchor.r.x = 280;
			//GraphicsUtil.drawCircle(bmd, anchor.r.x, anchor.r.y+drawOffset, 2, 0xff61a45a, true);
		}

		// update old anchors - can't forget about them!
		for(anchor in oldAnchors){
			if(anchor.r.y > 400) continue;
			if(anchor.r.y > 280) anchor.r.y = 280;
			if(anchor.r.x < 120) anchor.r.x = 120;
			else if(anchor.r.x > 280) anchor.r.x = 280;
			anchor.forces.push(gravity);
			anchor.update();
		}

		// draw foreground vines
		for(constraint in constraints){
			constraint.update();
			if(constraint.b.position == 1) continue;
			var diff = constraint.b.r.subtract(constraint.a.r);
			diff.normalize(1);
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y+drawOffset, constraint.b.r.x+diff.x, constraint.b.r.y+diff.y+drawOffset, 0xff5ea55d);
		}

		// draw foreground leaves
		for(anchor in anchors.concat(oldAnchors)){
			if(anchor.position == 0)
				anchor.drawLeaf(bmd, drawOffset);
		}

		// check collision between vine and objects in alley
		for(frame in frames){
			if(frame.collides(Std.int(lastAnchor.r.x-frame.x), Std.int(lastAnchor.r.y-frame.y))){
				lastAnchor.anchored = true;
				lastAnchor.position = 1-lastAnchor.position;
				oldAnchors = oldAnchors.concat(anchors);
				anchors = [];
			}
		}

		drawOffset = Std.int(150-lastAnchor.r.y);
		if(drawOffset < 0) drawOffset = 0;

		count++;
		if(count % 10 == 0 || lastAnchor.anchored){
			var a = new Anchor(lastAnchor.r.x, lastAnchor.r.y);
			a.position = lastAnchor.position;
			anchors.push(a);
			
			var c = new Constraint(lastAnchor, a, 0);
			constraints.push(c);
		}
	}

	var wallBricksLeft:Rectangle;
	var wallWindowsLeft:Rectangle;
	var wallBricksRight:Rectangle;
	var wallWindowsRight:Rectangle;
	var wallPosters:Rectangle;
	private function setupWalls(){
		wallBricksLeft = new Rectangle(0, 0, walls.width/2, 72);
		wallWindowsLeft = new Rectangle(0, 78, walls.width/2, 72);
		wallBricksRight = new Rectangle(walls.width/2, 0, walls.width/2, 72);
		wallWindowsRight = new Rectangle(walls.width/2, 78, walls.width/2, 72);
		wallPosters = new Rectangle(0, 204, walls.width, 85);
		wallOrderLeft = [];
		wallOrderRight = [];
		wallObjects = [];
		generateWall();
	}

	var wallOrderLeft:Array<Int>;
	var wallOrderRight:Array<Int>;
	var wallObjects:Array<Frame>;
	private function drawWalls(){		
		//bmd.draw(walls, new openfl.geom.Matrix(1, 0, 0, 1, 0, drawOffset));
		bmd.copyPixels(walls, wallPosters, new Point(0, 195+drawOffset), null, null, true);

		for(i in 0...wallOrderLeft.length){
			var p = 195-wallWindowsLeft.height*(i+1) + drawOffset;
			if(wallOrderLeft[i] == 0)
				bmd.copyPixels(walls, wallBricksLeft, new Point(0, p), null, null, true);
			else{
				bmd.fillRect(new Rectangle(0, p, 100, 50), 0xff3d3c39);
				bmd.copyPixels(walls, wallWindowsLeft, new Point(0, p), null, null, true);
			}

			if(wallOrderRight[i] == 0)
				bmd.copyPixels(walls, wallBricksRight, new Point(200, p), null, null, true);
			else{
				bmd.fillRect(new Rectangle(300, p, 100, 50), 0xff3d3c39);
				bmd.copyPixels(walls, wallWindowsRight, new Point(200, p), null, null, true);
			}
		}
	}

	private function generateWall(){
		for(i in 0...35){
			var n = Math.random()>.5?1:0;
			wallOrderLeft.push(n);
			genPiece(n, i, 0);
		}

		for(i in 0...35){
			var n = Math.random()>.5?1:0;
			// easy mode - always something to climb
			if(wallOrderLeft[i] == 0) n == 1;
			wallOrderRight.push(n);
			genPiece(n, i, 1);
		}
	}

	private function genPiece(n:Int, i:Int, side:Int){
		if(n == 1){
			var f = new Frame("ledge.png");
			f.x = 120+side*160;
			f.y = 236-wallWindowsLeft.height*(i+1);
			frames.push(f);
		}
		var a = side==0?wallOrderLeft:wallOrderRight;
		if(i>0 && n==1 && a[i-1] == 1){
			var f = new Frame("fire_escape.png");
			f.x = 120+side*160;
			f.y = 208-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			if(i>1) f.setRect(new Rectangle(0, 0, f.width, f.height-29));
			wallObjects.push(f);
			frames.push(f);
		} else if(n==1 && Math.random() < .5){
			var f = new Frame("aircon.png");
			f.x = 110+side*180;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		} else if (n == 0 && Math.random() < .4){
			var f = new Frame("satellite.png");
			f.x = 120+side*160;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		} else if (n == 0 && Math.random() < .4){
			var f = new Frame("camera.png");
			f.x = 120+side*160;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		}
	}
}