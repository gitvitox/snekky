package ast;

enum NodeType {
    Block;
    Expression;
    Statement;
    Variable;
    VariableAssign;
    Ident;
    FunctionCall;

    Add;
    Subtract;
    Multiply;
    Divide;
    Modulo;
    LogicOr;
    LogicAnd;
    LessThan;
    LessThanOrEqual;
    GreaterThan;
    GreaterThanOrEqual;
    ConcatString;
    Equals;
    NotEquals;
    Negate;
    Not;

    Float;
    String;
    Function;
    Boolean;
    Array;
    Hash;
    Null;

    Return;
    Break;
    If;
    While;

    Index;
    IndexAssign;
}