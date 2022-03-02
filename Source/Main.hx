package;

import openfl.display.Sprite;
import openfl.Lib;

import me.miltage.ld34.Game;
import me.miltage.ld34.SoundManager;
import me.miltage.ld34.Menu;

class Main extends Sprite {

	public static var instance:Main;

	public static var PAUSED:Bool = false;
	public static var MUTED:Bool = false;
	public static var EFFECTS:Bool = true;
	
	var game:Game;
	var soundManager:SoundManager;
	var menu:Menu;
	
	public function new () {
		
		super ();

		instance = this;
		Lib.current.stage.quality = flash.display.StageQuality.LOW;

		soundManager = new SoundManager(1);
		soundManager.loop("assets/song.mp3");
		
		game = new Game(stage);
		addChild(game);

		menu = new Menu();
		addChild(menu);
		hideMenu();
	}

	public function restart(){
		removeChild(game);
		game.dump();
		game = new Game(stage);
		addChildAt(game, 0);
		hideMenu();
	}

	public function toggleMusic(){
		MUTED = !MUTED;
		for(m in SoundManager.managers){
			m.transform(MUTED?0:1);
		}
	}

	public function toggleEffects(){
		EFFECTS = !EFFECTS;
	}

	public function showMenu(){
		menu.mouseEnabled = true;
		menu.visible = true;
		PAUSED = true;
	}

	public function hideMenu(){
		menu.mouseEnabled = false;
		menu.visible = false;
		PAUSED = false;
	}

	public function isMenuVisible(){
		return menu.visible;
	}
	
	
}