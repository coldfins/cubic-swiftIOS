#include "callback_handler.h"
#include "cubic.h"
#include "client_utils.h"
#include <stdexcept>

namespace cubic_client
{
    CallbackHandler::Ptr gHandler;
    
    void loggingCallback(int level, CubicString msg)
    {
        gHandler->makeLoggingCallback(level, msg);
    }
    
    void resultsCallback(CubicString recognizerIdC, CubicString resultC)
    {
        gHandler->makeResultsCallback(recognizerIdC, resultC);
    }
    
    void metricsCallback(CubicString recognizerIdC, CubicString metricsC)
    {
        gHandler->makeMetricsCallback(recognizerIdC, metricsC);
    }
    
    void jsonCallback(CubicString recognizerIdC, CubicString jsonC)
    {
        gHandler->makeJsonCallback(recognizerIdC, jsonC);
    }
    
    void registerCallbackHandler(CallbackHandler::Ptr handler)
    {
        gHandler = handler;
        if (!handler)
        {
            throw std::runtime_error("Attempting to register a null callback handler");
        }
        checkApiReturn(Api_RegisterLoggingCallback(&loggingCallback));
        checkApiReturn(Api_RegisterResultsCallback(&resultsCallback));
        checkApiReturn(Api_RegisterMetricsCallback(&metricsCallback));
        checkApiReturn(Api_RegisterJsonCallback(&jsonCallback));
    }
    
}

