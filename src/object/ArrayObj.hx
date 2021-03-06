package object;

import std.lib.MemberObject;
import object.Closure.ClosureObj;
import evaluator.Evaluator;
import object.Object.ObjectType;

using equals.Equal;

private class ArrayIterator extends MemberObject {

    public function new(evaluator:Evaluator, value:Array<Object>) {
        super(evaluator);

        var index = -1;

        addFunctionMember("next", 0, function(p) {
            index++;
            return value[index];
        });

        addFunctionMember("hasNext", 0, function(p) {
            return new NumberObj(index < value.length - 1 ? 1 : 0, evaluator);
        });
    }
}

class ArrayObj extends Object {

    public final value:Array<Object>;

    public function new(value:Array<Object>, evaluator:Evaluator) {
        super(ObjectType.Array, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("Iterator", 0, function(p) {
            return new ArrayIterator(evaluator, value).getMembers();
        });

        addFunctionMember("length", 0, function(p) {
            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(this.value.toString(), evaluator);
        });

        addFunctionMember("push", 1, function(p) {
            this.value.push(p[0]);

            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("pop", 0, function(p) {
            return this.value.pop();
        });

        addFunctionMember("map", 1, function(p) {
            assertParameterType(p[0], ObjectType.Closure);
            final callback = cast(p[0], ClosureObj);

            for (k => v in this.value) {
                this.value[k] = evaluator.callFunction(callback, [v]);
            }

            return new NullObj(evaluator);
        });
    }

    override function toString():String {
        return value.map(o -> o.toString()).toString(); 
    }
}