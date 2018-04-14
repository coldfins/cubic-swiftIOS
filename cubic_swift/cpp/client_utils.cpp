#include "client_utils.h"
#include "cubic.h"
#include <string>
using std::string;

namespace cubic_client
{

    void checkApiReturn(const ApiReturn& ret)
    {
        // 0 means success
        if (ret.error == 0)
        {
            return;
        }
        // copy the string and use api call to release memory
        const string error(ret.errorMessage);
        Api_Clear(ret.errorMessage);
        throw std::runtime_error(error);
    }
}



