export interface MagnetometerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  startMagnetometerUpdates(options: { frequency: number }): Promise<void>;
  stopMagnetometerUpdates(): Promise<void>;
  addListener(
      eventName: 'magnetometerData',
      listenerFunc: (data: MagnetometerData) => void
  ): Promise<{ remove: () => void }>;
}

export interface MagnetometerData {
  x: number;
  y: number;
  z: number;
}
