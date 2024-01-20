#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(MagnetometerPlugin, "Magnetometer",
           CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startMagnetometerUpdates, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stopMagnetometerUpdates, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addListener, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(removeListener, CAPPluginReturnNone);
)
