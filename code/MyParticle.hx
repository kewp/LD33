package ;

import flixel.util.FlxRandom;
import flixel.effects.particles.FlxParticle;
import flixel.text.FlxText;

class MyParticle extends FlxParticle
{
	private static var colors:Array<Int> = [0xFF444444,0x55888888,0x88CCCCCC];
	private var _text:FlxText;

	public function new()
	{
		super();
		makeGraphic(32,32,colors[Std.int(FlxRandom.float() * colors.length)],true);
		
		_text = new FlxText(0,10,32,String.fromCharCode("a".charCodeAt(0)+Std.random(26)));//String.fromCharCode(Std.random(26)+"a".charCodeAt(0)));
		_text.setFormat("assets/cour.ttf", 32, 0xffffffff, "center");
		_text.exists = false;


		solid = true;
		on();
		stamp(_text);
	}

	public function on()
	{
		_text.exists = true;
	}

	override public function draw()
	{
		//if (_text.exists) stamp(_text);
		super.draw();
	}
}