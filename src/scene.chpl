module SceneModule {

    use Object;
    use Colour;
    use Vector;
    use Ray;
    use Transformation;
    use Rendering;
    import Camera;
    use Time;
    use MaterialModule;
    import Math;

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

    proc Intersection(): Operation {
        return new Operation(tag = OperationTag.Intersection);
    }

    proc Difference(): Operation {
        return new Operation(tag = OperationTag.Difference);
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

    proc SceneNode.distance(ray : Ray): (real(64), Material, borrowed SceneNode?, Colour.RGB) {
        if this.isLeaf {
            // const object = this.value.leaf;
            // const p = object.map_point(ray.origin);
            // const obj_dist = object.distance(p);
            // // writeln("obj: ", object, " ||| ray: ", ray, " ||| map: ", p, " ||| dist: ", obj_dist, "\n");
            // var ray_obj = ray;
            // ray_obj.advance(obj_dist);
            // // writeln("ray_obj: ", ray_obj, "\n");

            // // Transform the ray back into the space of the camera

            // // Compute the distance between those two rays
            // var delta = ray.origin - ray_obj.origin;
            // // var scale = M4x4_rotation(object.rotation);
            // var scale = M4x4_scale(object.scale);
            // delta = delta * scale;
            // const dist = delta.length();
            // const light_taken = object.material.col * (object.material.emission / (dist + 2.0)**1.01);
            // return (dist, object.material, this, light_taken/*, object.ignored*/);
            const object = this.value.leaf;
            const p = object.map_point(ray.origin);
            const obj_dist = object.distance(p);
            return (obj_dist, object.material, this, object.material.col * (object.material.emission / (obj_dist + 2.0)**1.01));
        }

        const op = this.getOperation();
        const left = this.getLeft()!;
        const right = this.getRight()!;

        var (left_dist, left_mat, left_obj, left_light/*, left_ign*/) = left.distance(ray);
        var (right_dist, right_mat, right_obj, right_light/*, right_ign*/) = right.distance(ray);
        // writeln("Dist ", left_dist, " - ", right_dist);
        // writeln("Col ", left_col, " - ", right_mat);

        select op.tag {
            when OperationTag.Union {
                // return min(left_dist, right_dist);
                // if (left_ign) {
                //     left_dist = 999999.0;
                // }
                // if (right_ign) {
                //     right_dist = 999999.0;
                // }
                const light = left_light + right_light;
                if (left_dist < right_dist) {
                    return (left_dist, left_mat, left_obj, light/*, left_ign*/);
                }   
                else {
                    return (right_dist, right_mat, right_obj, light/*, right_ign*/);
                }
            }
            when OperationTag.Intersection {
                // return max(left_dist, right_dist);
                // if (left_ign) {
                //     left_dist = 999999.0;
                // }
                // if (right_ign) {
                //     right_dist = 999999.0;
                // }
                if (left_dist > right_dist) {
                    return (left_dist, left_mat, left_obj, left_light/*, left_ign*/);
                }
                else {
                    return (right_dist, right_mat, right_obj, right_light/*, right_ign*/);
                }
            }
            when OperationTag.Difference {
                // return min(left_dist, -right_dist);
                // if (left_ign) {
                //     left_dist = 999999.0;
                // }
                // if (right_ign) {
                //     right_dist = 999999.0;
                // }
                if (left_dist < -right_dist) {
                    return (left_dist, left_mat, left_obj, left_light/*, left_ign*/);
                }
                else {
                    return (-right_dist, right_mat, right_obj, right_light/*, right_ign*/);
                }
            }
            when OperationTag.SmoothUnion {
                // return min(left_dist, right_dist) - op.value.smoothUnion;
                // if (left_dist < right_dist) {
                //     return (left_dist - op.value.smoothUnion, left_mat);
                // }
                // else {
                //     return (right_dist - op.value.smoothUnion, right_mat);
                // }
                var old_right_dist = right_dist;
                var old_left_dist = left_dist;
                // if (left_ign) {
                //     left_dist = 999999.0;
                //     old_left_dist = -old_left_dist;
                // }
                // if (right_ign) {
                //     right_dist = 999999.0;
                //     old_right_dist = -old_right_dist;
                // }
                var obj;
                if (left_dist < right_dist) {
                    obj = left_obj;
                }
                else {
                    obj = right_obj;
                }

                const k = op.value.smoothUnion;
                const h = max(k - abs(old_left_dist - old_right_dist), 0) / k;
                const x = ((h**3)*k) / 6;
                var i = (0.5 + 0.5 * (old_left_dist - old_right_dist) / k);//, 0.0, 1.0); //interpol
                if (i < 0.0) {
                    i = 0.0;
                }
                if (i > 1.0) {
                    i = 1.0;
                }
                const min_dist = min(left_dist, right_dist) - x;
                // const col = (right_mat * i) + (left_mat * (1.0 - i));
                const mat = Material_interpolate(a=left_mat, b=right_mat, t=i);
                const light = mat.col * (mat.emission / (min_dist + 2.0)**1.01);
                return (min_dist, mat, obj, light/*, left_ign || right_ign*/);
                // if (left_dist < right_dist) {
                //     return (left_dist - x, left_col);
                // }
                // else {
                //     return (right_dist - x, right_mat);
                // }
            }
        }

        return (+inf, new Material(), this, Colour.BLACK/*, false*/);
    }

    proc SceneNode.normal(in r: Ray) : Vec3 {
        // Usual normal calculation
        const EPS: real(64) = 0.0000000001;
        
        // const (x, _) = this.distance(new Ray(origin = r.origin + new Vec3(EPS,0.0,0.0), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(EPS,0.0,0.0), direction = r.direction));
        // const (y, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,EPS,0.0), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(0.0,EPS,0.0), direction = r.direction));
        // const (z, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,0.0,EPS), direction = r.direction)) - this.distance(new Ray(origin = r.origin - new Vec3(0.0,0.0,EPS), direction = r.direction));
        const (dxp, _, _, _) = this.distance(new Ray(origin = r.origin + new Vec3(EPS,0.0,0.0), direction = r.direction));
        const (dxn, _, _, _) = this.distance(new Ray(origin = r.origin - new Vec3(EPS,0.0,0.0), direction = r.direction));
        const (dyp, _, _, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,EPS,0.0), direction = r.direction));
        const (dyn, _, _, _) = this.distance(new Ray(origin = r.origin - new Vec3(0.0,EPS,0.0), direction = r.direction));
        const (dzp, _, _, _) = this.distance(new Ray(origin = r.origin + new Vec3(0.0,0.0,EPS), direction = r.direction));
        const (dzn, _, _, _) = this.distance(new Ray(origin = r.origin - new Vec3(0.0,0.0,EPS), direction = r.direction));
        const dx = dxp - dxn;
        const dy = dyp - dyn;
        const dz = dzp - dzn;
        var vec = new Vec3(dx, dy, dz);
        vec.normalise();
        return vec;
    }

    // proc SceneNode.ray_march(in ray: Ray, depth: uint) : Hit {
    //     param MAX_STEPS: uint = 500;
    //     param MAX_DIST: real(64) = 300.0;
    //     param EPS: real(64) = 0.002;

    //     const no_hit = new Hit(
    //         did_hit = false,
    //         colour = Colour.LIGHT_BLUE,
    //         normal = new Vec3(0.0, 0.0, 0.0),
    //         steps_taken = MAX_STEPS,
    //         alpha_acc = 0.0
    //     );

    //     if depth == 0 {
    //         return new Hit(
    //             did_hit = false,
    //             colour = Colour.BLACK,
    //             normal = new Vec3(0.0, 0.0, 0.0),
    //             steps_taken = 0,
    //             alpha_acc = 0.0
    //         );
    //     } 

    //     for i in 0..MAX_STEPS {
    //         var (min_dist, mat) = this.distance(ray);
    //         var (col, alpha) = (mat.col, mat.alpha);
    //         // writeln("iter ", i, "dist", min_dist);
    //         if min_dist > MAX_DIST {
    //             return no_hit;
    //         }
    //         if min_dist < EPS {
    //             // ray.advance(min_dist); // <- breaks normals
    //             // var normal = min_hit.normal(ray.origin);


    //             return new Hit(
    //                 did_hit = true,
    //                 colour = col,
    //                 normal = this.normal(ray),
    //                 steps_taken = i,
    //                 alpha_acc = alpha
    //             );

    //             // var results: [1..3] Hit;
    //             // const bounce_samples = vecs_in_hemisphere_uniform(normal, 3);
    //             // for i in 1..3 {
    //             //     var bounce_ray = new Ray(origin = ray.origin, direction = bounce_samples[i]);
    //             //     bounce_ray.advance(0.005);
    //             //     results[i] = this.ray_march(bounce_ray, depth - 1);
    //             // }
    //             // var colour = new RGB(0.0, 0.0, 0.0);
    //             // for i in 1..3 {
    //             //     colour += results[i].colour;
    //             // }
    //             // colour /= 3.0;
    //             // return new Hit(
    //             //     did_hit = true,
    //             //     colour = colour,
    //             //     normal = normal
    //             // );
    //         }

    //         ray.advance(min_dist);
    //     }

    //     return no_hit;
    // }

    // proc SceneNode.reset_ignored() {
    //     if this.isLeaf {
    //         this.value.leaf.ignored = false;
    //     }
    //     else {
    //         this.getLeft()!.reset_ignored();
    //         this.getRight()!.reset_ignored();
    //     }
    // }

    proc SceneNode.print() {
        if this.isLeaf {
            writeln("Leaf: ", this.value.leaf);
        }
        else {
            writeln("Node: ", this.value.node.operation.tag);
            this.getLeft()!.print();
            this.getRight()!.print();
        }
    }

    proc SceneNode.print_all_distances(ray: Ray) {
        if this.isLeaf {
            const (dist, _, _, _) = this.distance(ray);
            writeln("Leaf: ", this.value.leaf, " dist: ", dist);
        }
        else {
            const (dist, _, _, _) = this.distance(ray);
            writeln("Node: ", this.value.node.operation.tag, " dist: ", dist);
            this.getLeft()!.print_all_distances(ray);
            this.getRight()!.print_all_distances(ray);
        }
    }

    proc SceneNode.ray_march(in ray: Ray, depth: uint) : Hit {
        param MAX_STEPS: uint = 500;
        param MAX_DIST: real(64) = 300.0;
        param EPS: real(64) = 0.001;

        var hit = new Hit(
            did_hit = false,
            colour = Colour.BLACK,
            normal = new Vec3(0.0, 0.0, 0.0),
            steps_taken = MAX_STEPS,
            alpha_acc = 0.0,
            light_acc = Colour.BLACK
        );

        const sky_mat = new Material(
            col = Colour.LIGHT_BLUE,
            alpha = 1.0,
            emission = 0.0
        );

        var mask = Colour.WHITE;
        var did_hit_transparent_last_time = false;
        var last_mat = new Material();
        var last_pos = new Point(0.0, 0.0, 0.0);
        for i in 0..MAX_STEPS {

            var (min_dist, mat, scenenode, light_accumulation) = this.distance(ray);
            
            var is_inside = false;
            if (min_dist < 0.0) {
                is_inside = true;
            }

            var leaf = scenenode!;

            // accumulate light
            // hit.light_acc += light_accumulation / (min_dist + 1.0)**1.01;
            // mask *= mat.col;
            
            var (col, alpha) = (mat.col, mat.alpha);

            // Over
            if min_dist > MAX_DIST {
                hit.hit_after_transparent(sky_mat);
                return hit;
            }

            if min_dist < EPS {
                // this.print_all_distances(ray);
                if (!hit.did_hit) {
                    hit.did_hit = true;
                    hit.position = ray.origin;
                    hit.steps_taken = i;
                    hit.normal = this.normal(ray);
                }
                /*if (last_pos.x == 0.0 && last_pos.y == 0.0 && last_pos.z == 0.0) {
                    last_pos = hit.position;
                }

                // Calculate the distance to full opacity
                var dist_to_full_alpha = 1.0 - hit.alpha_acc;

                // Blend the colors using alpha blending
                hit.colour = (hit.colour * hit.alpha_acc) + (col * dist_to_full_alpha);

                // Update the accumulated alpha according to how much of the color is opaque, and how far you traveled
                var dist = (hit.position - last_pos).length();
                // writeln("dist: ", dist);
                const to_add = alpha * dist_to_full_alpha / ((dist + 0.001) * 1000000.0);
                // writeln("to_add: ", to_add);
                // writeln("alpha acc before: ", hit.alpha_acc, " to add: ", to_add);
                hit.alpha_acc += to_add;
                // writeln("alpha acc after: ", hit.alpha_acc);

                // Terminate early if fully opaque
                if (hit.alpha_acc >= 1.0) {
                    return hit;
                }*/

                // Step inside the object and accumulate transparency
                var steps_inside = 0;
                // writeln("inside");
                hit.colour = (hit.colour * hit.alpha_acc) + (col * (1.0 - hit.alpha_acc));
                // writeln("alpha acc before: ", hit.alpha_acc);
                // writeln("alpha acc after: ", hit.alpha_acc);
                const sample_distance = 0.01;
                hit.alpha_acc += mat.alpha;
                if (hit.alpha_acc > 1.0) {
                    hit.alpha_acc = 1.0;
                }


                // writeln("alpha acc before inside: ", hit.alpha_acc);

                var new_ray = new Ray(
                    origin = ray.origin,
                    direction = ray.direction
                );
                // this.print_all_distances(new_ray);
                new_ray.advance(min_dist);
                // this.print_all_distances(new_ray);
                // writeln("min dist: ", min_dist, " new ray min dist: ", this.distance(new_ray));
                for j in i..MAX_STEPS {
                    // if (hit.alpha_acc >= 1.0) {
                    //     writeln("steps inside before break 1: ", steps_inside);
                    //     hit.colour = Colour.ORANGE;
                    //     break;
                    // }
                    var (new_dist, new_mat, new_scenenode, new_light_accumulation) = this.distance(new_ray);
                    // write("new_dist: ", new_dist, " ");
                    if (new_dist < (EPS + 0.01)) {
                        // hit.colour = (hit.colour * hit.alpha_acc) + (new_mat.col * (1.0 - hit.alpha_acc));
                        // hit.alpha_acc += new_mat.alpha * sample_distance;
                        // if (hit.alpha_acc > 1.0) {
                            // hit.alpha_acc = 1.0;
                        // }
                        steps_inside += 1;
                        new_ray.advance(sample_distance);
                    } else {
                        // writeln("steps inside before break 2: ", steps_inside, "new_dist: ", new_dist);
                        // hit.colour = Colour.PURPLE;
                        break;
                    }
                }
                ray = new_ray;
                // writeln("steps inside: ", steps_inside, " alpha acc new: ", hit.alpha_acc);
                hit.alpha_acc += mat.alpha * steps_inside * sample_distance;
                if (hit.alpha_acc > 1.0) {
                    hit.alpha_acc = 1.0;
                }
                // writeln("alpha acc after inside: ", hit.alpha_acc, " steps inside: ", steps_inside);
            } else {
                // Advance the ray if no hit
                ray.advance(min_dist);
            }
        }

        if (hit.alpha_acc >= 1.0) {
            hit.alpha_acc = 1.0;
        }
        hit.hit_after_transparent(sky_mat);

        return hit;
    }

    proc SceneNode.ambient_occlusion(hit: Hit): real(64) {
        // return hit.steps_taken;

        // Create a sphere of 30 points
        // const (x, y, z) = hit.position;
        const x = hit.position.x;
        const y = hit.position.y;
        const z = hit.position.z;
        // const EPS = 0.003;
        // const points = [
        //     (x + EPS, y, z),
        //     (x - EPS, y, z),
        //     (x, y + EPS, z),
        //     (x, y - EPS, z),
        //     (x, y, z + EPS),
        //     (x, y, z - EPS)
        // ];

    //     def fibonacci_sphere(samples=1000):

    // points = []
    // phi = math.pi * (math.sqrt(5.) - 1.)  # golden angle in radians

    // for i in range(samples):
    //     y = 1 - (i / float(samples - 1)) * 2  # y goes from 1 to -1
    //     radius = math.sqrt(1 - y * y)  # radius at y

    //     theta = phi * i  # golden angle increment

    //     x = math.cos(theta) * radius
    //     z = math.sin(theta) * radius

    //     points.append((x, y, z))

    // return points

        var points: [0..<30] (3 * real(64));
        const phi = 3.1415 * (sqrt(5.0) - 1.0);
        for i in 0..<30 {
            const dy = 1 - (i:real(64) / 29.0) * 2;
            const radius = sqrt(1-dy*dy);
            const theta=phi*i;
            const dx = Math.cos(theta) * radius;
            const dz = Math.sin(theta) * radius;

            points[i] = (x + dx, y+dy, z+dz);
        }

        // writeln(points);
        var nb_inside = 0;
        for p in points {
            const ray = new Ray(
                origin = new Point(
                    x=p[0],y=p[1],z=p[2]
                ),
                direction=-hit.normal
                // direction=new Vec3(0.0,0.0,0.0)
            );
            const (dist, _, _, _/*, ign*/) = this.distance(ray);
            // writeln(dist);
            // if (!ign) {
                if dist < 0.001 {
                    nb_inside += 1;
                }
            // }
        }
        // writeln(nb_inside);
        return nb_inside / 6.0;
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
                    var depth = 0;
                    const eX = 250 / 2;
                    const eY = 270 / 2;
                    // if (abs(x - X) < 5 && abs(y - Y) < 5) {
                        // depth = 1;
                    // }
                    if (x == eX && y == eY) {
                        depth = 1;
                    }
                    var hit = this.ray_march(ray, depth);
                    hit.light_acc /= hit.steps_taken;
                    hit.light_acc *= 0.8;
                    hit.light_acc.r = min(hit.light_acc.r, 1.0);
                    hit.light_acc.g = min(hit.light_acc.g, 1.0);
                    hit.light_acc.b = min(hit.light_acc.b, 1.0);

                    const light_ratio = 0.95;
                    colour.pixels[x, y] += (light_ratio * (hit.colour + hit.light_acc) + (1.0 - light_ratio) * hit.light_acc) / nb_samples;
                    normal.pixels[x, y] += new RGB(
                        r = (1.0 + hit.normal.x) / 2.0,
                        g = (1.0 + hit.normal.y) / 2.0,
                        b = (1.0 + hit.normal.z) / 2.0
                    ) / nb_samples;
                    const amb = this.ambient_occlusion(hit);
                    amb_occ.pixels[x, y] = Colour.WHITE - ((Colour.WHITE * amb));
                    // amb_occ.pixels[x, y] = Colour.WHITE - ((Colour.WHITE * hit.steps_taken) / (MAX_STEPS / STRENGTH));
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
            writeln("x = ", x);
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