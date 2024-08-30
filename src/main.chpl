import Colour.RGB;
import Colour;
import Camera.Camera;
use Vector;
import IO.FormattedIO;
use Object;
import Ray.Ray;
use Rendering;
use Math;

config const width: uint = 256;
config const height: uint = 256;
config const output_name: string = "renders/output_1";

proc main() {

    // TODO: fix issue with coordinate system
    // For now : +Y = left, +X = down, +Z = forward
    var camera = new Camera(
        origin = new Vec3(0.0, 0.0, -1.0),
        direction = new Vec3(0.0, 0.0, 1.0)
    );
    camera.direction.normalise();

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

    const scene = new Scene(objects = [obj1, obj2]);

    const renderedimage = scene.render(camera, width, height);

    renderedimage.save(output_name);
}