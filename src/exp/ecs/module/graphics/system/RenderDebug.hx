package exp.ecs.module.graphics.system;

import kha.Scheduler;

/**
 * Render debug info on screen
 */
@:nullSafety(Off)
class RenderDebug extends System {
	public var frame:kha.Framebuffer;
	public var font:kha.Font;
	public var x:Int;
	public var y:Int;

	var count:Int;
	var time = Scheduler.time();

	public function new(font, x, y) {
		this.font = font;
		this.x = x;
		this.y = y;
	}

	override function initialize(world:World) {
		return tink.state.Observable.auto(world.entities.count).bind(count -> this.count = count);
	}

	override function update(dt:Float) {
		final g2 = frame.g2;

		final now = Scheduler.time();
		final fps = 'Entity Count: $count';
		time = now;

		g2.begin(false);
		g2.font = font;
		g2.transformation.setFrom(kha.math.FastMatrix3.identity());
		g2.color = kha.Color.Black;
		g2.drawString(fps, x + 1, y + 1);
		g2.color = kha.Color.White;
		g2.drawString(fps, x, y);
		g2.end();
	}
}
