package ;

import flixel.effects.particles.FlxParticle;
import flixel.util.FlxRandom;
import flixel.FlxG;

class MyObject extends FlxParticle
{
	private static var colors:Array<Int> = [0xFF444444,0x55888888,0x88CCCCCC];

	public function new(color:Int = null)
	{
		super();
		if (color==null) color = colors[Std.int(FlxRandom.float() * colors.length)];
		makeGraphic(32,32,color);
		solid = true;
	}
}