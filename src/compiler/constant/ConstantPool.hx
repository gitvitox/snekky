package compiler.constant;

import evaluator.Evaluator;
import object.NullObj;
import object.UserFunctionObj;
import object.StringObj;
import object.NumberObj;
import object.Object;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class ConstantPool {

    final constants:Array<Object> = [];

    public function new() { }

    public function addConstant(obj:Object):Int {
        return constants.push(obj);
    }

    public function getSize():Int {
        return constants.length;
    }

    public function toByteCode():Bytes {
        final constantsBytes = new BytesOutput();

        for (const in constants) {
            switch (const.type) {
                case ObjectType.Number:
                    final cNumber = cast(const, NumberObj);

                    constantsBytes.writeByte(ConstantType.Float);
                    constantsBytes.writeDouble(cNumber.value);
                case ObjectType.String:
                    final cString = cast(const, StringObj);

                    constantsBytes.writeByte(ConstantType.String);
                    constantsBytes.writeInt32(Bytes.ofString(cString.value).length);
                    constantsBytes.writeString(cString.value);
                case ObjectType.UserFunction:
                    final cUserFunction = cast(const, UserFunctionObj);

                    constantsBytes.writeByte(ConstantType.UserFunction);
                    constantsBytes.writeInt32(cUserFunction.position);
                    constantsBytes.writeInt16(cUserFunction.parametersCount);
                case ObjectType.Null:
                    constantsBytes.writeByte(ConstantType.Null);
                default:
            }
        }

        final output = new BytesOutput();
        output.writeInt32(constantsBytes.length);
        output.write(constantsBytes.getBytes());

        return output.getBytes();
    }

    public static function fromByteCode(byteCode:BytesInput, evaluator:Evaluator):Array<Object> {
        final pool:Array<Object> = [];
        final poolSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while (byteCode.position < startPosition + poolSize) {
            final type = byteCode.readByte();

            switch (type) {
                case ConstantType.Float:
                    final value = byteCode.readDouble();
                    pool.push(new NumberObj(value, evaluator));
                case ConstantType.String:
                    final length = byteCode.readInt32();
                    final value = byteCode.readString(length);
                    pool.push(new StringObj(value, evaluator));
                case ConstantType.UserFunction:
                    final position = byteCode.readInt32();
                    final parametersCount = byteCode.readInt16();
                    pool.push(new UserFunctionObj(position, parametersCount, evaluator));
                case ConstantType.Null:
                    pool.push(new NullObj(evaluator));
                default:
            }    
        }

        return pool;
    }
}