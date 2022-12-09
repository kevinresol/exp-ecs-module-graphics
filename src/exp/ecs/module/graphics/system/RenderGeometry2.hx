package exp.ecs.module.graphics.system;

import exp.ecs.NodeList;
import exp.ecs.system.*;
import exp.ecs.module.geometry.component.*;
import exp.ecs.module.graphics.component.*;
import exp.ecs.module.transform.component.*;
#if kha
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

private typedef Context = {
	g2:kha.graphics2.Graphics,
}
#end

private typedef CameraComponents = {
	final camera:Camera2;
	final ?transform:Transform2;
}

private typedef Components = {
	final transform:Transform2;
	final rectangle:Rectangle;
	final circle:Circle;
	final polygon:Polygon;
	final color:Color;
}

private typedef Specs = {
	final cameras:NodeListSpec<CameraComponents>;
	final nodes:NodeListSpec<Components>;
}

/**
 * Render 2D geometries
 */
@:nullSafety(Off)
class RenderGeometry2 extends System {
	public var context:Context;

	final specs:Specs;

	var cameras:NodeList<CameraComponents>;
	var nodes:NodeList<Components>;

	public function new(context:Context) {
		this.context = context;

		this.specs = {
			cameras: NodeList.spec(@:component(camera) Camera2 && @:component(transform) ~Transform2),
			nodes: NodeList.spec(@:component(transform) Transform2 && (Rectangle || Circle || Polygon) && Color),
		}
	}

	override function initialize(world:World) {
		return
			// @formatter:off
			NodeList.make(world, specs.cameras).bind(v -> this.cameras = v, tink.state.Scheduler.direct) & 
			NodeList.make(world, specs.nodes).bind(v -> this.nodes = v, tink.state.Scheduler.direct);
			// @formatter:on
	}

	override function update(dt:Float) {
		#if kha
		final g2 = context.g2;
		final view = FastMatrix3.identity();

		g2.begin(false);
		for (camera in cameras) {
			final window = camera.data.camera.window;
			final projection = FastMatrix3.translation(window.x, window.y);

			// NOTE: don't factorize view.setFrom outside the switch, to avoid allocation
			switch camera.data.transform {
				case null:
					view.setFrom(FastMatrix3.identity());
				case cam:
					view.setFrom(convertMatrix(cam.global));
			}

			g2.scissor(Std.int(window.x), Std.int(window.y), Std.int(window.w), Std.int(window.h));

			for (node in nodes) {
				final model = convertMatrix(node.data.transform.global);
				g2.transformation.setFrom(projection.multmat(view).multmat(model));
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
						if (vertices.length > 0) {
							final v = vertices[0];
							g2.drawLine(0, 0, v.x, v.y, 2); // point to first vertex to indicate rotation
							g2.drawPolygon(0, 0, vertices, 2);
						} else {
							// consider throwing something for debug purpose
						}
				}
				// g2.popTransformation();
			}

			// g2.popTransformation();
			g2.disableScissor();
		}

		g2.end();
		#end
	}

	#if kha
	static inline function convertMatrix(matrix:Transform2.MatrixView3x3):FastMatrix3 {
		return new FastMatrix3(matrix.m00, matrix.m10, matrix.m20, matrix.m01, matrix.m11, matrix.m21, matrix.m02, matrix.m12, matrix.m22);
	}
	#end
}
