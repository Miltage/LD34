package me.miltage.ld34.physics;

import openfl.geom.Point;

class Anchor {
	public var r:Point;
	public var a:Point;
	public var old:Point;
	var d:Float = .98;
	public var forces:Array<Point> = [];
	public var anchored = false;
	public var position = 0;
	public function new(x:Float, y:Float) {
		r = new Point(x, y);
		a = new Point();
		old = r.clone();
	}
	
	public function update(){
		totalForces();
		if(!anchored) movePoint();
		forces = [];
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

}