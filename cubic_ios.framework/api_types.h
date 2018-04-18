#ifndef CUBIC_API_TYPES_H_
#define CUBIC_API_TYPES_H_
/**
 * @file api_types.h
 * types used by the cubic api.
 */
// C types used by the cubic C api.
#include <stdint.h>
typedef const char* CubicString;
typedef char* Memory;

// Logging Levels, a subset of log4j levels
#define LOGLEVEL_TRACE 0 // most fine grained log level available
#define	LOGLEVEL_DEBUG 1 // fine grained messages to aid debugging
#define	LOGLEVEL_INFO 2  // coarse grained information messages, mostly event based
#define	LOGLEVEL_WARN 3  // warning messages, potentially harmful situations
#define	LOGLEVEL_ERROR 4 // error events but application will keep going
#define	LOGLEVEL_FATAL 5 // application will abort shortly

// logging callback
typedef void (*Logging_Callback)(int loglevel, CubicString msg);

// results callback: Recognition results are always tied to a recognizer, thus the
// first parameter in the callback is the recognizerId.
typedef void (*Results_Callback)(CubicString recognizerId, CubicString result);

// metrics callback: metrics are often tied to a recognizer, thus the
// first parameter in the callback is the recognizerId.
typedef void (*Metrics_Callback)(CubicString recognizerId, CubicString metric);

// Json callback: this callback will be used to record useful recognition events, such as the complete timeline of events
// It is often tied to a recognizer, thus the first parameter in the callback is the recognizerId.
// This callback is likely to be used for debugging and recording, rather than actionable triggers for client code.
typedef void (*Json_Callback)(CubicString recognizerId, CubicString json);

// a model that aids in recognition.
typedef struct AuxiliaryModel
{
    char* bytes;
    int size;
} AuxiliaryModel;

// Auxiliary model callback: this callback is typically made at the start of recognition.
// Client logic must find the compatible auxiliary model, based on the recognizer ID and auxiliary model type parameters
//
// If client logic is successful, return 0 and set the auxiliary model.
// If client logic is unsuccessful, return non-0 (1) and the engine will not attempt to use the model.
typedef int (*AuxiliaryModel_Callback)(CubicString recognizerId, CubicString auxiliaryModelType,
        AuxiliaryModel* auxiliaryModel);

// common return struct for API function calls
typedef struct ApiReturn
{
    // 0 means success, non-0 means failure
    int error;
    // if error is non-0, errorMessage will hold the string error message.
    // if error is 0, do not access errorMessage.
    char* errorMessage;
} ApiReturn;

// return struct for modelset attributes
typedef struct ModelsetAttributesReturn
{
    // 0 means success, non-0 means failure
    int error;
    // if error is non-0, errorMessage will hold the string error message.
    // if error is 0, do not access errorMessage.
    char* errorMessage;
    // modelset attributes, as JSON.
    const char* modelsetAttributes;
} ModelsetAttributesReturn;

typedef struct CubicBinaryObject
{
    char* data;
    unsigned int size;
} CubicBinaryObject;

typedef struct CubicArchiveReturn
{
    // 0 means success, non-0 means failure
    int error;
    // if error is non-0, errorMessage will hold the string error message.
    // if error is 0, do not access errorMessage.
    char* errorMessage;
    //Cubic Archive as a whole byte array.
    CubicBinaryObject cubicArchive;
} CubicArchiveReturn;

// Event types
typedef enum
{
    // this is an audio event.
    // In asynchronous model, it is a non-blocking event, the call to push this event returns immediately.
    AUDIO_EVENT,

    // session end, finish a recognizer session.
    //
    // 1. it moves to the front of the recognition queue.
    // 2. it clears the queue of unprocessed audio events.
    // 3. it emits a result based on the current processed audio, if there is a result available.
    // 4. it tells the recognizer that no new audio will be pushed
    //
    // this event is a blocking event, we block until it is processed.
    SESSION_END,

    // backlog empty, ensure that all avaialble audio is processed.
    //
    // this event is a blocking event, we block until it is processed
    BACKLOG_EMPTY,

    // This is an
} RecognitionEventType;

typedef enum
{
    // Audio is encoded as PCM16
    PCM16,
    // Audio is encoded as mu-law 8
    MU_LAW_8,
} EncodingType;

typedef struct AudioEvent
{
    // audio
    unsigned char *audioBuffer;
    // length in bytes of audio buffer
    unsigned long sizeInBytes;
    // What encoding scheme is used for the audio
    EncodingType type;
} AudioEvent;

typedef struct RecognitionEvent
{
    // describes the event type
    RecognitionEventType eventType;
    // audio event, expected to be populated if eventType is audioEvent
    AudioEvent* bytes;
} RecognitionEvent;

#endif
