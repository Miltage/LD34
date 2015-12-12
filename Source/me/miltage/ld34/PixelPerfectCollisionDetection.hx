package;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

class PixelPerfectCollisionDetection	
{
	
	/** Get the collision rectangle between two display objects. **/
	public static function GetCollisionRect(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Float = 0):Rectangle
	{
		// get bounding boxes in common parent's coordinate space
		var rect1:Rectangle = GetBoundingRectangle(target1);
		var rect2:Rectangle = GetBoundingRectangle(target2);
		// find the intersection of the two bounding boxes
		var intersectionRect:Rectangle = rect1.intersection(rect2);		
		//trace("ir: " + intersectionRect);
		if (intersectionRect.size.length> 0)
		{
			if (pixelPrecise)
			{
				// size of rect needs to integer size for bitmap data
				intersectionRect.width = Math.ceil(intersectionRect.width);
				intersectionRect.height = Math.ceil(intersectionRect.height);
				// get the alpha maps for the display objects
				var alpha1:BitmapData = GetAlphaMap(target1, intersectionRect, BitmapDataChannel.RED, commonParent);
				var alpha2:BitmapData = GetAlphaMap(target2, intersectionRect, BitmapDataChannel.GREEN, commonParent);
				// combine the alpha maps
				#if flash
				alpha1.draw(alpha2, null, null, BlendMode.LIGHTEN);
				#else
				alpha1.draw(alpha2, null, null, "LIGHTEN");
				#end
				// calculate the search color
				var searchColor:Int;
				if (tolerance <= 0)
				{
					searchColor = 0x010100;
				}
				else
				{
					if (tolerance> 1) tolerance = 1;
					var byte:Int = Math.round(tolerance * 255);
					searchColor = (byte <<16) | (byte <<8) | 0;
				}
				// find color
				var collisionRect:Rectangle = alpha1.getColorBoundsRect(searchColor, searchColor);
				collisionRect.x += intersectionRect.x;
				collisionRect.y += intersectionRect.y;
				return collisionRect;
			}
			else
			{
				return intersectionRect;
			}
		}
		else
		{
			// no intersection
			return null;
		}
	}
	
	/** Gets the alpha map of the display object and places it in the specified channel. **/
	private static function GetAlphaMap(target:DisplayObject, rect:Rectangle, channel:Int, commonParent:DisplayObjectContainer):BitmapData
	{
		// calculate the transform for the display object relative to the common parent
		var parentXformInvert:Matrix = commonParent.transform.concatenatedMatrix.clone();
		parentXformInvert.invert();
		var targetXform:Matrix = target.transform.concatenatedMatrix.clone();
		targetXform.concat(parentXformInvert);
		// translate the target into the rect's space
		targetXform.translate(-rect.x, -rect.y);
		// draw the target and extract its alpha channel into a color channel
		var bitmapData:BitmapData = new BitmapData(cast(rect.width), cast(rect.height), true, 0);
		bitmapData.draw(target, targetXform);
		var alphaChannel:BitmapData = new BitmapData(cast(rect.width), cast(rect.height), false, 0);
		alphaChannel.copyChannel(bitmapData, bitmapData.rect, new Point(0, 0), BitmapDataChannel.ALPHA, channel);
		return alphaChannel;
	}
	
	/** Get the center of the collision's bounding box. **/
	public static function GetCollisionPoint(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Float = 0):Point
	{
		var collisionRect:Rectangle = GetCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
		if (collisionRect != null && collisionRect.size.length> 0)
		{
			var x:Float = (collisionRect.left + collisionRect.right) / 2;
			var y:Float = (collisionRect.top + collisionRect.bottom) / 2;
			return new Point(x, y);
		}
		return null;
	}
	
	/** Are the two display objects colliding (overlapping)? **/
	public static function IsColliding(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Float = 0):Bool
	{
		var collisionRect:Rectangle = GetCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
		if (collisionRect != null && collisionRect.size.length> 0) return true;
		else return false;
	}
	
	public static function GetBoundingRectangle(object:DisplayObject):Rectangle {
		var rotation = object.rotation;
		if (rotation < 0) {
			rotation = 360 + rotation;
		}
			
		var position = new Point(object.x, object.y);
		if ((rotation > 0) && (rotation < 360)) {
			if (rotation < 90) {
				position.x -= object.height * Math.sin(rotation);
			}
			else if (rotation == 90) {
				position.x -= object.width;
			}
			else if (rotation < 180) {
				position.x -= object.width;
				position.y -= object.width * Math.sin(rotation);
			}
			else if (rotation == 180) {
				position.x -= object.width;
				position.y -= object.height;
			}
			else if (rotation < 270) {
				position.x -= object.height * Math.sin(rotation);
				position.y -= object.height;
			}
			else if (rotation == 270) {
				position.y -= object.height;
			}
			else {
				position.y -= object.width * Math.sin(rotation);
			}
		}
		
		return (new Rectangle(position.x, position.y, object.width, object.height));
	}
}