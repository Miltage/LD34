package me.miltage.ld34.physics;

import openfl.display.BitmapData;
import openfl.geom.Point;

class Anchor {
	public var r:Point;
	public var a:Point;
	public var old:Point;
	var d:Float = .98;
	public var forces:Array<Point> = [];
	public var anchored = false;
	public var position = 0;
	public var leaf:Bool = false;
	public var leafSize:Float = 0;
	public var leafMaxSize:Float = 0;
	public function new(x:Float, y:Float) {
		r = new Point(x, y);
		a = new Point();
		old = r.clone();

		leaf = Math.random() < .33;
		leafMaxSize = 1+Math.random()*3;
		leafSize = 0;
	}
	
	public function update(){
		totalForces();
		if(!anchored) movePoint();
		forces = [];
		if(leaf && leafSize < leafMaxSize) leafSize += 0.1;
	}
	
	public function totalForces(){
		a = new Point();
		for(p in forces){
			a = a.add(p);
		}
		
	}
	
	public function movePoint(){
		var temp:Point = r.clone();
		r.x += (r.x - old.x + a.x)*d;
		r.y += (r.y - old.y + a.y)*d;
		old = temp.clone();
	}
	
	public function setPosition(p:Point){
		r = p.clone();
	}
	
	public function setAnchored(a:Bool){
		anchored = a;
	}

	public function drawLeaf(bmd:BitmapData, dy:Int){
		if(!leaf) return;
		var c:UInt = 0xff8EF084;
		bmd.setPixel32(Std.int(r.x), Std.int(r.y)+dy, c);
		bmd.setPixel32(Std.int(r.x), Std.int(r.y)+1+dy, c);
		if(leafSize < 2) return;
		bmd.setPixel32(Std.int(r.x)+1, Std.int(r.y)+dy, c);
		bmd.setPixel32(Std.int(r.x)-1, Std.int(r.y)+dy, c);
		bmd.setPixel32(Std.int(r.x)+2, Std.int(r.y)+dy, c);
		bmd.setPixel32(Std.int(r.x)-2, Std.int(r.y)+dy, c);
		if(leafSize < 3) return;
		bmd.setPixel32(Std.int(r.x)+1, Std.int(r.y)+dy+1, c);
		bmd.setPixel32(Std.int(r.x)-1, Std.int(r.y)+dy+1, c);
		bmd.setPixel32(Std.int(r.x)+1, Std.int(r.y)+dy-1, c);
		bmd.setPixel32(Std.int(r.x)-1, Std.int(r.y)+dy-1, c);
		bmd.setPixel32(Std.int(r.x)+1, Std.int(r.y)+dy+2, c);
		bmd.setPixel32(Std.int(r.x)-1, Std.int(r.y)+dy+2, c);
		if(leafSize < 4) return;
		bmd.setPixel32(Std.int(r.x), Std.int(r.y)+2+dy, c);
		bmd.setPixel32(Std.int(r.x), Std.int(r.y)+3+dy, c);
		bmd.setPixel32(Std.int(r.x), Std.int(r.y)+4+dy, c);
	}

}