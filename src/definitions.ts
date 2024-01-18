export interface MagnetometerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
