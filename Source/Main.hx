package;

import openfl.display.Sprite;
import openfl.Lib;

import me.miltage.ld34.Game;

class Main extends Sprite {
	
	var game:Game;
	
	public function new () {
		
		super ();
		
		game = new Game();
		addChild(game);
		
	}
	
	
}