package com.example.capacitormagnetometer;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Magnetometer")
public class MagnetometerPlugin extends Plugin {

    private SensorManager sensorManager;
    private Sensor magnetometer;
    private SensorEventListener sensorEventListener;

    @Override
    public void load() {
        sensorManager = (SensorManager) getContext().getSystemService(Context.SENSOR_SERVICE);
        magnetometer = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
    }

    @PluginMethod
    public void startMagnetometerUpdates(PluginCall call) {
        if (magnetometer == null) {
            call.reject("Magnetometer sensor not available.");
        } else {
            startListening();
            call.resolve();
        }
    }

    @PluginMethod
    public void stopMagnetometerUpdates(PluginCall call) {
        stopListening();
        call.resolve();
    }


    private void startListening() {
        sensorEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                // This method will be called when the magnetometer data changes

                JSObject data = new JSObject();
                data.put("x", event.values[0]);
                data.put("y", event.values[1]);
                data.put("z", event.values[2]);

                // Notify the JavaScript side of the new data
                notifyListeners("magnetometerData", data);
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
                // If you want, you can also handle accuracy changes
            }
        };

        sensorManager.registerListener(sensorEventListener, magnetometer, SensorManager.SENSOR_DELAY_NORMAL);
    }

    private void stopListening() {
        if (sensorEventListener != null) {
            sensorManager.unregisterListener(sensorEventListener);
            sensorEventListener = null; // Release the listener reference
        }
    }
    protected void handleOnStop() {
        super.handleOnStop();
        stopListening(); // Stop sensor updates when the activity is not visible
    }

    @Override
    protected void handleOnDestroy() {
        super.handleOnDestroy();
        stopListening(); // Ensure sensor updates are stopped when the activity is destroyed
    }
}
