package ;

import flash.display.BlendMode;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.util.FlxCollision;

using flixel.util.FlxSpriteUtil;

class State extends FlxState
{
	/**
	 * Allows users to toggle the effect on and off with the space bar.
	 */
	private var _enabled:Bool = true;
	private var _text1:FlxText;
	private var _text2:FlxText;
	private var _me:MyObject;
	private var _cameraWall:FlxGroup;

	/**
	 * How much light bloom to have - larger numbers = more
	 */
	private var _bloom:Int = 10;
	/**
	 * Our helper sprite - basically a mini screen buffer (see below)
	 */
	private var _fx:FlxSprite;
	
	/**
	 * Collidables
	 */
	private var _emitter:FlxEmitter;
	private var _pixel:FlxParticle; // this is to prevent creating all new pixels to new variables in loop
	private var _myobject:MyObject;
	private var _group:FlxGroup;

	/**
	 * This is where everything gets set up for the game state
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		#if !flash
		FlxG.log.error("Flash target only.");
		#else
		
		FlxG.sound.playMusic("assets/audio/grind.mp3",1,true);

		// Title text, nothing crazy here!
		_text1 = new FlxText(FlxG.width / 4, FlxG.height / 2 - 20, Math.floor(FlxG.width / 2), "Untitled");
		_text1.setFormat(null, 32, 0xffffffff, "center");
		add(_text1);
		
		_text2 = new FlxText(FlxG.width / 4, FlxG.height / 2 + 20, Math.floor(FlxG.width / 2), "press space");
		_text2.setFormat(null, 16, 0x44666666, "center");
		add(_text2);
		
		// This is the sprite we're going to use to help with the light bloom effect
		// First, we're going to initialize it to be a fraction of the screens size
		_fx = new FlxSprite();
		_fx.makeGraphic(Math.floor(FlxG.width / _bloom), Math.floor(FlxG.height / _bloom), 0, true);
		// Zero out the origin so scaling goes from top-left, not from center
		_fx.origin.set();
		// Scale it up to be the same size as the screen again
		_fx.scale.set(_bloom, _bloom);
		// Set AA to true for maximum blurry
		_fx.antialiasing = true;
		// Set blend mode to "screen" to make the blurred copy transparent and brightening
		_fx.blend = BlendMode.SCREEN;
		// Note that we do not add it to the game state!  It's just a helper, not a "real" sprite.
		
		// Then we scale the screen buffer down, so it draws a smaller version of itself
		// into our tiny FX buffer, which is already scaled up.  The net result of this operation
		// is a blurry image that we can render back over the screen buffer to create the bloom.
		FlxG.camera.screen.scale.set(1 / _bloom, 1 / _bloom);
		
		// This is the particle emitter that spews things off the bottom of the screen.
		// I'm not going to go over it in too much detail here, but basically we
		// create the emitter, then we create 50 16x16 sprites and add them to it.
		var num:Int = 50;
		_emitter = new FlxEmitter(0, FlxG.height + 8, num);
		_emitter.width = FlxG.width;
		_emitter.y = FlxG.height + 20;
		_emitter.gravity = -20;
		_emitter.setXSpeed( -20, 20);
		_emitter.setYSpeed( -75, -25);
		_emitter.bounce = 0.8;

		_group = new FlxGroup();

		for (i in 0...num)
		{
			_myobject = new MyObject();
			_emitter.add(_myobject);
			_group.add(_myobject);
		}

		add(_emitter);
		add(_group);

		_emitter.start(false, 0, 0.1);

		_cameraWall = FlxCollision.createCameraWall(FlxG.camera,FlxCollision.CAMERA_WALL_INSIDE,1);

		#end
	}
	
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE && _enabled)
		{
			_enabled = false;
			FlxTween.tween(_text1,{alpha:0},2.0,{ease:FlxEase.quadInOut,complete:titleFadeDone});
			FlxTween.tween(_text2,{alpha:0},2.0,{ease:FlxEase.quadInOut});
		}
		
		super.update();

		FlxG.collide(_emitter,_group);
		if (_me!=null)
		{
			FlxG.collide(_me,_group);
			FlxG.collide(_me,_cameraWall);
		}
	}
	
	private function titleFadeDone(Tween:FlxTween):Void
	{
		_me = new MyObject(0xffffffff);
		_me.screenCenter();
		_me.exists = true;
		add(_me);
		
	}

	/**
	 * This is where we do the actual drawing logic for the game state
	 */ 
	override public function draw():Void
	{
		// This draws all the game objects
		super.draw();
		#if flash
			//The actual blur process is quite simple now.
			//First we draw the contents of the screen onto the tiny FX buffer:
			//_fx.stamp(FlxG.camera.screen);
			//Then we draw the scaled-up contents of the FX buffer back onto the screen:
			//_fx.draw();
		#end
	}
}