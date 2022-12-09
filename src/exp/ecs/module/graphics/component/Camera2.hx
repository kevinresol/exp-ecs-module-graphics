package exp.ecs.module.graphics.component;

/**
	2D Camera
**/
class Camera2 implements Component {
	/** 
		Screen coordinates: where to put the rendered image on screen
	**/
	public var window:Rect;
}

@:structInit
class Rect {
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;
}
