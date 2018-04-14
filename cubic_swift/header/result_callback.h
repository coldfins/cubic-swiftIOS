//
//  display_result_callback.h
//  cubic_asr_test
//
//  Created by Kevin Yang on 5/5/16.
//  Copyright © 2016 cobaltspeech. All rights reserved.
//

#ifndef result_callback_h
#define result_callback_h

#if __cplusplus
extern "C" {
#endif

    typedef void (*Results_Display_Callback)(const char* result);
    
    void setupCallbacks(Results_Display_Callback callback);
    
#if __cplusplus
}
#endif

#endif /* display_result_callback_h */
