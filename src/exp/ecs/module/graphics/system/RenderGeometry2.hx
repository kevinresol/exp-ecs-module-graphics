package exp.ecs.module.graphics.system;

import exp.ecs.system.*;
import exp.ecs.module.geometry.component.*;
import exp.ecs.module.graphics.component.*;
import exp.ecs.module.transform.component.*;

#if kha
using kha.graphics2.GraphicsExtension;

private typedef Context = {
	g2:kha.graphics2.Graphics,
}
#end

private typedef Components = {
	final transform:Transform2;
	final rectangle:Rectangle;
	final circle:Circle;
	final polygon:Polygon;
	final color:Color;
}

/**
 * Render 2D geometries
 */
@:nullSafety(Off)
class RenderGeometry2 extends SingleListSystem<Components> {
	public var context:Context;

	public function new(context) {
		super(NodeList.spec(@:component(transform) Transform2 && (Rectangle || Circle || Polygon) && Color));
		this.context = context;
	}

	override function update(dt:Float) {
		#if kha
		final g2 = context.g2;

		g2.begin(false);
		final g2transform = g2.transformation;

		for (node in nodes) {
			final transform = node.data.transform.global;

			// @formatter:off
			g2transform._00 = transform.m00; g2transform._10 = transform.m10; g2transform._20 = transform.m20;
			g2transform._01 = transform.m01; g2transform._11 = transform.m11; g2transform._21 = transform.m21;
			g2transform._02 = transform.m02; g2transform._12 = transform.m12; g2transform._22 = transform.m22;
			
			// @formatter:on
			g2.color = node.data.color.value;

			switch node.data.rectangle {
				case null:
				case rectangle:
					g2.drawRect(-rectangle.width / 2, -rectangle.height / 2, rectangle.width, rectangle.height, 2);
					g2.drawLine(0, 0, rectangle.width / 2, 0, 2); // point towards angle = 0
			}

			switch node.data.circle {
				case null:
				case {radius: radius}:
					g2.drawCircle(0, 0, radius, 2, 32);
					g2.drawLine(0, 0, radius, 0, 2); // point towards angle = 0
			}

			switch node.data.polygon {
				case null:
				case {vertices: vertices}:
					final v = vertices[0];
					g2.drawLine(0, 0, v.x, v.y, 2); // point to first vertex to indicate rotation
					g2.drawPolygon(0, 0, vertices, 2);
			}
		}
		g2.end();
		#end
	}
}
