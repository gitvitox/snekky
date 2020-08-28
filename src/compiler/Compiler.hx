package compiler;

import sys.io.File;
import object.objects.*;
import compiler.symbol.SymbolTable;
import parser.nodes.operators.Operator;
import haxe.io.BytesBuffer;
import parser.nodes.datatypes.Int.IntN;
import code.Code;
import code.OpCode;
import parser.nodes.*;
import parser.nodes.Node;

class Compiler {

    public final constants:Array<Object> = [];
    public var instructions = new BytesBuffer();
    public final symbolTable = new SymbolTable();

    // Position of last break instruction
    private var lastBreakPos:Int = -1;

    public function new() {

    }

    public function writeByteCode() {
        File.saveBytes("program.bite", instructions.getBytes());
    }

    public function compile(node:Node) {
        switch(node.type) {
            case Block:
                final cBlock = cast(node, Block);
                symbolTable.newScope();
                for (blockNode in cBlock.body) {
                    compile(blockNode);
                }
                symbolTable.setParent();
            case Break:
                lastBreakPos = instructions.length;
                emit(OpCode.Jump, [0]);
            case Statement:
                final cStatement = cast(node, Statement);
                compile(cStatement.value.value);
                emit(OpCode.Pop, []);
            case Expression:
                final cExpression = cast(node, Expression);
                compile(cExpression.value);
            case Plus | Multiply | Equal | SmallerThan | GreaterThan | Minus | Divide | Modulo:
                final cOperator = cast(node, Operator);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case Plus: emit(OpCode.Add, []);
                    case Multiply: emit(OpCode.Multiply, []);
                    case Equal: emit(OpCode.Equals, []);
                    case SmallerThan: emit(OpCode.SmallerThan, []);
                    case GreaterThan: emit(OpCode.GreaterThan, []);
                    case Minus: emit(OpCode.Subtract, []);
                    case Divide: emit(OpCode.Divide, []);
                    case Modulo: emit(OpCode.Modulo, []);
                    default: // TODO: Error
                }
            case Variable:
                final cVariable = cast(node, Variable);
                final symbolIndex = symbolTable.define(cVariable.name);
                compile(cVariable.value);
                emit(OpCode.SetLocal, [symbolIndex]);
            case VariableAssign:
                final cVariableAssign = cast(node, VariableAssign);
                final symbolIndex = symbolTable.resolve(cVariableAssign.name); // TODO: Error if not found
                compile(cVariableAssign.value);
                emit(OpCode.SetLocal, [symbolIndex]);
            case Ident:
                final cIdent = cast(node, Ident);
                final symbolIndex = symbolTable.resolve(cIdent.value);
                emit(OpCode.GetLocal, [symbolIndex]);
            case If:
                final cIf = cast(node, If);
                compile(cIf.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, [0]);

                compile(cIf.consequence);
                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, [0]);

                final jumpNotPos = instructions.length;
                if (cIf.alternative != null) {
                    compile(cIf.alternative);
                }
                final jumpPos = instructions.length;

                overwriteInstruction(jumpNotInstructionPos, [jumpNotPos]);
                overwriteInstruction(jumpInstructionPos, [jumpPos]);
            case While:
                final cWhile = cast(node, While);

                final jumpPos = instructions.length;
                compile(cWhile.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, [0]);
                compile(cWhile.block);
                emit(OpCode.Jump, [jumpPos]);

                if (lastBreakPos != -1) {
                    overwriteInstruction(lastBreakPos, [instructions.length]);
                    lastBreakPos = -1;
                }

                overwriteInstruction(jumpNotInstructionPos, [instructions.length]);
            case Int | Boolean:
                emit(OpCode.Constant, [addConstant(node)]);
            default:
        }
    }

    function overwriteInstruction(pos:Int, operands:Array<Int>) {
        final buffer = new BytesBuffer();
        final currentBytes = instructions.getBytes();
        currentBytes.setInt32(pos + 1, operands[0]);
        buffer.add(currentBytes);
        instructions = buffer;
    }

    function emit(op:OpCode, operands:Array<Int>) {
        final instruction = Code.make(op, operands);
        instructions.add(instruction);
    }

    function addConstant(node:Node):Int {
        switch (node.type) {
            case Int:
                constants.push(new IntObject(cast(node, IntN).value));
            case Boolean:
                constants.push(new IntObject(cast(node, Boolean).value ? 1 : 0));
            default:
        }

        return constants.length - 1;
    }
}