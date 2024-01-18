# capacitor-magnetometer

Custom Capacitor plugin to access the device's magnetometer sensor data for building compass applications on iOS and Android.

## Install

```bash
npm install capacitor-magnetometer
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`startMagnetometerUpdates(...)`](#startmagnetometerupdates)
* [`stopMagnetometerUpdates()`](#stopmagnetometerupdates)
* [`addListener('magnetometerData', ...)`](#addlistenermagnetometerdata)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### startMagnetometerUpdates(...)

```typescript
startMagnetometerUpdates(options: { frequency: number; }) => Promise<void>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ frequency: number; }</code> |

--------------------


### stopMagnetometerUpdates()

```typescript
stopMagnetometerUpdates() => Promise<void>
```

--------------------


### addListener('magnetometerData', ...)

```typescript
addListener(eventName: 'magnetometerData', listenerFunc: (data: MagnetometerData) => void) => Promise<{ remove: () => void; }>
```

| Param              | Type                                                                             |
| ------------------ | -------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'magnetometerData'</code>                                                  |
| **`listenerFunc`** | <code>(data: <a href="#magnetometerdata">MagnetometerData</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;{ remove: () =&gt; void; }&gt;</code>

--------------------


### Interfaces


#### MagnetometerData

| Prop    | Type                |
| ------- | ------------------- |
| **`x`** | <code>number</code> |
| **`y`** | <code>number</code> |
| **`z`** | <code>number</code> |

</docgen-api>
