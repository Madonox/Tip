# Tip
`Tip` is an open-source library created for Roblox to enable developers to easily create and edit interactable prompts, labels, and more!

# Usage
Below is all documentation on how to use `Tip`, from initial startup to advanced configuration and use cases.

## Getting Started
In order to begin using `Tip`, you must first require the module.  Since `Tip` is entirely client-sided, it is recommended that you place the module under `ReplicatedStorage`, or some other shared directory.
Once you have placed the `Tip` module in your desired directory, you can begin by requiring the module on the client.
```lua
local Tip = require(path.to.Tip)
```
Once you have this added to your script, you can begin to write code that interfaces with the `Tip` module.  The documentation for all of the module's functions can be found below.
## Hints
Hints are GUI-based notifications that pop up whenever a player gets close enough to a specified point.  Hints can be customized greatly, and can have input-bound functions added to them.
The code below details how to create a `Hint`
```lua
local Tip = require(path.to.Tip)
local Hint = Tip.Hint.new()
Hint:SetPosition(Vector3.new(0,5,0)) -- Move the hint center to 0,5,0
Hint:SetRadius(5) -- Set the detection radius to 5 studs
Hint:SetMessage("Hello!") -- Set the display message to "Hello!"
Hint:Start() -- Enable the hint
```
The code above details a very simple way to create a hint, and does **not** cover all the functionality offered by hints.  More in-depth documentation can be found below.
