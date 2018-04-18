#ifndef COBALT_GUARD_CLIENT_CALLBACKS_H_
#define COBALT_GUARD_CLIENT_CALLBACKS_H_

#include "api_types.h"
#include <string>

namespace cubic_client
{
    // interface for callbacks
    class CallbackHandler
    {
    public:
        typedef std::shared_ptr<CallbackHandler> Ptr;
        
        virtual ~CallbackHandler(){}
        
        virtual void makeLoggingCallback(int loglevel, CubicString msg) = 0;
        
        virtual void makeResultsCallback(CubicString recognizerId, CubicString result) = 0;
        
        virtual void makeMetricsCallback(CubicString recognizerId, CubicString metric) = 0;
        
        virtual void makeJsonCallback(CubicString recognizerId, CubicString json) = 0;
    };
    
    // Best-practice is to call this function once, before any other calls to cobalt APIs
    void registerCallbackHandler(CallbackHandler::Ptr handler);
}

#endif /* COBALT_GUARD_CLIENT_CALLBACKS_H_ */
