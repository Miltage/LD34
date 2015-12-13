package me.miltage.ld34;

import openfl.Assets;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.utils.Timer;

/*
 * Track current state (playing, looping, or stopped)
 */
enum SoundManagerState {
  EMPTY;	// no sound is currently loaded, play or loop calls will fail
	PLAY;		// channel is actively playing a sound
	LOOP;		// currently playing a sound and looping it indefinitely (through eventlistener)
	STOP;		// idle
}
 
class SoundManager {
	
	// track all sound managers out there
	public static var managers:Array<SoundManager>;
	
	// internal sound objects, managed through functions
	private var _sound:Sound;
	private var _soundname:String;	// the ID/path of the currently playing file
	private var _channel:SoundChannel;
	private var _transform:SoundTransform;
	public var state:SoundManagerState;
	
	// for animating from current soundtransform to a target soundtransform
	private var _targetTransform:SoundTransform;
	private var _pandelta:Float;                    // value to adjust the pan each time we update the transform
	private var _voldelta:Float;                    // value to adjust the volume each time we update the transform
	private var _updfreq:Float = .05;             // how often we update
	
	// defaults
	inline static private var _defaultvol = .5;					// default to half volume
	inline static private var _defaultpan = 0;						// default to centered
	
	// debug
	public var loopcount:Int = 0;
	
	/**
	 * Constructor.
	 */
	public function new(?vol:Float,?pan:Float):Void {
		
		// TODO: add static destroyAll() to iter through all the managers, stop any channels, clear all vars to null, then clear the manager to null, and finally wipe the array
		// TODO: add destroy() to do that to just the current manager (slice it from array?)
		// track all sound managers
		if (managers == null) managers = new Array<SoundManager>();
		managers.push(this);
		
		// default state
		state = EMPTY;
		
		// default transform
		transform(vol,pan);
	}
	
	/**
	 * Load the given sound, but don't play it.
	 */
	public function load(newsound:String = ""):Bool {
		//FlxG.log("--- loading... ---");
		
		// try to get new sound
		if ( newsound == null || newsound == "" )
			return false;															// no sound to load
		if ( newsound == _soundname ) return true;	// sound already loaded
		var newsoundObj:Sound = Assets.getSound(newsound);
		if ( newsoundObj == null ) return false;		// failed to load the new sound
		
		// assign new sound
		stop();																			// stop any current sound, kill any loop listener, set state to STOP
		_soundname = newsound;											// update current sound name
		_sound = newsoundObj;												// update current sound object
		
		//FlxG.log("--- ...loaded ---");
		
		return true;																// loaded new sound
	}

	/**
	 * Play the currently assigned sound, or load a new one and play it.
	 */
	public function play(?newsound:String):Bool {
		//FlxG.log(" --- playing... ---");
		
		if ( state == PLAY && ( newsound == null || _soundname == newsound ) )
			return true; // already playing and no new sound to process
		
		// given a sound name, so try to load it
		if ( newsound != null && !load(newsound) ) return false;	// given a sound but failed to load it so don't play
		
		// for some reason we've got here and still don't have a sound loaded, so don't play (may not need this check)
		if ( state == EMPTY ) return false;
		
		// play was called on an already looping sound (no new sound or load would have reset status to STOP)
		if ( state == LOOP ) {
			_channel.removeEventListener(Event.SOUND_COMPLETE, loopReset);			// so remove the loop listener
		} else {
		
			// we have a (possibly new, possibly unchanged) sound to play
			stop();																										// make sure we clear any looping listeners and stop any playing sound
			_channel = _sound.play(0, 1, _transform);									// still not sure if this is going to create a new channel
		}
		
		// update the state and add a listener to clear and update the state when the sound is done
		state = PLAY;
		_channel.addEventListener(Event.SOUND_COMPLETE, stop);
		
		//FlxG.log(" --- ...play started ---");
		
		return true;
	}

	/**
	 * Loop the currently assigned sound, or load a new one and loop it.
	 */
	public function loop(?newsound:String):Void {
		// already looping this sound?
		if ( ( newsound == null || _soundname == newsound ) && state == LOOP ) return;
		
		//FlxG.log(" + looping... +");
		
		// try to play
		if ( !play(newsound) ) return; // bail if there's a problem playing
		
		// remove the stop listener because we're looping
		_channel.removeEventListener(Event.SOUND_COMPLETE, stop);
		
		// start looping
		//   using listener as -1 on loop count is not getting the audio to loop... may not work for non-Flash targets though
		state = LOOP;																											// we're looping
		_channel.addEventListener(Event.SOUND_COMPLETE, loopReset);				// setup our callback to keep the loop going
		
		//FlxG.log(" + ...loop started +");
	}

	/**
	 * Helper function: removes the loop listener starts the loop playing again.
	 */	
	private function loopReset(e:Event):Void {
		//FlxG.log("  ... resetting... ...");
		_channel.stop();																									// just in case, since we're going to remove this channel
		_channel = _sound.play(0, 1, _transform);													// play sound again, we know the sound is stopped so we can use a direct play call
		state = LOOP;																											// we're looping
		_channel.addEventListener(Event.SOUND_COMPLETE, loopReset);				// setup our callback to keep the loop going
		//FlxG.log("  ... ...loop reset ...");
	}
	 
	/**
	 * Stop the sound (if it exists).
	 * 
	 * @param obj : In case called from an event listener or timer
	 */
	public function stop(?obj:Dynamic):Void {
		if (state == STOP ) return; // already stopped
		
		if ( state != EMPTY && _channel != null ) _channel.stop();
		state = STOP;
		
		//FlxG.log("### stopped ###");
	}
	
	private function _boundSoundTransform(?vol:Float, ?pan:Float):Dynamic {
		
		// default or bound initial vol and pan
		vol = (vol == null && _transform != null) ? _transform.volume : vol;  // if no volume given but we have a transform keep it the same
		vol = (vol == null) ? _defaultvol : vol;  // otherwise use default
		vol = (vol < 0) ? 0: vol;									// negative volume doesn't make sense
		vol = (vol > 10) ? 10: vol;								// picking 10 as an upper limit, for many sounds anything over 1 will be ear-blasting
		pan = (pan == null && _transform != null) ? _transform.pan : pan;  // if no pan given but we have a transform keep it the same
		pan = (pan == null) ? _defaultpan : pan;  // otherwise use default
		pan = (pan < -1) ? -1: pan;								// can't pan further left than -1
		pan = (pan > 1)  ? 1: pan;								// can't pan further right than 1
		
		var bounded:Dynamic = {
			vol:vol,
			pan:pan
		};
		
		return bounded;
	}
	
	/**
	 * Change volume and/or pan of sound
	 */
	public function transform(?vol:Float = _defaultvol, ?pan:Float = _defaultpan):Void {
		
		var boundedVals:Dynamic = _boundSoundTransform(vol, pan);
		
		// setup transform
		// make sure we at least have a default SoundTransform to use
		if ( _transform == null ) {
			_transform = new SoundTransform(boundedVals.vol, boundedVals.pan);
		} else {
			_transform.volume = boundedVals.vol; // only change volume if it's given
			_transform.pan    = boundedVals.pan; // only change pan if it's given
		}
		
		// if we're playing a sound then apply the transform to the current channel
		if ( ( state == PLAY || state == LOOP ) && _channel != null && _channel.soundTransform != _transform)
			_channel.soundTransform = _transform;
	}
		
	
}