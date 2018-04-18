#ifndef CUBIC_FLAGS_H_
#define CUBIC_FLAGS_H_

#ifdef _WIN32
    #ifdef CUBIC_EXPORT
        #define  CUBICDLL __declspec(dllexport)
    #else
        #define  CUBICDLL __declspec(dllimport)
    #endif
#else
    #define CUBICDLL
#endif

#endif
