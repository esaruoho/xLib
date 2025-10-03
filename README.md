# com.renoise.xLib.xrnx

xLib is a pure lua library which can add additional functionality to your Renoise tools.  
This tool contains some unit-tests of the various classes contained in xLib.

The xLib library is a suite of classes that extend the standard Renoise API. 

For example, xLib contains alternative implementations of `renoise.NoteColumn` and `renoise.EffectColumn` that works the same as their Renoise counterpart, but can be freely defined anywhere (does not belong to a specific line in a pattern). 

Other classes are nothing more than a bunch of static methods that can be called without having to create an instance first. This includes, for example, the `xPatternSequencer`

> As a general organizing principle, if a class is closely modelled over a Renoise API counterpart, the name will reflect this. 

## Requirements

xLib requires an additional library called cLib, which you can get here:  
https://github.com/renoise/tools/tree/master/Tools/com.renoise.cLib.xrnx

## How to use 

If you are planning to use xLib in your own project, start by including the xLib.lua file, and any classes you need

```lua
-- set up include-path
_xlibroot = 'source/xLib/classes/'

-- require some classes
require (_xlibroot..'xLib')
require (_xlibroot..'xSample')
```


> Note: it's important that you specify the include path, as it's used internally as well.  

### Special considerations

To improve performance, xLib is using a single reference to the Renoise song object - called `rns`. You will need to define and maintain this variable yourself. For example, by refreshing it when a new document becomes available:

```lua
renoise.tool().app_new_document_observable:add_notifier(function()
  rns = renoise.song()
end)
```

## Documentation

Point your browser to this location to browse the auto-generated luadocs:  
https://renoise.github.io/libraries/xlib

## Examples

xLib is used in many of the tools on our github repository:  
https://github.com/renoise/tools/tree/master/Tools

There is a packaged (renoise tool) version of xLib, configured to run some unit-tests:
http://github.com/esaruoho/xLib/releases
