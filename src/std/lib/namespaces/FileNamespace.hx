package std.lib.namespaces;

import object.NullObj;
import object.StringObj;
import sys.io.File;
import object.Object;
import evaluator.Evaluator;

class FileNamespace extends MemberObject {

    public static final name = "File";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("read", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final path = cast(p[0], StringObj).value;

            try {
                final content = File.getContent(path);
                return new StringObj(content, evaluator);
            } catch (e) {
                error("failed to open file");
            }

            return new NullObj(evaluator);
        });

        addFunctionMember("write", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            assertParameterType(p[1], ObjectType.String);
            final path = cast(p[0], StringObj).value;
            final content = cast(p[1], StringObj).value;
            
            try {
                File.saveContent(path, content);
            } catch (e) {
                error("failed to open file");
            }

            return new NullObj(evaluator);
        });
    }
}