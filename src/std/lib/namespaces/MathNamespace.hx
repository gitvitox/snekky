package std.lib.namespaces;

import object.NullObj;
import object.NumberObj;
import object.Object;
import evaluator.Evaluator;

class MathNamespace extends MemberObject {

    public static final name = "Math";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addObjectMember("PI", new NumberObj(Math.PI, evaluator));

        addFunctionMember("abs", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.abs(value), evaluator);
        });

        addFunctionMember("floor", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.floor(value), evaluator);
        });

        addFunctionMember("sqrt", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.sqrt(value), evaluator);
        });
    }
}