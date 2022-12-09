package exp.ecs.module.graphics.component;

/**
	2D Camera

	Values indicates the capture area (in world coordinates).
	It should be transformed by a Transform2 component.
**/
class Camera2 implements Component {
	public var w:Float;
	public var h:Float;
}
