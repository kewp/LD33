package ;

import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;

class MyObject extends FlxSprite
{
	public function new(x:Float,y:Float)
	{
		super(x,y);
		makeGraphic(32,32,0xFFFFFFFF);
	}

	override public function update():Void 
	{
		angularVelocity = 0;
		
		if (FlxG.keys.anyPressed(["A", "LEFT"]))
		{
			angularVelocity -= 240;
		}
		
		if (FlxG.keys.anyPressed(["D", "RIGHT"]))
		{
			angularVelocity += 240;
		}
		
		acceleration.set();
		
		if (FlxG.keys.anyPressed(["W", "UP"]))
		{
			FlxAngle.rotatePoint(90, 0, 0, 0, angle, acceleration);
		}
		
		super.update();
	}
}