package exp.ecs.module.graphics.system;

#if kha
import kha.Scheduler;

private typedef Context = {
	g2:kha.graphics2.Graphics,
	font:kha.Font,
}
#end

/**
 * Render debug info on screen
 */
@:nullSafety(Off)
class RenderDebug extends System {
	public var x:Int;
	public var y:Int;
	public var context:Context;

	var count:Int;

	public function new(x, y, context) {
		this.x = x;
		this.y = y;
		this.context = context;
	}

	override function initialize(world:World) {
		return tink.state.Observable.auto(world.entities.count).bind(count -> this.count = count);
	}

	override function update(dt:Float) {
		final text = 'Entity Count: $count';

		#if kha
		final g2 = context.g2;
		g2.begin(false);
		g2.font = context.font;
		g2.transformation.setFrom(kha.math.FastMatrix3.identity());
		g2.color = kha.Color.Black;
		g2.drawString(text, x + 1, y + 1);
		g2.color = kha.Color.White;
		g2.drawString(text, x, y);
		g2.end();
		#end
	}
}
