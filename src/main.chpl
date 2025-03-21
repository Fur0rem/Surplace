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
use MaterialModule;

config const width: uint = 512;
config const height: uint = 512;
config const output_name: string = "renders/output_1";

proc main() {

    writeln("nb gpus: ", here.gpus.size);

    // TODO: fix issue with coordinate system
    // For now : +Y = left, +X = down, +Z = forward
    var camera = new Camera(
        origin = new Vec3(0.0, 0.0, -3.0)
    );

    /*{
        var obj1 = new Object(
            shape_tag = ShapeTag.Mandelbulb,
            shape_value = new ShapeValue(),
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(0.5, 1.0, 1.0),
            position = new Vec3(-0.3, 0.0, 1.0),
            material = new Material(Colour.RED, 1.0)
        );
        obj1.shape_value.mandelbulb = (100, 8.0);

        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(200.0, 200.0, 200.0),
            position = new Vec3(0.0, -100.5, 1.0),
            material = new Material(Colour.LIME, 1.0)
        );

        const obj3 = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(1.0, 0.0, 0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.8, 0.0, 1.0),
            material = new Material(Colour.BLUE, 1.0)
        );

        // const obj1 = new Object(
        //     shape_tag = ShapeTag.Sphere,
        //     rotation = new Vec3(0.0,0.0,0.0),
        //     scale = new Vec3(200.0, 200.0, 200.0),
        //     position = new Vec3(0.0, -101.0, -3.0),
        //     material = Colour.RED
        // );

        var leaf1 = Leaf(obj2);
        var leaf2 = Leaf(obj1);
        var leaf3 = Leaf(obj3);
        var op = SmoothUnion(0.2);
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

        // const renderedimage = scene.render(camera, width, height);
        // renderedimage.save(output_name);
    }

    {
        const obj1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.1, 1.2, 1.1),
            position = new Vec3(0.0, 0.05, 1.0),
            material = new Material(Colour.WHITE, 1.0)
        );
        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(0.5, 0.4, 0.5),
            position = new Vec3(0.0, -0.7, 1.0),
            material = new Material(Colour.LIGHT_BLUE, 1.0)
        );
        const obj3 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(0.1, 0.05, 0.1),
            position = new Vec3(0.0, -0.92, 1.0),
            material = new Material(Colour.PINK, 1.0)
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
        
        // const renderedimage = scene.render(camera, width, height);
        // renderedimage.save("renders/output_2");
    }

    // {
    //     var test = new Object(
    //         shape_tag = ShapeTag.Sphere,
    //         rotation = new Vec3(0.0, 0.0, 0.0),
    //         scale = new Vec3(0.5, 0.5, 0.5),
    //         position = new Vec3(0.0, 0.0, -7.0),
    //         material = new Material(Colour.RED, 1.0)
    //     );
    //     var p = test.map_point(new Vec3(0.0, 0.0, 0.0));
    //     writeln(p);

    //     test = new Object(
    //         shape_tag = ShapeTag.Cube,
    //         rotation = new Vec3(0.0, 0.0, 0.0),
    //         scale = new Vec3(1.1, 1.2, 1.1),
    //         position = new Vec3(0.0, 0.05, -7.0),
    //         material = new Material(Colour.WHITE, 1.0)
    //     );
    //     p = test.map_point(new Vec3(1.0, 1.0, 1.0));
    //     writeln(p);
    // }

    {
        const obj1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(-1.0, 0.0, 1.0),
            material = new Material(Colour.RED, 1.0)
        );
        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(1.0, 0.0, 1.0),
            material = new Material(Colour.RED, 0.5)
        );
        const op = Union();
        const leaf1 = Leaf(obj1);
        const leaf2 = Leaf(obj2);
        const scene = Node(
            op, leaf1, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_3");
    }

    {
        // const obj1 = new Object(
        //     shape_tag = ShapeTag.Sphere,
        //     rotation = new Vec3(0.0,0.0,0.0),
        //     scale = new Vec3(1.0, 1.0, 1.0),
        //     position = new Vec3(-0.4, 0.0, 2.0),
        //     material = new Material(Colour.RED, 0.3)
        // );
        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(-5.0, 0.0, 30.0),
            material = new Material(Colour.WHITE, 0.3)
        );
        const obj3 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.5, 0.0, 1.0),
            material = new Material(Colour.GREEN, 0.5)
        );
        // const op = Union();
        // const leaf1 = Leaf(obj1);
        // const leaf2 = Leaf(obj2);
        // const leaf3 = Leaf(obj3);
        // const op2 = Union();
        // const scene1 = Node(
        //     op, leaf1, leaf2
        // );
        // const scene = Node(
        //     op2, scene1, leaf3
        // );
        const leaf1 = Leaf(obj2);
        const leaf2 = Leaf(obj3);
        const op = Union();
        const scene = Node(
            op, leaf1, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_4");
    }*/

    {
        const obj1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(-0.5, 0.0, 1.0),
            material = new Material(Colour.RED, 1.0, 0.0)
        );
        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.5, 0.0, 1.0),
            material = new Material(Colour.RED, 0.000005, 0.0)
        );
        const op = SmoothUnion(1.0);
        const leaf1 = Leaf(obj1);
        const leaf2 = Leaf(obj2);
        const scene = Node(
            op, leaf1, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_5");
    }

    /*{
        const obj1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.5, 1.5, 1.5),
            position = new Vec3(0.0, 0.0, 1.0),
            material = new Material(Colour.RED, 1.0)
        );

        const obj2 = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.0, 0.0, 1.0),
            material = new Material(Colour.BLUE, 1.0)
        );

        const op = SmoothUnion(0.5);
        const leaf1 = Leaf(obj1);
        const leaf2 = Leaf(obj2);

        const scene = Node(
            op, leaf1, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_6");
    }*/

    {
        const floor = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(0.0, -30.0, 0.0),
            material = new Material(Colour.LIME, 1.0, 0.0)
        );

        const ceiling = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(0.0, 30.0, 0.0),
            material = new Material(Colour.PINK, 1.0, 0.0)
        );

        const back_wall = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(0.0, 0.0, 30.0),
            material = new Material(Colour.WHITE, 1.0, 0.0)
        );

        const left_wall = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(-30.0, 0.0, 0.0),
            material = new Material(Colour.RED, 1.0, 0.0)
        );

        const right_wall = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(30.0, 30.0, 30.0),
            position = new Vec3(30.0, 0.0, 0.0),
            material = new Material(Colour.BLUE, 1.0, 0.0)
        );

        const front_wall = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(20.0, 20.0, 20.0),
            position = new Vec3(0.0, 0.0, -40.0),
            material = new Material(Colour.WHITE, 1.0, 0.0)
        );

        const sphere1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(-2.0, 0.0, 2.0),
            material = new Material(Colour.RED, 1.0, 0.0)
        );

        const sphere2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(2.0, 0.0, 2.0),
            material = new Material(Colour.BLUE, 1.0, 0.0)
        );

        const sphere3 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(0.0, 0.0, 2.0),
            material = new Material(Colour.GREEN, 1.0, 0.0)
        );

        const light = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.0, 5.0, 2.0),
            material = new Material(Colour.ORANGE, 1.0, 5.0)
        );

        const u1 = Union();
        const u2 = Union();
        const u3 = Union();
        const u4 = Union();
        const u5 = Union();
        const u6 = Union();
        const u7 = Union();
        const su1 = SmoothUnion(1.5);
        const su2 = SmoothUnion(1.5);
        
        const leaf1 = Leaf(floor);
        const leaf2 = Leaf(ceiling);
        const leaf3 = Leaf(back_wall);
        const leaf4 = Leaf(left_wall);
        const leaf5 = Leaf(right_wall);
        const leaf6 = Leaf(front_wall);
        const leaf7 = Leaf(sphere1);
        const leaf8 = Leaf(sphere2);
        const leaf9 = Leaf(sphere3);
        const leaf10 = Leaf(light);
        
        const n1 = Node(su1, leaf7, leaf8);
        const n2 = Node(su2, leaf9, n1);
        const n3 = Node(u5, leaf10, n2);
        const n4 = Node(u6, n3, leaf6);
        const n5 = Node(u4, n4, leaf5);
        const n6 = Node(u3, n5, leaf4);
        const n7 = Node(u2, n6, leaf3);
        const n8 = Node(u1, n7, leaf2);
        const scene = Node(u7, n8, leaf1);        

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_7");

    }

    {
        const sphere1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(-2.0, 0.0, 2.0),
            material = new Material(Colour.RED, 0.5, 0.0)
        );

        const sphere2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(2.0, 0.0, 2.0),
            material = new Material(Colour.BLUE, 1.0, 0.0)
        );

        const sphere3 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(0.0, 0.0, 2.0),
            material = new Material(Colour.GREEN, 0.2, 0.0)
        );

        const su1 = SmoothUnion(1.2);
        const su2 = SmoothUnion(1.2);
        
        const leaf7 = Leaf(sphere1);
        const leaf8 = Leaf(sphere2);
        const leaf9 = Leaf(sphere3);
        
        const n1 = Node(su1, leaf7, leaf8);
        const scene = Node(su2, leaf9, n1);

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/to_fix");

    }
    
    {
        const sphere1 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(0.0, 0.0, 2.0),
            material = new Material(Colour.RED, 0.001, 0.0)
        );

        const sphere3 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.0, 0.0, 2.0),
            material = new Material(Colour.BLUE, 1.0, 0.0)
        );

        const su1 = SmoothUnion(1.5);
        
        const leaf7 = Leaf(sphere1);
        const leaf9 = Leaf(sphere3);
        
        const scene = Node(su1, leaf7, leaf9);

        const renderedimage = scene.render(camera, width / 2, height / 2);
        renderedimage.save("renders/to_fix2");

    }

    {
        const cube = new Object(
            shape_tag = ShapeTag.Cube,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(2.0, 0.0, 2.0),
            material = new Material(Colour.WHITE, 0.5, 0.0)
        );
        
        const sphere = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(-2.0, 0.0, 2.0),
            material = new Material(Colour.BLUE, 0.3, 0.0)
        );

        const u = Union();
        const leaf = Leaf(cube);
        const leaf2 = Leaf(sphere);
        const scene = Node(
            u, leaf, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/to_fix3");
    }
    
    {
        var truc = new Object(
            shape_tag = ShapeTag.Mandelbulb,
            shape_value = new ShapeValue(),
            rotation = new Vec3(0.0, 0.0, 0.0),
            scale = new Vec3(2.0, 2.0, 2.0),
            position = new Vec3(2.0, 0.0, 2.0),
            material = new Material(Colour.WHITE, 0.2, 0.0)
        );
        truc.shape_value.mandelbulb = (2, 6.0);

        const scene = Leaf(truc);

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/test2");
    }

    {
        var obj1 = new Object(
            shape_tag = ShapeTag.Mandelbulb,
            shape_value = new ShapeValue(),
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.5, 1.5, 1.5),
            position = new Vec3(0.0, 0.0, 1.0),
            material = new Material(Colour.BLUE, 1.0, 5.0)
        );
        obj1.shape_value.mandelbulb = (100, 8.0);

        // const obj2 = new Object(
        //     shape_tag = ShapeTag.Cube,
        //     rotation = new Vec3(0.0,0.0,0.0),
        //     scale = new Vec3(1.0, 1.0, 1.0),
        //     position = new Vec3(0.0, 0.0, 1.0),
        //     material = new Material(Colour.BLUE, 1.0)
        // );

        // const op = SmoothUnion(0.5);
        // const leaf1 = Leaf(obj1);
        // const leaf2 = Leaf(obj2);

        const obj2 = new Object(
            shape_tag = ShapeTag.Sphere,
            rotation = new Vec3(0.0,0.0,0.0),
            scale = new Vec3(1.0, 1.0, 1.0),
            position = new Vec3(0.0, 0.0, 10.0),
            material = new Material(Colour.RED, 1.0, 0.0)
        );

        const op = SmoothUnion(0.5);
        const leaf1 = Leaf(obj1);
        const leaf2 = Leaf(obj2);

        const scene = Node(
            op, leaf1, leaf2
        );

        const renderedimage = scene.render(camera, width, height);
        renderedimage.save("renders/output_8");
    }

}