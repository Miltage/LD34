package;

import openfl.display.Sprite;
import openfl.Lib;

import me.miltage.ld34.Game;
import me.miltage.ld34.SoundManager;

class Main extends Sprite {
	
	var game:Game;
	var soundManager:SoundManager;
	
	public function new () {
		
		super ();

		Lib.current.stage.quality = flash.display.StageQuality.LOW;

		soundManager = new SoundManager(1);
		soundManager.loop("assets/song.mp3");
		
		game = new Game(stage);
		addChild(game);
		
	}
	
	
}