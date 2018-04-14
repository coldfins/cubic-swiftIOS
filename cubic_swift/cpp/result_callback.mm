#include "api_types.h"
#include "callback_handler.h"
#include "result_callback.h"
#include <thread>
#include <string>
#include <sstream>
#include <iostream>

namespace cubic_client
{
    class DisplayCallbackHandler : public CallbackHandler
    {
    public:
        DisplayCallbackHandler(bool verbose) : mVerbose(verbose) {}
        
        void makeLoggingCallback(int loglevel, CubicString msg)
        {
            if (mVerbose)
            {
                std::stringstream ss;
                ss << "Log Level: " << loglevel << ", LOG: " << msg;
                threadSafeLog(ss.str());
            }
        }
        void makeResultsCallback(CubicString recognizerIdC, CubicString resultC)
        {
            if (mVerbose)
            {
                std::stringstream ss;
                ss << "Recognizer Id: " << recognizerIdC << " result: " << resultC;
                threadSafeLog(ss.str());
            }
            if (mCallback)
            {
                mCallback(resultC);
            }
        }
        void makeMetricsCallback(CubicString recognizerIdC, CubicString metricC)
        {
            if (mVerbose)
            {
                std::stringstream ss;
                ss << "Recognizer Id: " << recognizerIdC << " metrics: " << metricC;
                threadSafeLog(ss.str());
            }
        }
        
        void makeJsonCallback(CubicString recognizerIdC, CubicString jsonC)
        {}
        
        void setDisplayCallback(Results_Display_Callback callback)
        {
            mCallback = callback;
        }
        
    private:
        const bool mVerbose;
        typedef std::lock_guard<std::mutex> LockGuard_t;
        std::mutex mMutex;
        Results_Display_Callback mCallback;
    private:
        void threadSafeLog(const std::string& msg)
        {
            LockGuard_t lock(mMutex);
            std::cout << msg << std::endl;
        }
    };
 
}

void setupCallbacks(Results_Display_Callback callback)
{
    std::shared_ptr<cubic_client::DisplayCallbackHandler> handler=
        std::make_shared<cubic_client::DisplayCallbackHandler>(true);
    handler->setDisplayCallback(callback);
    registerCallbackHandler(handler);
}

