package ast.nodes;

class OperatorNode extends Node {
    
    public final left:Node;
    public final right:Node;

    public function new(position:Int, type:NodeType, left:Node, right:Node) {
        super(position, type);

        this.left = left;
        this.right = right;
    }
}