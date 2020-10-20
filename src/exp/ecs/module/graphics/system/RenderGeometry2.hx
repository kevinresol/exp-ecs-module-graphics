package exp.ecs.module.graphics.system;

import exp.ecs.module.geometry.component.*;
import exp.ecs.module.graphics.component.*;
import exp.ecs.module.transform.component.*;

private typedef Components = {
	final transform:Transform2;
	final rectangle:Rectangle;
	final circle:Circle;
	final color:Color;
}

/**
 * Render 2D geometries
 */
@:nullSafety(Off)
class RenderGeometry2 extends System {
	static final SIN_TABLE = [for (i in 0...32) Math.sin(Math.PI * 2 * i / 32)];
	static final COS_TABLE = [for (i in 0...32) Math.cos(Math.PI * 2 * i / 32)];

	public var frame:kha.Framebuffer;

	var nodes:Array<Node<Components>>;

	public function new(nodes:NodeList<Components>) {
		nodes.bind(v -> this.nodes = v, tink.state.Scheduler.direct);
	}

	static var printed = false;

	override function update(dt:Float) {
		final g2 = frame.g2;
		g2.begin(true, kha.Color.fromBytes(0, 95, 106));
		for (node in nodes) {
			final transform = node.components.transform.global;

			g2.transformation = new kha.math.FastMatrix3(
				// @formatter:off
				transform.m00, transform.m10, transform.m20,
				transform.m01, transform.m11, transform.m21,
				transform.m02, transform.m12, transform.m22
				// @formatter:on
			);
			g2.color = switch node.components.color {
				case null:
					kha.Color.Red;
				case {value: color}:
					color;
			}

			switch node.components.rectangle {
				case null:
				case rectangle:
					g2.drawRect(-rectangle.width / 2, -rectangle.height / 2, rectangle.width, rectangle.height, 2);
					g2.drawLine(0, 0, 0, -rectangle.height / 2, 2); // indicate upright direction
			}

			switch node.components.circle {
				case null:
				case {radius: radius}:
					var x1 = COS_TABLE[0] * radius;
					var y1 = SIN_TABLE[0] * radius;
					for (i in 0...32) {
						final index = (i + 1) % 32;
						final x2 = COS_TABLE[index] * radius;
						final y2 = SIN_TABLE[index] * radius;
						g2.drawLine(x1, y1, x2, y2, 2);
						x1 = x2;
						y1 = y2;
					}
					g2.drawLine(0, 0, 0, -radius, 2); // indicate upright direction
			}
		}
		g2.end();
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world, @:field(transform) Transform2 && (Rectangle || Circle) && ~Color);
		// @formatter:on
	}
}
