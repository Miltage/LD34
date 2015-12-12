package me.miltage.ld34;

class GraphicsUtil {
	
	public static function drawLine (bmd:openfl.display.BitmapData, xx0:Float, yy0:Float, xx1:Float, yy1:Float, color:Int) {
		// Bresenham's line drawing algorithm
		var x0:Int = Std.int(xx0);
		var x1:Int = Std.int(xx1);
		var y0:Int = Std.int(yy0);
		var y1:Int = Std.int(yy1);
		var dx:Int = Std.int(x1-x0);
		var dy:Int = Std.int(y1-y0);
		var stepx:Int;
		var stepy:Int;
	
		if (dx<0) { dx*=-1; stepx=-1; } else { stepx=1; }
		if (dy<0) { dy*=-1; stepy=-1; } else { stepy=1; }
		
		dy <<= 1; // *= 2;
		dx <<= 1;
		
		bmd.setPixel32(Std.int(x0), Std.int(y0), color);
		if (dx > dy) {
			var fraction:Float = dy - (dx >> 1);
			while (x0 != x1) {
				if (fraction >= 0) {
					y0 += stepy;
					fraction -= dx;
				}
				x0 += stepx;
				fraction += dy;
				bmd.setPixel32(Std.int(x0), Std.int(y0), color);
			}
		} else {
			var fraction:Float = dx - (dy >> 1);
			while (y0 != y1) {
				if (fraction >= 0) {
					x0 += stepx;
					fraction -= dy;
				}
				y0 += stepy;
				fraction += dx;
				bmd.setPixel32(Std.int(x0), Std.int(y0), color);
			}
		}

		
	}	

	public static function drawStaggeredLine (bmd:openfl.display.BitmapData, xx0:Float, yy0:Float, xx1:Float, yy1:Float, color:Int) {
		// Bresenham's line drawing algorithm
		var x0:Int = Std.int(xx0);
		var x1:Int = Std.int(xx1);
		var y0:Int = Std.int(yy0);
		var y1:Int = Std.int(yy1);
		var dx:Int = Std.int(x1-x0);
		var dy:Int = Std.int(y1-y0);
		var stepx:Int;
		var stepy:Int;
		var c:Int = 0;
	
		if (dx<0) { dx*=-1; stepx=-1; } else { stepx=1; }
		if (dy<0) { dy*=-1; stepy=-1; } else { stepy=1; }
		
		dy <<= 1; // *= 2;
		dx <<= 1;
		
		bmd.setPixel32(Std.int(x0), Std.int(y0), color);
		if (dx > dy) {
			var fraction:Float = dy - (dx >> 1);
			while (x0 != x1) {
				if (fraction >= 0) {
					y0 += stepy;
					fraction -= dx;
				}
				x0 += stepx;
				fraction += dy;
				if(c % 2 == 0) bmd.setPixel32(Std.int(x0), Std.int(y0), color);
				c++;
			}
		} else {
			var fraction:Float = dx - (dy >> 1);
			while (y0 != y1) {
				if (fraction >= 0) {
					x0 += stepx;
					fraction -= dy;
				}
				y0 += stepy;
				fraction += dx;
				if(c % 2 == 0) bmd.setPixel32(Std.int(x0), Std.int(y0), color);
				c++;
			}
		}
		
	}	
	
