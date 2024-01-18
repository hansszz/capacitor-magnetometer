import { WebPlugin } from '@capacitor/core';

import type { MagnetometerPlugin } from './definitions';

export class MagnetometerWeb extends WebPlugin implements MagnetometerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
