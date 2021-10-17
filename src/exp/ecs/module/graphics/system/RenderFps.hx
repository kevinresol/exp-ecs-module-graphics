package exp.ecs.module.graphics.system;

#if kha
import kha.Scheduler;

private typedef Context = {
	g2:kha.graphics2.Graphics,
	font:kha.Font,
}
#end

/**
 * Render FPS on screen
 */
@:nullSafety(Off)
class RenderFps extends System {
	public var x:Int;
	public var y:Int;
	public var context:Context;

	public function new(x, y, context) {
		this.x = x;
		this.y = y;
		this.context = context;
	}

	override function update(dt:Float) {
		final text = 'FPS: ${Math.round(1 / dt)}';

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
