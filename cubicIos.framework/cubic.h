#ifndef CUBIC_CUBIC_H_
#define CUBIC_CUBIC_H_

#ifdef __cplusplus
extern "C"
{
#endif
    // C API header file.
    /**
     * @file cubic.h
     * This is a thread-safe speech recognition API. The objective of this API is to convert
     * speech to text.
     *
     * There are two main types of 'objects' in this API: Models and Recognizers.
     *
     * A Model is an encapsulation for machine-learned artifacts that were trained in
     * offline, supervised fashion. Models are the 'brain' of our system. Models own the
     * the accuracy or recognition.
     *
     * A Recognizer is created from a model and contains the logic for performing speech recognition.
     * Recognizers own the latency and stability of recognition.
     *
     * Models are typically heavy weight objects that should be created once and used often. Recognizers
     * are light weight objects should be created per audio stream (unless otherwise advised).
     *
     * This API provides two main classes of functions: API level functions, prefixed by API_, are responsible
     * for creating and deleting objects, such as models and recognizers. Object specific functions,
     * prefixed by object names such as Recognizer_, are responsible for controlling specific functionality of each
     * object, such as pushing audio to a recognizer.
     *
     * Each API call returns success of failure. If the call is successful, the object created for the API call may be used;
     * if the call failed, the reason for failure is documented in the return struct.
     *
     * The API is stateful, and uses string (char*) based IDs to maintain state; e.g. clients create a Models and
     * control the ID of the model by setting modelIdC, that model may then be used by calling other API functions
     * with the same ID.
     *
     * Memory management is crucial to the success of the API, the client must make sure each pointer object
     * passed to an API call remains in scope until the call returns. Pointers returned by the API will remain
     * in scope until the client calls the "clear" function. Best practice is to copy the contents each pointer, and call
     * clear() immediately, to avoid memory usage growth.
     *
     * The API delivers objects via callbacks, e.g. logging, metrics, and results.
     *
     * Callbacks are registered as function pointers. The registration calls are not thread-safe. Best practice
     * is to registered each callback once at the start of the process. Callbacks should be registered prior to any other
     * API calls.
     *
     * The API delivers per-recognition results in asynchronous fashion. To allow the client to map a result to a recognizer,
     * the result (and metrics) callbacks contain a field for the id of the recognizer. Each recognizer object delivers
     * (0+) results per lifetime, depending on the underlying model and Recognizer_ API calls.
     *
     */


#include "api_types.h"
#include "flags.h"

    /**
     * Entry point for creating a new model.
     * \param[in] modelIdC	The ID of the successfully created model,
     * 						if call is successful, clients may use the model by sending the ID to
     * 						other API calls.
     * 						The ID must be unique, the API call will fail if clients attempt to create
     * 						a model with a ID identical to an existing model.
     *
     * \param[in] modelPathC 	The on-disk filepath of the model.
     */
    CUBICDLL ApiReturn Api_NewModel(CubicString modelIdC, CubicString modelPathC);


    /**
     * Entry point for getting attributes of a model.
     *
     * Attributes are returned as JSON, and contains useful infomation for clients, such as
     * audio frequency, or model type.
     *
     * The memory contained in the return type is valid, as long as the model is not deleted,
     * there is no need to clear the memory.
     *
     * \param[in] modelIdC  The ID of the model to get attributes for
     */
    CUBICDLL ModelsetAttributesReturn Api_GetModelsetAttributes(CubicString modelIdC);

    /**
     * Entry point for adding a phrase to a keyword (key phrase) spotter model.
     * \param[in] modelIdC The ID of an existing keyword model
     *
     * \param[in] jsonListC The serialized JSON list of strings to be added
     */
    CUBICDLL ApiReturn Model_AddPhrases(CubicString modelIdC, CubicString jsonListC);

    /**
     * Entry point for removing a keyword (key phrase) from a spotter model
     * \param[in] modelIdC The ID of an existing keyword model
     *
     * \param[in] jsonListC The serialized JSON list of strings to be removed
     */
    CUBICDLL ApiReturn Model_RemovePhrases(CubicString modelIdC, CubicString jsonListC);

    /**
     * Entry point for deleting an existing model.
     *
     * \param[in] modelIdC	The ID of the model to be deleted.
     *
     */
    CUBICDLL ApiReturn Api_DeleteModel(CubicString modelIdC);

    /**
     * Entry point for creating a new recognizer.
     *
     * \param[in] recognizerIdC		The ID of the successfully created recognizer.
     * 						If this API call is successful, clients may use the recognizer by sending the ID to
     * 						other API calls.
     * 						The ID must be unique, the API call will fail if clients attempt to create
     * 						a recognizer with a ID identical to an existing recognizer.
     *
     * \param[in] modelIdC 	The ID of the model to the recognizer used by the recognizer.
     * 						Clients must be mindful to select the 'compatible' model with a recognizer.
     *
     * 						e.g. Accuracy will degrade if clients create a recognizer with a model trained to recognize
     * 						16 KHZ audio, then send 8 KHZ audio to that recognizer.
     *
     * \param[in] synchronus Set to non-0 for synchronous mode operation, 0 for asynchronous mode operation
     *                       The main difference between the two modes of operations is that pushing audio events become
     *                       non-blocking calls during asynchronous. The client thread is allowed to process other events while
     *                       our background worker processes the audio.
     */
    CUBICDLL ApiReturn Api_NewRecognizer(CubicString recognizerIdC, CubicString modelIdC, int synchronus);

    /**
     * Entry point for deleting a recognizer.
     *
     * \param[in] recognizerIdC		The ID of the recognizer to be deleted.
     *
     */
    CUBICDLL ApiReturn Api_DeleteRecognizer(CubicString recognizerIdC);

    /**
     * Entry point for pushing audio to a recognizer.
     *
     * \param[in] recognizerIdC		The ID of the recognizer. The recognizer must already exist, through
     * 								the NewRecognizer call.
     *
     * \param[in] event				The recognition event. Examples of event types are audio events and
     * 								end-of-session events.
     *
     */
    CUBICDLL ApiReturn Recognizer_PushEvent(CubicString recognizerIdC, RecognitionEvent* event);

    /**
     * Entry point for registering a logging callback
     *
     * \param[in] callback 			Function Pointer to make callbacks to.
     *
     */
    CUBICDLL ApiReturn Api_RegisterLoggingCallback(Logging_Callback callback);

    /**
     * Entry point for registering a results callback
     *
     * \param[in] callback 			Function Pointer to make callbacks to.
     *
     */
    CUBICDLL ApiReturn Api_RegisterResultsCallback(Results_Callback callback);

    /**
     * Entry point for registering a metrics callback
     *
     * \param[in] callback 			Function Pointer to make callbacks to.
     *
     */
    CUBICDLL ApiReturn Api_RegisterMetricsCallback(Metrics_Callback callback);


    /**
     * Entry point for registering a Json callback
     *
     * \param[in] callback          Function Pointer to make callbacks to.
     *
     */
    CUBICDLL ApiReturn Api_RegisterJsonCallback(Json_Callback callback);

    /**
     * Entry point for registering an auxiliary model callback
     *
     * \param[in] callback          Function Pointer to make callbacks to.
     *
     */
    CUBICDLL ApiReturn Api_RegisterAuxiliaryModelCallback(AuxiliaryModel_Callback callback);

    /**
     * Entry point for adding objects to a recognizer
     *
     * \param[in] recognizerIdC     The ID of the recognizer where we want to add the binary object.
     *                              It must already exist via the Api_NewRecognizer call
     *
     * \param[in] objectName        The name of the object that we want to add to the archive.
     *                              The name must not collide with the name of another object
     *                              which was saved previously in that archive
     *
     * \param[in] object            Struct containing the size of the object and the char* to that archive data
     */
    CUBICDLL ApiReturn Recognizer_PushArchiveObject(CubicString recognizerIdC,CubicString objectName,CubicBinaryObject object);

    /**
     * Entry point for getting a saved archive
     *
     *\param[in] recognizerIdC          The ID of the archive we want to get. It must be an existing recognizer
     *                                  created by Api_NewRecognizdr call
     *
     */
    CUBICDLL CubicArchiveReturn Api_GetArchiveFromRecognizer(CubicString recognizerIdC);

    /**
     * Entry point for deleting memory.
     * The library will return objects that are active on the heap, e.g. error messages.
     * The client should use this function to clear that memory, after the client no longer needs the memory.
     *
     * \param[in] clear 			The Pointer for the memory to be cleared.
     *
     */
    CUBICDLL void Api_Clear(Memory clear);

    /**
     * Entry point for getting the library verion information
     * The library will return the output of
     * git describe --dirty --always --tags
     * which was collected at build time
     *
     */
    CUBICDLL CubicString Api_GetCubicVersion();

#ifdef __cplusplus
} // extern "C"
#endif
#endif /* CUBIC_CUBIC_H_ */
