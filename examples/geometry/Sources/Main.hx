package;

import exp.ecs.*;
import exp.ecs.module.transform.component.*;
import exp.ecs.module.geometry.component.*;
import exp.ecs.module.graphics.component.*;
import exp.ecs.module.transform.system.*;
import exp.ecs.module.geometry.system.*;
import exp.ecs.module.graphics.system.*;
import hxmath.math.*;

class Main {
	static final WIDTH = 1024;
	static final HEIGHT = 768;
	static final GRID_W = 6;
	static final GRID_H = 6;

	static function main() {
		kha.System.start({
			title: "Render Geometry Example",
			width: WIDTH,
			height: HEIGHT,
			framebuffer: {samplesPerPixel: 4}
		}, _ -> {
			// Just loading everything is ok for small projects
			kha.Assets.loadEverything(() -> {
				final engine = new exp.ecs.Engine();
				final world = engine.worlds.create([
					//
					{id: FixedUpdate, type: FixedTimestep(1 / 100)}, //
					Update, //
					Render, //
				]);

				final renderContext:{g2:kha.graphics2.Graphics, font:kha.Font} = {
					g2: null,
					font: kha.Assets.fonts.kenney_mini,
				}

				initEntities(world);
				initSystems(world, renderContext);

				// game loop
				var time = kha.Scheduler.time();
				kha.System.notifyOnFrames(frames -> {
					final g2 = renderContext.g2 = frames[0].g2;

					final now = kha.Scheduler.time();
					final dt = now - time;

					g2.begin(true, 0);
					g2.end();

					engine.update(dt);
					time = now;
				});
			});
		});
	}

	static function initEntities(world:World) {
		function createScreen(x, y, w, h) {
			final entity = world.entities.create();
			entity.add(Screen2, x, y, w, h);
			return entity;
		}
		function createCamera(x, y, r) {
			final entity = world.entities.create();
			entity.add(Camera2, 100, 100);
			entity.add(Transform2, new Vector2(x, y), r);
			return entity;
		}

		for (x in 0...GRID_W)
			for (y in 0...GRID_H) {
				final square = world.entities.create();
				square.add(Transform2, new Vector2(x * 50 + 25, y * 50 + 25));
				square.add(Color, 0xff << 24 | Std.int(x * 255 / GRID_W) << 16 | Std.int(y * 255 / GRID_H) << 8 | Std.int((GRID_W - x) * 255 / GRID_W));
				square.add(Rectangle, 47, 47);
			}

		final screens = [
			createScreen(WIDTH / 4, HEIGHT / 4, WIDTH / 2, HEIGHT / 2),
			createScreen(WIDTH * 3 / 4, HEIGHT / 4, WIDTH / 2, HEIGHT / 2),
			createScreen(WIDTH / 4, HEIGHT * 3 / 4, WIDTH / 2, HEIGHT / 2),
			createScreen(WIDTH * 3 / 4, HEIGHT * 3 / 4, WIDTH / 2, HEIGHT / 2),
		];

		final cameras = [
			createCamera(0, 0, 0),
			createCamera(-25, -25, Math.PI / 4),
			createCamera(50, 50, 0),
		];

		screens[0].link('camera', cameras[0]);
		screens[1].link('camera', cameras[1]);
		screens[2].link('camera', cameras[1]);
		screens[3].link('camera', cameras[2]);
	}

	static function initSystems(world:World, renderContext:{g2:kha.graphics2.Graphics, font:kha.Font}) {
		// systems
		world.pipeline.add(FixedUpdate, new ComputeLocalTransform2());
		world.pipeline.add(FixedUpdate, new ComputeGlobalTransform2());

		// ========== Rendering ==========

		world.pipeline.add(Render, new RenderGeometry2(renderContext));
		world.pipeline.add(Render, new RenderFps(10, 10, renderContext));
		world.pipeline.add(Render, new RenderDebug(10, 30, renderContext));
	}
}

@:transitive
enum abstract Phase(Int) to Int {
	final FixedUpdate;
	final Update;
	final Render;
}
