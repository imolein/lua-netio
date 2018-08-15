# Returend data structures

## Status table

The **Status** table is returned by the **info()** method and contains all
informations which the API provides.

**Example:**

```lua
{
  Agent = {
    DeviceName = "NETIO 4ALL Demo",
    JSONVer = "2.1",
    Model = "NETIO 4All",
    NumOutputs = 4,
    OemID = 0,
    SerialNumber = "24:A4:2C:39:11:5A",
    Time = "2018-08-15T18:44:28+01:00",
    Uptime = 490866,
    VendorID = 0,
    Version = "3.1.0"
  },
  GlobalMeasure = {
    EnergyStart = "2018-01-19T13:30:26+00:00",
    Frequency = 50.1,
    OverallPowerFactor = 0,
    TotalCurrent = 0,
    TotalEnergy = 2253,
    TotalLoad = 0,
    Voltage = 239.1
  },
  Outputs = { {
      Action = 6,
      Current = 0,
      Delay = 5000,
      Energy = 0,
      ID = 1,
      Load = 0,
      Name = "output_1",
      PowerFactor = 0,
      State = 1
    }, {
      Action = 6,
      Current = 0,
      Delay = 5000,
      Energy = 0,
      ID = 2,
      Load = 0,
      Name = "output_2",
      PowerFactor = 0,
      State = 1
    }, {
      Action = 6,
      Current = 0,
      Delay = 5000,
      Energy = 2081,
      ID = 3,
      Load = 0,
      Name = "output_3",
      PowerFactor = 0,
      State = 0
    }, {
      Action = 6,
      Current = 0,
      Delay = 5000,
      Energy = 172,
      ID = 4,
      Load = 0,
      Name = "output_4",
      PowerFactor = 0,
      State = 1
    } }
}
```

## Agent table

The **Agent** table is returned by the **general_info()** method and contains the
**Agent** part of the [**Status** table](#Status_table).

**Example:**

```lua
{
    DeviceName = "NETIO 4ALL Demo",
    JSONVer = "2.1",
    Model = "NETIO 4All",
    NumOutputs = 4,
    OemID = 0,
    SerialNumber = "24:A4:2C:39:11:5A",
    Time = "2018-08-15T18:44:28+01:00",
    Uptime = 490866,
    VendorID = 0,
    Version = "3.1.0"
}
```

## GlobalMeasure table

The **GlobalMeasure** table is returned by the **measure_info()** method and contains the
**GlobalMeasure** part of the [**Status** table](#Status_table).

**Example:**

```lua
{
  EnergyStart = "2018-01-19T13:30:26+00:00",
  Frequency = 50.1,
  OverallPowerFactor = 0,
  TotalCurrent = 0,
  TotalEnergy = 2253,
  TotalLoad = 0,
  Voltage = 239.1
}
```

## Ouputs table

The **Outputs** table is returned by the **outputs_info()** method and contains the
**Outputs** part of the [**Status** table](#Status_table).

* If a specific output is given as parameter, only the nested table with the matching output ID is returned
* The **outputs_action()** methods (**outputs_on()** etc.) return the complete outputs table

 **Example:**

```lua
{
  {
    Action = 6,
    Current = 0,
    Delay = 5000,
    Energy = 0,
    ID = 1,
    Load = 0,
    Name = "output_1",
    PowerFactor = 0,
    State = 1
  }, {
    Action = 6,
    Current = 0,
    Delay = 5000,
    Energy = 0,
    ID = 2,
    Load = 0,
    Name = "output_2",
    PowerFactor = 0,
    State = 1
  }, {
    Action = 6,
    Current = 0,
    Delay = 5000,
    Energy = 2081,
    ID = 3,
    Load = 0,
    Name = "output_3",
    PowerFactor = 0,
    State = 0
  }, {
    Action = 6,
    Current = 0,
    Delay = 5000,
    Energy = 172,
    ID = 4,
    Load = 0,
    Name = "output_4",
    PowerFactor = 0,
    State = 1
  }
}
```
