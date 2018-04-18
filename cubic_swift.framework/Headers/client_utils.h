#ifndef CLIENT_UTILS_H_
#define CLIENT_UTILS_H_
#include "api_types.h"

namespace cubic_client
{
    /**
     * Helper function for checking the return struct of API calls.
     * Throws with the struct's error message if API call failed.
     */
    void checkApiReturn(const ApiReturn& ret);
}

#endif /* CLIENT_UTILS_H_ */

