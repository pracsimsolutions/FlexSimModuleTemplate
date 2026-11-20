#include "module.h"

#include "FlexSimModuleTemplate.h"
visible ObjectDataType* createodtderivative(char* classname)
{
	return NULL;
}

visible SimpleDataType* createsdtderivative(char* classname)
{
	if (strcmp(classname, "FlexSimModuleTemplate") == 0) return new FlexSimModuleTemplate::FlexSimModuleTemplate;
	return NULL;
}

visible void dllinitialize() {}
visible void dllcleanup() {}
