import Colour.RGB;
import Colour;
import Camera.Camera;
use Vector;
import IO.FormattedIO;
use Object;
import Ray.Ray;
use Rendering;
use Math;

config const width: uint = 512;
config const height: uint = 512;
config const output_name: string = "renders/output_1";

proc main() {
    var camera = new Camera(
        origin = new Vec3(0.0, 0.0, 0.0),
        direction = new Vec3(0.0, 0.0, 1.0)
    );
    camera.direction.normalise();

    const sphere = new Object(
        shape = Shape.Sphere,
        position = new Point(0.0, -0.5, 3.0),
        scale = new Vec3(2.0, 1.0, 1.0),
        colour = new RGB(0.0, 0.0, 1.0)
    );

    const cube = new Object(
        shape = Shape.Cube,
        position = new Point(0.0, 1.0, 2.0),
        rotation = new Vec3(pi / 4, pi / 4, pi / 4),
        scale = new Vec3(1.0, 1.0, 1.0),
        colour = new RGB(1.0, 0.0, 0.0)
    );

    var renderedimage = new Render(
        colour = new Image(width, height),
        normal = new Image(width, height)
    );

    const scene = new Scene(objects = [sphere, cube]);

    for x in 0..<width {
        for y in 0..<height {
            var ray = camera.ray(x, y, width, height);
            scene.ray_march(ray, renderedimage, x, y);
        }
        writeln("x = ", x);
    }

    renderedimage.save(output_name);
}