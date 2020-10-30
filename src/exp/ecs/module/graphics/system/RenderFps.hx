package exp.ecs.module.graphics.system;

import kha.Scheduler;

/**
 * Render FPS on screen
 */
@:nullSafety(Off)
class RenderFps extends System {
	public var frame:kha.Framebuffer;
	public var font:kha.Font;
	public var x:Int;
	public var y:Int;

	public function new(font, x, y) {
		this.font = font;
		this.x = x;
		this.y = y;
	}

	override function update(dt:Float) {
		final g2 = frame.g2;
		final fps = 'FPS: ${Math.round(1 / dt)}';

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
