module SceneModule {

    use Object;

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
        var smoothUnion: real;
    }

    record Operation {
        var tag: OperationTag;
        var value: OperationValue;
    }

    proc SmoothUnion(k: real): Operation {
        var value = new OperationValue();
        value.smoothUnion = k;
        return new Operation(tag = OperationTag.SmoothUnion, value = value);   
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
}