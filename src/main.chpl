import Colour.RGB;
import Colour;
import Camera.Camera;
use Vector;
import IO.FormattedIO;
use Object;
import Ray.Ray;
use Rendering;
use Math;
use SceneModule;

config const width: uint = 256;
config const height: uint = 256;
config const output_name: string = "renders/output_1";

proc main() {

    // TODO: fix issue with coordinate system
    // For now : +Y = left, +X = down, +Z = forward
    var camera = new Camera(
        origin = new Vec3(0.0, 0.0, -1.0)
    );

    const obj1 = new Object(
        shape = Shape.Sphere,
        rotation = new Vec3(0.0, 0.0, 0.0),
        scale = new Vec3(0.5, 1.0, 1.0),
        position = new Vec3(0.0, 0.0, 1.0),
        colour = Colour.RED
    );

    const obj2 = new Object(
        shape = Shape.Sphere,
        rotation = new Vec3(0.0,0.0,0.0),
        scale = new Vec3(200.0, 200.0, 200.0),
        position = new Vec3(0.0, -100.5, 1.0),
        colour = Colour.LIME
    );

    var leaf1 = Leaf(obj1);
    var leaf2 = Leaf(obj2);
    var leaf3 = Leaf(obj2);
    var op = SmoothUnion(0.5);
    var op2 = SmoothUnion(1.0);
    var node1 = Node(op2, leaf2, leaf3);
    var node = Node(op, leaf1, node1);

    if node.isANode() {
        writeln("Operation: ", node.getOperation().tag);
        writeln("Node with left value: ", node.getLeft()!.getLeafValue());
        writeln("Node with right value: ", node.getRight()!.getOperation());
    }

    const scene = new LinearScene(objects = [obj1, obj2]);

    const renderedimage = scene.render(camera, width, height);

    renderedimage.save(output_name);
}