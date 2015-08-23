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
import flixel.util.FlxRect;

using flixel.util.FlxSpriteUtil;

class State extends FlxState
{
	/**
	 * Allows users to toggle the effect on and off with the space bar.
	 */
	private var _enabled:Bool = true;
	private var _text1:FlxText;
	private var _text2:FlxText;
	private var _particle:MyParticle;
	private var _me:MyObject;
	private var _cameraWall:FlxGroup;
	private var _zoomCam:FlxZoomCamera;
	
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
		super.create();

		FlxG.log.redirectTraces = true;

		trace(FlxG.worldBounds);

		FlxG.worldBounds.set(0, 0, FlxG.width*4, FlxG.height*2);

		add(flixel.addons.display.FlxGridOverlay.create(32,32,4*FlxG.width,FlxG.height*2,false,true,0x22222222,0x44444444));

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
		//FlxG.camera.screen.scale.set(1 / _bloom, 1 / _bloom);
		
		// This is the particle emitter that spews things off the bottom of the screen.
		// I'm not going to go over it in too much detail here, but basically we
		// create the emitter, then we create 50 16x16 sprites and add them to it.
		var num:Int = 500;
		_emitter = new FlxEmitter(0, FlxG.height+8, num);
		_emitter.width = FlxG.width;
		_emitter.y = FlxG.height ;
		//_emitter.gravity = -20;
		_emitter.setXSpeed( -20, 20);
		_emitter.setYSpeed( -75, -25);
		_emitter.bounce = 0.8;
		trace(_emitter.xPosition.min);
		trace(_emitter.xPosition.max);
		trace(_emitter.yPosition.min);
		trace(_emitter.yPosition.max);
		trace(FlxG.camera.bounds);
		_group = new FlxGroup();


		for (i in 0...num)
		{
			_particle = new MyParticle();

			_emitter.add(_particle);
			_group.add(_particle);
		}

		_emitter.particleClass = MyParticle;

		add(_emitter);
		add(_group);

		_emitter.start(false, 0, 0.1);

		//_cameraWall = FlxCollision.createCameraWall(FlxG.camera,FlxCollision.CAMERA_WALL_INSIDE,1);

		#end
	}
	
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE && _me==null)
		{
			var tween = FlxG.height;
			var tweenCameraY = FlxG.camera.scroll.y + tween;
			var tweenText1Y = _text1.y - tween;
			var tweenText2Y = _text2.y - tween;
			var objectY = tweenCameraY + FlxG.camera.height/2;
			var tweenEmitterY = objectY + FlxG.height;

			// stay fixed on screen
			_text1.scrollFactor.set();
			_text2.scrollFactor.set();

			FlxTween.tween(_text1,{alpha:0},2.0,{ease:FlxEase.quadInOut,complete:titleFadeDone});
			FlxTween.tween(_text2,{alpha:0},2.0,{ease:FlxEase.quadInOut});

			_me = new MyObject(FlxG.width/2,objectY);
			add(_me);
			_me.alpha = 0;
			_me.solid = false;

			FlxTween.tween(_me,{alpha:1.0},2.0,{ease:FlxEase.quadInOut});

			//_me.y = -FlxG.height;

			var cam:FlxCamera = FlxG.camera;
			_zoomCam = new FlxZoomCamera(Std.int(cam.x), Std.int(cam.y), cam.width, cam.height, cam.zoom);
			FlxG.cameras.reset(_zoomCam);
			//_zoomCam.follow(_me, FlxCamera.STYLE_TOPDOWN, null, 5);

			FlxTween.tween(FlxG.camera.scroll,{y:tweenCameraY},2.0,{ease:FlxEase.quadInOut});

			//FlxTween.tween(_emitter.yPosition,{min:tweenEmitterY},2.0,{ease:FlxEase.quadInOut});
			//FlxTween.tween(_emitter.yPosition,{max:tweenEmitterY+FlxG.height},2.0,{ease:FlxEase.quadInOut});
			
			//FlxTween.tween(FlxG.camera,{targetZoom:2},2.0,{ease:FlxEase.quadInOut});
			//_zoomCam.targetZoom = 2;
			//FlxTween.tween(FlxG.camera,{zoom:2},2,{ease:FlxEase.quadInOut});

			//FlxTween.tween(_zoomCam,{y:tweenCameraY},2.0,{ease:FlxEase.quadInOut});
			FlxTween.tween(_zoomCam,{targetZoom:2},2.0,{ease:FlxEase.quadInOut});
			//FlxTween.tween(_text1,{y:tweenText1Y},2.0,{ease:FlxEase.quadInOut});
			//FlxTween.tween(_text2,{y:tweenText2Y},2.0,{ease:FlxEase.quadInOut});
		}
		
		if (FlxG.keys.justPressed.ONE) _zoomCam.targetZoom += -0.25; // zoom in
        if (FlxG.keys.justPressed.TWO) _zoomCam.targetZoom += 0.25; // zoom out

        //if (FlxG.keys.justPressed.ONE) FlxG.camera.zoom += -0.25; // zoom in
        //if (FlxG.keys.justPressed.TWO) FlxG.camera.zoom += 0.25; // zoom out

		super.update();

		FlxG.collide(_emitter,_group);
		if (_me!=null)
		{
			FlxG.collide(_me,_group);
			//FlxG.collide(_me,_cameraWall);
			_emitter.yPosition.min = _me.y + FlxG.height/2;
			_emitter.yPosition.max = _me.y + 3*FlxG.height/2;
			_emitter.xPosition.min = _me.x - FlxG.width/2;
			_emitter.xPosition.max = _me.x + FlxG.width/2;
			
		}
	}
	
	private function titleFadeDone(Tween:FlxTween):Void
	{
		FlxG.camera.follow(_me,FlxCamera.STYLE_LOCKON,null,5);
		_me.solid = true;
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