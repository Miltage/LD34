package me.miltage.ld34.physics;

import openfl.geom.Point;

class Constraint {
	public var a:Anchor;
	public var b:Anchor;
	private var length:Float;
	public function new(a:Anchor, b:Anchor, len:Float) {
		this.a = a;
		this.b = b;
		length = len;
	}
	
	public function setLength(len:Float){
		length = len;
	}
	
	public function getLength():Float {
		return length;
	}
	
	public function update(){
		var dx = b.r.x - a.r.x;
		var dy = b.r.y - a.r.y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var diff = length-dist;
		var offset:Point = new Point((diff*dx/dist)/2, (diff*dy/dist)/2);
		if(!a.anchored) a.r = a.r.subtract(offset);
		if(!b.anchored) b.r = b.r.add(offset);
	}

}