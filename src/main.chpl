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

config const width: uint = 512;
config const height: uint = 512;
config const output_name: string = "renders/output_1";

proc main() {

    // TODO: fix issue with coordinate system
    // For now : +Y = left, +X = down, +Z = forward
    var camera = new Camera(
        origin = new Vec3(0.0, 0.0, -1.0)
    );

    /*{
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

        const obj3 = new Object(
            shape = Shape.Cube,
            rotation = new Vec3(1.0, 0.0, 0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.8, 0.0, 1.0),
            colour = Colour.BLUE
        );

        // const obj1 = new Object(
        //     shape = Shape.Sphere,
        //     rotation = new Vec3(0.0,0.0,0.0),
        //     scale = new Vec3(200.0, 200.0, 200.0),
        //     position = new Vec3(0.0, -101.0, -3.0),
        //     colour = Colour.RED
        // );

        var leaf1 = Leaf(obj1);
        var leaf2 = Leaf(obj2);
        var leaf3 = Leaf(obj3);
        var op = SmoothUnion(1.2);
        var op2 = SmoothUnion(0.5);
        var node1 = Node(op2, leaf2, leaf3);
        var node = Node(op, leaf1, node1);

        // var leaf1 = Leaf(obj1);
        // var leaf2 = Leaf(obj2);
        // var op = SmoothUnion(1.0);
        // var node = Node(op, leaf1, leaf2);

        // if node.isANode() {
        //     writeln("Operation: ", node.getOperation().tag);
        //     writeln("Node with left value: ", node.getLeft()!.getLeafValue());
        //     writeln("Node with right value: ", node.getRight()!.getLeafValue());
        // }
        // writeln("going to ray march now");

        // const scene = new LinearScene(objects = [obj1, obj2]);
        const scene = node;

        const renderedimage = scene.render(camera, width, height);

        renderedimage.save(output_name);
    }*/

    {
        const obj1 = new Object(
            shape = Shape.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.1, 1.2, 1.1),
            position = new Vec3(0.0, 0.05, 1.0),
            colour = Colour.WHITE
        );
        const obj2 = new Object(
            shape = Shape.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(0.5, 0.4, 0.5),
            position = new Vec3(0.0, -0.7, 1.0),
            colour = Colour.LIGHT_BLUE
        );
        const obj3 = new Object(
            shape = Shape.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(0.1, 0.05, 0.1),
            position = new Vec3(0.0, -0.92, 1.0),
            colour = Colour.PINK
        );
        const leaf1 = Leaf(obj1);
        const leaf2 = Leaf(obj2);
        const op = SmoothUnion(0.33);
        const leaf3 = Leaf(obj3);
        const o = Node(
            op,
            leaf1, leaf2
        );
        const op2 = SmoothUnion(0.01);
        const scene = Node(
            op2, leaf3, o
        );

        // const ray = camera.ray(width / 2, height / 2, width, height);
        // const ray = new Ray(
            // origin = new Vec3(0.0, 0.0, 1.0),
            // direction = new Vec3(0.0, 0.0, -1.0)
        // );
        // writeln("ray = ", ray);
        // const dist = scene.distance(ray);
        // writeln("dist = ", dist);
        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_2");
    }

    // {
    //     var test = new Object(
    //         shape = Shape.Sphere,
    //         rotation = new Vec3(0.0, 0.0, 0.0),
    //         scale = new Vec3(0.5, 0.5, 0.5),
    //         position = new Vec3(0.0, 0.0, -7.0),
    //         colour = Colour.RED
    //     );
    //     var p = test.map_point(new Vec3(0.0, 0.0, 0.0));
    //     writeln(p);

    //     test = new Object(
    //         shape = Shape.Cube,
    //         rotation = new Vec3(0.0, 0.0, 0.0),
    //         scale = new Vec3(1.1, 1.2, 1.1),
    //         position = new Vec3(0.0, 0.05, -7.0),
    //         colour = Colour.WHITE
    //     );
    //     p = test.map_point(new Vec3(1.0, 1.0, 1.0));
    //     writeln(p);
    // }
}