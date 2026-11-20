#include "FlexSimModuleTemplate.h"

namespace FlexSimModuleTemplate {
    void FlexSimModuleTemplate::bindInterface()
    {
        __super::bindInterface();
        bindMethod(helloWorld, FlexSimModuleTemplate, "Variant helloWorld(Variant value)", BIND_METHOD_STATIC);
    }

    Variant FlexSimModuleTemplate::helloWorld(Variant value)
    {
        print("Hello, your number was: " + value);
        return "check your output console";
    }
}
