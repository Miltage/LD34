package me.miltage.ld34.physics;

import openfl.geom.Point;

class BiasedConstraint extends Constraint{
	private var bias:Int;
	public function new(a:Anchor, b:Anchor, len:Float, bias:Int) {
		super(a, b, len);
		this.bias = bias;
		a.connected = true;
		b.connected = true;
	}
	
	override public function update(){
		var dx = b.r.x - a.r.x;
		var dy = b.r.y - a.r.y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var diff = length-dist;
		var offset:Point = new Point((diff*dx/dist)/2, (diff*dy/dist)/2);
		if(!a.anchored && bias == 1) a.r = a.r.subtract(offset);
		if(!b.anchored && bias == 0) b.r = b.r.add(offset);
	}

}