package;

import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.Assets;
import openfl.events.MouseEvent;

import me.miltage.ld34.Game;
import me.miltage.ld34.SoundManager;
import me.miltage.ld34.Menu;
import me.miltage.ld34.Button;

class Main extends Sprite {

	public static var instance:Main;

	public static var PAUSED:Bool = false;
	public static var MUTED:Bool = false;
	public static var EFFECTS:Bool = true;
	
	var game:Game;
	var soundManager:SoundManager;
	var menu:Menu;
	
	public function new () {		
		super();

		instance = this;
		Lib.current.stage.quality = flash.display.StageQuality.LOW;

		menu = new Menu();
		addChild(menu);
		hideMenu();

		graphics.beginFill(0, 1);
		graphics.drawRect(0, 0, width, height);

		var menuText:BitmapData = Assets.getBitmapData("assets/start_button_text.png");

		var restartButton:Button = new Button(menuText, 0, 0, function(){});
		restartButton.x = 400 - 200;
		restartButton.y = 300 - 32;
		addChild(restartButton);

		addEventListener(MouseEvent.MOUSE_UP, function(m) { start(); });
	}

	public function start() {
		soundManager = new SoundManager(1);
		soundManager.loop("assets/song.mp3");
		
		game = new Game(stage);
		addChild(game);
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