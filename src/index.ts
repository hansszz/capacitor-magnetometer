import { registerPlugin } from '@capacitor/core';

import type { MagnetometerPlugin } from './definitions';

const Magnetometer = registerPlugin<MagnetometerPlugin>('Magnetometer', {
  web: () => import('./web').then(m => new m.MagnetometerWeb()),
});

export * from './definitions';
export { Magnetometer };
