package me.miltage.ld34;

import openfl.display.Stage;
import me.miltage.ld34.KeyObject;
import me.miltage.ld34.physics.Constraint;
import me.miltage.ld34.physics.BiasedConstraint;
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
	public static var SHUTTER_SPEED:Float = 3;

	var bmd:BitmapData;
	var black:BitmapData;
	var ambient:BitmapData;
	var ambientWindows:BitmapData;
	var key:KeyObject;

	var anchors:Array<Anchor>;
	var oldAnchors:Array<Anchor>;
	var miscAnchors:Array<Anchor>;
	var constraints:Array<Constraint>;
	var miscConstraints:Array<Constraint>;
	var frames:Array<Frame>;
	var angle:Float;
	var count:Int;
	var carCounter:Int;
	var carPos:Int;
	var carType:Int;
	var finished:Bool;

	var drawOffset:Int;
	var lastOffset:Int;
	var walls:BitmapData;
	var backWalls:BitmapData;
	var street:BitmapData;
	var rooftops:BitmapData;
	var sky:BitmapData;
	var people:BitmapData;
	var cars:BitmapData;
	var cars2:BitmapData;
	var birds:BitmapData;
	var title:BitmapData;
	var end:BitmapData;
	var buttons:BitmapData;
	var fbmd:BitmapData;

	var filter:Sprite;
	
	public function new(stage:Stage) {
		super();

		key = new KeyObject(stage);

		frames = [];
		var f = new Frame("street_frame.png");
		frames.push(f);

		bmd = new BitmapData(400, 300, true, 0x00000000);
		black = new BitmapData(400, 300, true, 0xff000000);
		ambient = new BitmapData(400, 400, true, 0x00000000);
		ambientWindows = new BitmapData(400, 300, true, 0x00000000);
		var b:Bitmap = new Bitmap(bmd);
		b.scaleX = b.scaleY = 2;
		addChild(b);

		filter = new Sprite();
		fbmd = new BitmapData(400, 300, true, 0xffffffff);
		filter.addChild(new Bitmap(fbmd));
		filter.scaleX = filter.scaleY = 2;
		addChild(filter);

		walls = Assets.getBitmapData("assets/walls.png");
		backWalls = Assets.getBitmapData("assets/background.png");
		street = Assets.getBitmapData("assets/street.png");
		rooftops = Assets.getBitmapData("assets/rooftops.png");
		sky = Assets.getBitmapData("assets/rooftop_bg.png");
		people = Assets.getBitmapData("assets/street_people.png");
		cars = Assets.getBitmapData("assets/cars.png");
		cars2 = Assets.getBitmapData("assets/cars.png");
		birds = Assets.getBitmapData("assets/birds.png");
		title = Assets.getBitmapData("assets/titlecard.png");
		end = Assets.getBitmapData("assets/end.png");
		buttons = Assets.getBitmapData("assets/buttons.png");
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
		lastOffset = 0;
		carCounter = 50;
		finished = false;

		addEventListener(Event.ENTER_FRAME, tick);

		// sim hanging lines
		for(i in 0...200){
			// update hanging anchors
			for(anchor in miscAnchors){
				anchor.forces.push(new Point(0, 0.025));
				anchor.update();
			}

			// draw hanging lines
			for(constraint in miscConstraints){
				constraint.update();
			}
		}
	}

	private var escPressed:Bool = false;
	public function tick(e:Event){

		if(!escPressed && key.isDown(KeyObject.ESCAPE) && !Main.instance.isMenuVisible()){
			Main.instance.showMenu();
			escPressed = true;
		} else if (!escPressed && key.isDown(KeyObject.ESCAPE)) {
			Main.instance.hideMenu();
			escPressed = true;
		} else if(!key.isDown(KeyObject.ESCAPE)){
			escPressed = false;
		}

		bmd.fillRect(bmd.rect, 0x00000000);
		// repeat back wall
		var bwp:Int = Std.int(drawOffset/2-8*Math.floor(drawOffset/16));
		var p:Int = Std.int(-wallOrderLeft.length*40+3+drawOffset/2);
		for(i in 0...100){
			bmd.copyPixels(backWalls, new Rectangle(0, 0, backWalls.width, 148), new Point(0, p+72*i-2));
		}
		bmd.fillRect(new Rectangle(0, 0, 400, p), 0xff75cdcf);
		bmd.draw(sky, new openfl.geom.Matrix(1, 0, 0, 1, 0, p));
		bmd.draw(backWalls, new openfl.geom.Matrix(1, 0, 0, 1, 0, p+wallOrderLeft.length*40-2));
		// end back wall

		bmd.fillRect(new Rectangle(0, -wallOrderLeft.length*67+drawOffset, 119, 3000), 0xff3d3c39);
		bmd.fillRect(new Rectangle(281, -wallOrderLeft.length*67+drawOffset, 120, 3000), 0xff3d3c39);

		bmd.draw(street, new openfl.geom.Matrix(1, 0, 0, 1, 0, drawOffset));
		bmd.copyPixels(walls, wallPosters, new Point(0, 195+drawOffset), null, null, true);

		if(count%SHUTTER_SPEED == 0) lastOffset = drawOffset;
		drawWalls();

		var rooftopEdge = -wallOrderLeft.length*72+160;

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
			if(anchor.position == 1 && anchor.r.y > rooftopEdge)
				anchor.drawLeaf(bmd, drawOffset);
			else if(anchor.position == 1)
				anchor.drawFlower(bmd, drawOffset);
		}

		for(object in wallObjects){
			bmd.draw(object, new openfl.geom.Matrix(object.scaleX, 0, 0, 1, object.x, object.y+drawOffset));
		}
		for(frame in frames){
			//bmd.draw(frame, new openfl.geom.Matrix(frame.scaleX, 0, 0, 1, frame.x, frame.y+drawOffset), new openfl.geom.ColorTransform(0, 0, 1, 1, 1, 1, 1, 1));
		}

		var lastAnchor:Anchor = anchors[anchors.length-1];
		if(!Main.PAUSED){
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
				else if(anchor.r.y > rooftopEdge+4 && anchor.r.x < 120) anchor.r.x = 120;
				else if(anchor.r.y > rooftopEdge+4 && anchor.r.x > 280) anchor.r.x = 280;
				else if(anchor.r.y > rooftopEdge && anchor.r.x < 120) anchor.r.y = rooftopEdge;
				else if(anchor.r.y > rooftopEdge && anchor.r.x > 280) anchor.r.y = rooftopEdge;
				//GraphicsUtil.drawCircle(bmd, anchor.r.x, anchor.r.y+drawOffset, 2, 0xff61a45a, true);
			}

			// update old anchors - can't forget about them!
			for(anchor in oldAnchors){
				if(anchor.r.y+drawOffset > 400 || anchor.r.y+drawOffset < -100)	continue;
				if(anchor.r.y > 280) anchor.r.y = 280;
				else if(anchor.r.y > rooftopEdge+4 && anchor.r.x < 120) anchor.r.x = 120;
				else if(anchor.r.y > rooftopEdge+4 && anchor.r.x > 280) anchor.r.x = 280;
				else if(anchor.r.y > rooftopEdge && anchor.r.x < 120) anchor.r.y = rooftopEdge;
				else if(anchor.r.y > rooftopEdge && anchor.r.x > 280) anchor.r.y = rooftopEdge;
				anchor.forces.push(gravity);
				anchor.update();
			}
		}

		// draw foreground vines
		for(constraint in constraints){
			if(!Main.PAUSED) constraint.update();
			if(constraint.b.position == 1) continue;
			var diff = constraint.b.r.subtract(constraint.a.r);
			diff.normalize(1);
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y+drawOffset, constraint.b.r.x+diff.x, constraint.b.r.y+diff.y+drawOffset, 0xff5ea55d);
		}

		// draw foreground leaves
		for(anchor in anchors.concat(oldAnchors)){
			if(anchor.position == 0 && anchor.r.y > rooftopEdge)
				anchor.drawLeaf(bmd, drawOffset);
			else if(anchor.position == 0)
				anchor.drawFlower(bmd, drawOffset);
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

		// update hanging anchors
		if(!Main.PAUSED) 
		for(anchor in miscAnchors){
			anchor.forces.push(new Point(0, 0.025));
			if(anchor.connected)
				anchor.forces.push(new Point(0, 0.3));
			anchor.update();
			if(Point.distance(lastAnchor.r, anchor.r) < 10 && !anchor.connected){
				constraints.push(new BiasedConstraint(lastAnchor, anchor, 0, 1));
				//lastAnchor.anchored = true;
				lastAnchor.position = 1-lastAnchor.position;
				oldAnchors = oldAnchors.concat(anchors);
				anchors = [];
			}
		}

		// draw hanging lines
		for(constraint in miscConstraints){
			if(!Main.PAUSED) constraint.update();
			var diff = constraint.b.r.subtract(constraint.a.r);
			diff.normalize(1);
			GraphicsUtil.drawLine(bmd, constraint.a.r.x, constraint.a.r.y+drawOffset, constraint.b.r.x+diff.x, constraint.b.r.y+diff.y+drawOffset, 0xff1f1e1b);
		}

		//GraphicsUtil.drawLine(bmd, 0, rooftopEdge+drawOffset, 400, rooftopEdge+drawOffset, 0xffff0000);

		
		var drawAmbient = count%SHUTTER_SPEED == 0;
		if(drawAmbient && !Main.PAUSED){
			ambient.fillRect(ambient.rect, 0x00000000);
		}

		if(Main.EFFECTS && !Main.PAUSED){

			// flying birds
			var bf = 2+Std.int(Math.random()*2);
			if(Math.random()>.4 && drawAmbient){
				for(i in 0...5)
				ambient.copyPixels(birds, new Rectangle(32*bf, 32*Std.int(Math.round(Math.random())), 32, 32), 
					new Point(Math.random()*450-25, 264-Math.random()*(wallOrderLeft.length*80)+drawOffset), null, null, true);
			}

			// sitting birds
			if(drawAmbient)
			for(i in 0...10){
				bf = Std.int(Math.random()*2);
				var birdy = 264; // floor
				var birdx = Math.random()*450-25; // anywhere
				if(Math.random()>.25){
					var valid = false;
					if(Math.random()>.7){
						// on roof
						birdy = 195-Std.int(wallWindowsLeft.height*(wallOrderLeft.length+1));
						birdx = Math.random()>.5?(Math.random()*110):(260+Math.random()*120);
					}else{
						// on fire escape
						while(!valid){
							var i = Std.int(Math.random()*wallOrderLeft.length);
							if(wallOrderLeft[i] == 1 && ((i>0 && wallOrderLeft[i-1] == 1) || (i<wallOrderLeft.length && wallOrderLeft[i+1] == 1))){
								valid = true;
								birdx = 130+Math.random()*40-20;
								birdy = 186-Std.int(wallWindowsLeft.height*(i+1));
							} else if(wallOrderRight[i] == 1 && ((i>0 && wallOrderRight[i-1] == 1) || (i<wallOrderLeft.length && wallOrderRight[i+1] == 1))){
								valid = true;
								birdx = 240+Math.random()*40-20;
								birdy = 186-Std.int(wallWindowsLeft.height*(i+1));
							}
						}
					}
					
				}
				ambient.copyPixels(birds, new Rectangle(32*bf, 32*Std.int(Math.round(Math.random())), 32, 32), 
						new Point(birdx, birdy+drawOffset), null, null, true);
			}

			// birds on wires
			if(drawAmbient)
			for(i in 0...3){
				bf = Std.int(Math.random()*2);

				var a:Anchor = miscAnchors[Std.int(Math.random()*miscAnchors.length)];

				var birdx = a.r.x-16;
				var birdy = a.r.y-22;

				ambient.copyPixels(birds, new Rectangle(32*bf, 32*Std.int(Math.round(Math.random())), 32, 32), 
						new Point(birdx, birdy+drawOffset), null, null, true);
			}

			// draw street people
			people = GraphicsUtil.flipBitmapData(people);
			if(Math.random()>.3 && drawAmbient){
				for(i in 0...Std.int(Math.random()*3)){
					var pf = Std.int(Math.random()*7);
					ambient.copyPixels(people, new Rectangle(64*pf, 0, 64, 96), new Point(Math.random()*450-25, 194+drawOffset), null, null, true);
				}
			}

			// draw cars
			if(drawAmbient){
				var cf = Math.random()<.05?1:0;
				cars = GraphicsUtil.flipBitmapData(cars);
				var pf = Std.int(Math.random()*2);
				ambient.copyPixels(cars, new Rectangle(153*pf, 0, 153, 64), new Point(Math.random()*500-50, 235+drawOffset), null, null, true);
			}

			if(carCounter > 0) carCounter--;
			else if(carCounter < 0 && drawAmbient){
				// draw lingering car
				ambient.copyPixels(cars2, new Rectangle(153*carType, 0, 153, 64), new Point(carPos, 235+drawOffset), null, null, true);

				carCounter++;
				if(carCounter == 0)
					carCounter = Std.int(Math.random()*150+20);
			}
			else if(drawAmbient){
				carPos = Std.int(Math.random()*500-50);
				carType = Math.random()>.5?1:0;
				carCounter = Std.int(-20-Math.random()*200);
				if(Math.random()>.5) cars = GraphicsUtil.flipBitmapData(cars);
			}
		}

		if(!finished){
			drawOffset = Std.int(150-lastAnchor.r.y);
			if(drawOffset < 0) drawOffset = 0;
		} else {
			drawOffset++;
		}

		bmd.copyPixels(ambient, ambient.rect, new Point(0, drawOffset-lastOffset), null, null, true);

		filter.alpha = 0;
		if(!finished && drawAmbient && Main.EFFECTS && !Main.PAUSED){
			filter.alpha = .1+Math.random()*.3;
			var red:Float = 40+Math.floor(Math.random()*40);
			var green:Float = 40+Math.floor(Math.random()*40);
			var blue:Float = 40+Math.floor(Math.random()*40);
			var color:UInt = 255 << 24 | Std.int(red) << 16 | Std.int(green) << 8 | Std.int(blue);
			fbmd.fillRect(fbmd.rect, color);
			filter.blendMode = openfl.display.BlendMode.OVERLAY;
		}

		// draw keys
		var alphaBitmap:BitmapData = new BitmapData(black.width, black.height, true, GraphicsUtil.ARGBToHex(0, 0, 0, (40-drawOffset)/40>0?(40-drawOffset)/40:0));
		bmd.copyPixels(buttons, new Rectangle(0, 0, 17, 19), new Point(200-17-15, 160+drawOffset), alphaBitmap, null, true);
		bmd.copyPixels(buttons, new Rectangle(17, 0, 17, 19), new Point(200+15, 160+drawOffset), alphaBitmap, null, true);
		alphaBitmap = new BitmapData(black.width, black.height, true, GraphicsUtil.ARGBToHex(0, 0, 0, (40-drawOffset)/40>0?(40-drawOffset)/40:0));
		bmd.copyPixels(end, new Rectangle(0, end.height/2, end.width, end.height/2), new Point(200-end.width/2, 190+drawOffset), alphaBitmap, null, true);

		if(!Main.PAUSED) count++;
		if(count % 10 == 0 || lastAnchor.anchored || lastAnchor.connected){
			var a = new Anchor(lastAnchor.r.x, lastAnchor.r.y);
			a.position = lastAnchor.position;
			anchors.push(a);
			
			var c = new Constraint(lastAnchor, a, -1);
			constraints.push(c);
		}

		alphaBitmap = new BitmapData(black.width, black.height, true, GraphicsUtil.ARGBToHex(0, 0, 0, Math.max((40-count)/40, 0)));
		bmd.copyPixels(black, black.rect, new Point(), alphaBitmap, null, true);
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

		var rooftopEdge = -wallOrderLeft.length*72+160;
		// gen hanging lines
		miscAnchors = [];
		miscConstraints = [];
		var liney = 100;
		for(i in 0...10){
			var a:Anchor = new Anchor(120, liney);
			liney += Std.int(Math.random()*50-25);
			if(liney < rooftopEdge) break;
			var b:Anchor = null;
			a.anchored = true;
			miscAnchors.push(a);
			for(j in 0...10){
				b = new Anchor(a.r.x + 16, liney);
				miscAnchors.push(b);
				var c:Constraint = new Constraint(a, b, 16);
				miscConstraints.push(c);
				a = b;
			}
			b.anchored = true;
			liney -= 10+Std.int(Math.random()*300);
		}
	}

	var wallOrderLeft:Array<Int>;
	var wallOrderRight:Array<Int>;
	var wallObjects:Array<Frame>;
	private function drawWalls(){

		if(count%SHUTTER_SPEED == 0 && !Main.PAUSED) 
			ambientWindows.fillRect(ambient.rect, 0x00000000);
		
		var ea = (drawOffset-wallOrderLeft.length*84)/100;
		if(ea < 0) ea = 0;
		else if(ea > 1) ea = 1;

		// draw end
		var alphaBitmap:BitmapData = new BitmapData(end.width, end.height, true, GraphicsUtil.ARGBToHex(0, 0, 0, ea));
		bmd.copyPixels(end, end.rect, new Point(200-end.width/2, 150-end.height/2), alphaBitmap, null, true);

		// draw title card
		var ta = (drawOffset-wallOrderLeft.length*72+40)/100;
		if(ta < 0) ta = 0;
		else if(ta > 1){
			ta = 1;
			finished = true;
		}
		var alphaBitmap:BitmapData = new BitmapData(title.width, title.height, true, GraphicsUtil.ARGBToHex(0, 0, 0, ta));
		bmd.copyPixels(title, title.rect, new Point(0, -wallOrderLeft.length*40+3+drawOffset/2), alphaBitmap, null, true);

		// draw people in windows
		for(i in 0...wallOrderLeft.length){
			var p = 195-wallWindowsLeft.height*(i+1) + drawOffset;
			if(wallOrderLeft[i] == 1){
				var pf = Std.int(Math.random()*7);
				if(pf == 3) pf = 0; // umbrellas inside are bad luck!
				if(count%SHUTTER_SPEED==0 && Math.random()>.8 && Main.EFFECTS && !Main.PAUSED)
					ambientWindows.copyPixels(people, new Rectangle(pf*64, 0, 64, 50), new Point(Math.random()*100-50, p), null, null, true);
			}
			if(wallOrderRight[i] == 1){
				var pf = Std.int(Math.random()*7);
				if(pf == 3) pf = 0; // umbrellas inside are bad luck!
				if(count%SHUTTER_SPEED==0 && Math.random()>.8 && Main.EFFECTS && !Main.PAUSED) 
					ambientWindows.copyPixels(people, new Rectangle(pf*64, 0, 64, 50), new Point(Math.random()*100+300, p), null, null, true);
			}
		}
		bmd.copyPixels(ambientWindows, ambientWindows.rect, new Point(0, drawOffset-lastOffset), null, null, true);

		for(i in 0...wallOrderLeft.length){
			var p = 195-wallWindowsLeft.height*(i+1) + drawOffset;
			if(wallOrderLeft[i] == 0)
				bmd.copyPixels(walls, wallBricksLeft, new Point(0, p), null, null, true);
			else{
				bmd.copyPixels(walls, wallWindowsLeft, new Point(0, p), null, null, true);
			}

			if(wallOrderRight[i] == 0)
				bmd.copyPixels(walls, wallBricksRight, new Point(200, p), null, null, true);
			else{
				bmd.copyPixels(walls, wallWindowsRight, new Point(200, p), null, null, true);
			}
		}
		
		bmd.draw(rooftops, new openfl.geom.Matrix(1, 0, 0, 1, 0, -wallOrderLeft.length*72+57+drawOffset));
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
			if(wallOrderLeft[i] == 0) n = 1;
			else if(Math.random()>.5) n = 0;
			wallOrderRight.push(n);
			genPiece(n, i, 1);
		}

		var f = new Frame("rooftops.png");
		f.x = 0;
		f.y = -wallOrderLeft.length*72+57;
		wallObjects.push(f);
		frames.push(f);
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
		} else if(n==1 && Math.random() < .3){
			var f = new Frame("aircon.png");
			f.x = 110+side*180;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		} else if (n == 0 && Math.random() < .3){
			var f = new Frame("satellite.png");
			f.x = 118+side*164;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		} else if (n == 0 && Math.random() < .3){
			var f = new Frame("camera.png");
			f.x = 120+side*160;
			f.y = 200-wallWindowsLeft.height*(i+1);
			f.scaleX = side==0?1:-1;
			wallObjects.push(f);
			frames.push(f);
		}
	}

	public function dump(){
		removeEventListener(Event.ENTER_FRAME, tick);
	}
}