	public static function drawCircle (bmd:flash.display.BitmapData, xCenter:Float, yCenter:Float, r:Float, color:Int, ?fill:Bool=false, ?scaleY:Float=1):Void {
		
		if (r == 0) {
			bmd.setPixel32(Std.int(xCenter), Std.int(yCenter), color);
			return;
		}
		
		var r2:Float = r * r;
		var x:Float = 1;
		var y:Float = Math.ceil(Math.sqrt(r2 - 1));
			
		bmd.setPixel32(Std.int(xCenter), Std.int(yCenter + r/scaleY), color);
		bmd.setPixel32(Std.int(xCenter), Std.int(yCenter - r/scaleY), color);
		bmd.setPixel32(Std.int(xCenter + r), Std.int(yCenter), color);
		bmd.setPixel32(Std.int(xCenter - r), Std.int(yCenter), color);
		if (fill != false && scaleY == 1) { 
			drawLine(bmd, xCenter - r - 1, yCenter, xCenter + r + 1, yCenter, color);
		}
		
		while (x <= y) {
			
			bmd.setPixel32(Std.int(xCenter + x), Std.int(yCenter + y/scaleY), color);
			bmd.setPixel32(Std.int(xCenter - x), Std.int(yCenter + y/scaleY), color);
			bmd.setPixel32(Std.int(xCenter - x), Std.int(yCenter - y/scaleY), color);
			bmd.setPixel32(Std.int(xCenter + x), Std.int(yCenter - y/scaleY), color);
			bmd.setPixel32(Std.int(xCenter + y), Std.int(yCenter + x/scaleY), color);
			bmd.setPixel32(Std.int(xCenter - y), Std.int(yCenter + x/scaleY), color);
			bmd.setPixel32(Std.int(xCenter - y), Std.int(yCenter - x/scaleY), color);
			bmd.setPixel32(Std.int(xCenter + y), Std.int(yCenter - x/scaleY), color);
			
			if (fill != false) {
				if (y != Math.ceil(Math.sqrt(r2 - (x-1)*(x-1)))) {
					drawLine(bmd, xCenter - x + 1, yCenter + y/scaleY, xCenter + x - 1, yCenter + y/scaleY, color);
					drawLine(bmd, xCenter - x + 1, yCenter - y/scaleY, xCenter + x - 1, yCenter - y/scaleY, color);
				}
				if (x != Math.ceil(Math.sqrt(r2 - (y-1)*(y-1)))) {
					drawLine(bmd, xCenter - y + 1, yCenter + x/scaleY, xCenter + y - 1, yCenter + x/scaleY, color);
					drawLine(bmd, xCenter - y + 1, yCenter - x/scaleY, xCenter + y - 1, yCenter - x/scaleY, color);
				}
			}
			
			x++;
			y = Math.ceil(Math.sqrt(r2 - x*x));
			
		}
	}

	public static function drawCircleLine (bmd:openfl.display.BitmapData, xx0:Float, yy0:Float, xx1:Float, yy1:Float, color:Int, r:Float) {
		// Bresenham's line drawing algorithm
		var x0:Int = Std.int(xx0);
		var x1:Int = Std.int(xx1);
		var y0:Int = Std.int(yy0);
		var y1:Int = Std.int(yy1);
		var dx:Int = Std.int(x1-x0);
		var dy:Int = Std.int(y1-y0);
		var stepx:Int;
		var stepy:Int;
	
		if (dx<0) { dx*=-1; stepx=-1; } else { stepx=1; }
		if (dy<0) { dy*=-1; stepy=-1; } else { stepy=1; }
		
		dy <<= 1; // *= 2;
		dx <<= 1;
		
		bmd.setPixel32(Std.int(x0), Std.int(y0), color);
		if (dx > dy) {
			var fraction:Float = dy - (dx >> 1);
			while (x0 != x1) {
				if (fraction >= 0) {
					y0 += stepy;
					fraction -= dx;
				}
				x0 += stepx;
				fraction += dy;
				drawCircle(bmd, x0, y0, r, color, true);
			}
		} else {
			var fraction:Float = dx - (dy >> 1);
			while (y0 != y1) {
				if (fraction >= 0) {
					x0 += stepx;
					fraction -= dy;
				}
				y0 += stepy;
				fraction += dx;
				drawCircle(bmd, x0, y0, r, color, true);
			}
		}
		
	}

	public static function getBrightness(color:Int) {
		var rgb:Array<Int> = HexToRGB(color);
    
    	return Math.sqrt((rgb[0] * rgb[0] * 0.241) + (rgb[1] * rgb[1] * 0.691) + (rgb[2] * rgb[2] * 0.068) ) / 255;
	}

	public static function HexToRGB(hex:Int):Array<Int>	{
	    var rgb:Array<Int> = [];
	    
	    var r:Int = hex >> 16 & 0xFF;
	    var g:Int = hex >> 8 & 0xFF;
	    var b:Int = hex & 0xFF;
	            
	    rgb.push(r);
	    rgb.push(g);
	    rgb.push(b);
	    return rgb;
	}

	public static function HexToARGB(hex:Int):Array<Int> {
	    var rgb:Array<Int> = [];
	    
	    var a:Int = (hex >>> 0x18) & 0xff;
	    var r:Int = (hex >>> 0x10) & 0xff;
	    var g:Int = (hex >>> 0x08) & 0xff;
	    var b:Int = hex & 0xff;
	            
	    rgb.push(a);
	    rgb.push(r);
	    rgb.push(g);
	    rgb.push(b);
	    return rgb;
	}

	public static function getAlpha(hex:Int){
		return HexToARGB(hex)[0];
	}

	public static function getAlphaBmd(bmd:openfl.display.BitmapData, x:Float, y:Float){
		return HexToARGB(bmd.getPixel32(Std.int(x), Std.int(y)))[0];
	}
}