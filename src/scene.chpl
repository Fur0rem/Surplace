module SceneModule {

    use Object;
    use Colour;
    use Vector;
    use Ray;
    use Transformation;
    use Rendering;
    import Camera;
    use Time;

    enum OperationTag {
        Union,
        Intersection,
        Difference,
        SmoothUnion,
    }

    union OperationValue {
        var unioned: nothing;
        var intersection: nothing;
        var difference: nothing;
        var smoothUnion: real(64);
    }

    record Operation {
        var tag: OperationTag;
        var value: OperationValue;
    }

    proc SmoothUnion(k: real(64)): Operation {
        var value = new OperationValue();
        value.smoothUnion = k;
        return new Operation(tag = OperationTag.SmoothUnion, value = value);   
    }

    proc Union(): Operation {
        return new Operation(tag = OperationTag.Union);
    }

    record Tree {
        var operation: Operation;
        var left: borrowed SceneNode?;
        var right: borrowed SceneNode?;
    }

    proc createTree(op: Operation, left: owned SceneNode, right: owned SceneNode): Tree {
        return new Tree(operation = op, left = left, right = right);
    }

    union SceneNodeValue {
        var leaf: Object;
        var node: Tree;
    }

    // Define the SceneNode class
    class SceneNode {
        var isLeaf: bool;
        var value: SceneNodeValue;
        
        // Constructor for Leaf
        proc init(leafValue: Object) {
            this.isLeaf = true;
            this.value = new SceneNodeValue();
            this.value.leaf = leafValue;
        }

        // Constructor for Node
        proc init(op: Operation, left: owned SceneNode, right: owned SceneNode) {
            this.isLeaf = false;
            this.value = new SceneNodeValue();
            this.value.node = createTree(op, left, right);
        }

        // Method to check if the SceneNode is a Leaf
        proc isALeaf(): bool {
            return this.isLeaf;
        }

        // Method to check if the SceneNode is a Node
        proc isANode(): bool {
            return !this.isLeaf;
        }

        // Method to get the leaf value, assuming it is a Leaf
        proc getLeafValue(): Object {
            if this.isLeaf {
                return this.value.leaf;
            } else {
                halt("Called getLeafValue on a Node");
            }
        }

        // Method to get the left child, assuming it is a Node
        proc getLeft(): borrowed SceneNode? {
            if !this.isLeaf {
                return this.value.node.left;
            } else {
                halt("Called getLeft on a Leaf");
            }
        }

        // Method to get the right child, assuming it is a Node
        proc getRight(): borrowed SceneNode? {
            if !this.isLeaf {
                return this.value.node.right;
            } else {
                halt("Called getRight on a Leaf");
            }
        }

        proc getOperation(): Operation {
            if !this.isLeaf {
                return this.value.node.operation;
            } else {
                halt("Called getOperation on a Leaf");
            }
        }
    }

    // Factory function to create a Leaf
    proc Leaf(value: Object): SceneNode {
        return new SceneNode(value);
    }

    // Factory function to create a Node
    proc Node(op: Operation, left: SceneNode, right: SceneNode): SceneNode {
        return new SceneNode(op, left, right);
    }

    proc SceneNode.distance(ray : Ray): (real(64), RGB) {
        if this.isLeaf {
            const object = this.value.leaf;
            const p = object.map_point(ray.origin);
            const obj_dist = object.distance(p);
            // writeln("obj: ", object, " ||| ray: ", ray, " ||| map: ", p, " ||| dist: ", obj_dist, "\n");
            var ray_obj = ray;
            ray_obj.advance(obj_dist);
            // writeln("ray_obj: ", ray_obj, "\n");

            // Transform the ray back into the space of the camera

            // Compute the distance between those two rays
            var delta = ray.origin - ray_obj.origin;
            // var scale = M4x4_rotation(object.rotation);
            var scale = M4x4_scale(object.scale);
            delta = delta * scale;
            const dist = delta.length();
            return (dist, object.colour);
        }

        const op = this.getOperation();
        const left = this.getLeft()!;
        const right = this.getRight()!;

        const (left_dist, left_col) = left.distance(ray);
        const (right_dist, right_col) = right.distance(ray);
        // writeln("Dist ", left_dist, " - ", right_dist);
        // writeln("Col ", left_col, " - ", right_col);

        select op.tag {
            when OperationTag.Union {
                // return min(left_dist, right_dist);
                if (left_dist < right_dist) {
                    return (left_dist, left_col);
                }
                else {
                    return (right_dist, right_col);
                }
            }
            when OperationTag.Intersection {
                // return max(left_dist, right_dist);
                if (left_dist > right_dist) {
                    return (left_dist, left_col);
                }
                else {
                    return (right_dist, right_col);
                }
            }
            when OperationTag.Difference {
                // return min(left_dist, -right_dist);
                if (left_dist < -right_dist) {
                    return (left_dist, left_col);
                }
                else {
                    return (-right_dist, right_col);
                }
            }
            when OperationTag.SmoothUnion {
                // return min(left_dist, right_dist) - op.value.smoothUnion;
                // if (left_dist < right_dist) {
                //     return (left_dist - op.value.smoothUnion, left_col);
                // }
                // else {
                //     return (right_dist - op.value.smoothUnion, right_col);
                // }
                const k = op.value.smoothUnion;
                const h = max(k - abs(left_dist - right_dist), 0) / k;
                const x = ((h**3)*k) / 6;
                var i = (0.5 + 0.5 * (left_dist - right_dist) / k);//, 0.0, 1.0); //interpol
                if (i < 0.0) {
                    i = 0.0;
                }
                if (i > 1.0) {
                    i = 1.0;
                }
                const min_dist = min(left_dist, right_dist) - x;
                const col = (right_col * i) + (left_col * (1.0 - i));
                return (min_dist, col);
                // if (left_dist < right_dist) {
                //     return (left_dist - x, left_col);
                // }
                // else {
                //     return (right_dist - x, right_col);
                // }
            }
        }

        return (+inf, Colour.BLACK);
    }

    proc SceneNode.normal(in r: Ray) : Vec3 {
        // Usual normal calculation
        const EPS: real(64) = 0.0000000001;
        
        const (x, _) = this.distance(new Ray(origin = r.origin + new Vec3(EPS,0.0,0.0), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(EPS,0.0,0.0), direction = r.direction));
        const (y, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,EPS,0.0), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(0.0,EPS,0.0), direction = r.direction));
        const (z, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,0.0,EPS), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(0.0,0.0,EPS), direction = r.direction));

        var vec = new Vec3(x, y, z);
        vec.normalise();
        return vec;
    }

    proc SceneNode.ray_march(in ray: Ray, depth: uint) : Hit {
        param MAX_STEPS: uint = 500;
        param MAX_DIST: real(64) = 300.0;
        param EPS: real(64) = 0.002;

        const no_hit = new Hit(
            did_hit = false,
            colour = Colour.LIGHT_BLUE,
            normal = new Vec3(0.0, 0.0, 0.0),
            steps_taken = MAX_STEPS
        );

        if depth == 0 {
            return new Hit(
                did_hit = false,
                colour = Colour.BLACK,
                normal = new Vec3(0.0, 0.0, 0.0),
                steps_taken = 0
            );
        } 

        for i in 0..MAX_STEPS {
            var (min_dist, col) = this.distance(ray);
            // writeln("iter ", i, "dist", min_dist);
            if min_dist > MAX_DIST {
                return no_hit;
            }
            if min_dist < EPS {
                // ray.advance(min_dist); // <- breaks normals
                // var normal = min_hit.normal(ray.origin);


                return new Hit(
                    did_hit = true,
                    colour = col,
                    normal = this.normal(ray),
                    steps_taken = i
                );

                // var results: [1..3] Hit;
                // const bounce_samples = vecs_in_hemisphere_uniform(normal, 3);
                // for i in 1..3 {
                //     var bounce_ray = new Ray(origin = ray.origin, direction = bounce_samples[i]);
                //     bounce_ray.advance(0.005);
                //     results[i] = this.ray_march(bounce_ray, depth - 1);
                // }
                // var colour = new RGB(0.0, 0.0, 0.0);
                // for i in 1..3 {
                //     colour += results[i].colour;
                // }
                // colour /= 3.0;
                // return new Hit(
                //     did_hit = true,
                //     colour = colour,
                //     normal = normal
                // );
            }

            ray.advance(min_dist);
        }

        return no_hit;
    }

    proc SceneNode.render(camera: Camera.Camera, width: uint, height: uint) : Render {
        var colour = new Image(width, height);
        var normal = new Image(width, height);
        var times: [0..width, 0..height] real(64);
        var amb_occ = new Image(width, height);
        var max_time_taken = 0.0;
        for x in 0..<width {
            for y in 0..<height {
                var chrono: stopwatch;
                chrono.start();
                const samples = camera.one_ray(y, x, width, height); // I don't know why I have to swap x and y
                const nb_samples = samples.domain.size: real(64);
                for ray in samples {
                    var hit = this.ray_march(ray, 5);
                    colour.pixels[x, y] += hit.colour / nb_samples;
                    normal.pixels[x, y] += new RGB(
                        r = (1.0 + hit.normal.x) / 2.0,
                        g = (1.0 + hit.normal.y) / 2.0,
                        b = (1.0 + hit.normal.z) / 2.0
                    ) / nb_samples;
                    param STRENGTH = 5.0;
                    amb_occ.pixels[x, y] = Colour.WHITE - ((Colour.WHITE * hit.steps_taken) / (MAX_STEPS / STRENGTH));
                    amb_occ.pixels[x, y] = max(amb_occ.pixels[x, y], Colour.BLACK);
                }
                var time_taken = chrono.elapsed();
                if time_taken > max_time_taken {
                    max_time_taken = time_taken;
                }
                times[x, y] = time_taken;
                // var ray = camera.ray(x, y, width, height);
                // var hit = this.ray_march(ray, 10);
                // colour.pixels[x, y] = hit.colour;
                // normal.pixels[x, y] = new RGB(r = hit.normal.x, g = hit.normal.y, b = hit.normal.z);
                // // writeln("y = ", y);
                // // writeln("hit = ", hit);
            }
            // writeln("x = ", x);
        }

        writeln("Max time taken: ", max_time_taken * 1000000, " us");

        var sum_of_time = 0.0;
        for x in 0..<width {
            for y in 0..<height {
                sum_of_time += times[x, y];
            }
        }
        writeln("Average time : ", (sum_of_time / (width*height)) * 1_000_000, " us");

        // normalise the time taken
        for x in 0..<width {
            for y in 0..<height {
                times[x, y] /= max_time_taken;
                if times[x, y] > 1.0 {
                    times[x, y] = 1.0;
                }
            }
        }

        var time_image = new Image(width, height);
        for x in 0..<width {
            for y in 0..<height {
                time_image.pixels[x, y] = new RGB(
                    r = times[x, y],
                    g = 0.0,
                    b = 0.0
                );
                if times[x, y] > 0.9 {
                    time_image.pixels[x, y].g = 1.0;
                }
            }
        }

        return new Render(
            colour = colour,
            normal = normal,
            time_taken = time_image,
            ambient_occlusion = amb_occ
        );
    }
}