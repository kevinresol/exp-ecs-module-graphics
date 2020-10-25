package exp.ecs.module.graphics.system;

import kha.Scheduler;

/**
 * Render FPS on screen
 */
@:nullSafety(Off)
class RenderFps extends System {
	public var frame:kha.Framebuffer;

	var time = Scheduler.time();

	public function new() {}

	override function update(dt:Float) {
		final g2 = frame.g2;

		final now = Scheduler.time();
		final fps = 'FPS: ${Math.round(1 / (now - time))}';
		time = now;

		g2.begin(false);
		g2.transformation.setFrom(kha.math.FastMatrix3.identity());
		g2.font = kha.Assets.fonts.kenney_mini;
		g2.color = kha.Color.Black;
		g2.drawString(fps, 11, 11);
		g2.color = kha.Color.White;
		g2.drawString(fps, 10, 10);
		g2.end();
	}
}
