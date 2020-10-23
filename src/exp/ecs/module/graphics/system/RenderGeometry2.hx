package exp.ecs.module.graphics.system;

import exp.ecs.module.geometry.component.*;
import exp.ecs.module.graphics.component.*;
import exp.ecs.module.transform.component.*;

using kha.graphics2.GraphicsExtension;

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

	final list:NodeList<Components>;
	var nodes:Array<Node<Components>>;

	public function new(list) {
		this.list = list;
	}

	override function initialize() {
		return list.bind(v -> nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		final g2 = frame.g2;
		// g2.begin(true, kha.Color.fromBytes(0, 95, 106));
		g2.begin(false);

		for (node in nodes) {
			final transform = node.components.transform.global;

			g2.transformation = new kha.math.FastMatrix3(
				// @formatter:off
				transform.m00, transform.m10, transform.m20,
				transform.m01, transform.m11, transform.m21,
				transform.m02, transform.m12, transform.m22
				// @formatter:on
			);
			g2.color = node.components.color.value;

			switch node.components.rectangle {
				case null:
				case rectangle:
					g2.drawRect(-rectangle.width / 2, -rectangle.height / 2, rectangle.width, rectangle.height, 2);
					g2.drawLine(0, 0, 0, -rectangle.height / 2, 2); // indicate upright direction
			}

			switch node.components.circle {
				case null:
				case {radius: radius}:
					g2.drawCircle(0, 0, radius, 2, 8);
					g2.drawLine(0, 0, 0, -radius, 2); // indicate upright direction
			}
		}
		g2.end();
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world, @:field(transform) Transform2 && (Rectangle || Circle) && Color);
		// @formatter:on
	}
}
