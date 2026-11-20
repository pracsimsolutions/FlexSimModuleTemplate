#pragma once
#include "FlexSimdefs.h"

namespace FlexSimModuleTemplate {
    class FlexSimModuleTemplate : public SimpleDataType
    {
    public:
        virtual const char* getClassFactory() override { return "FlexSimModuleTemplate::FlexSimModuleTemplate"; }
        virtual void bindInterface() override;

        static Variant helloWorld(Variant value);
    };
}
