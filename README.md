# isomap-love2d
Isometric map engine/library for Love2D

<img src="http://i.imgur.com/4QwPYLu.png" width="480">

## What's this?
This is a simple isometric map decoder and renderer. It can load maps with information stored on a JSON file and render the isometric map to the screen with a simple function call and a few parameters.
The example uses mouse wheel to zoom in and zoom out, and arrow keys to move the map around.

## What now?
I'll keep on adding things, such as elevation and maybe programmable tiles. I'll make a nice level editor too if needed. Won't be fast though.

### Modules used:
* [DKJson](https://github.com/LuaDist/dkjson) for json parsing. Used by the library itself.
* [Lovebird](https://github.com/rxi/lovebird) since it helps wonders with table content viewing. Used in the demo included.
* [Kenney's isometric sprites](https://kenney.nl/) since I suck at drawing. Used in the demo.
* [segfaultd](https://github.com/danielpontello) for drawing an example notice board, can be seen in the demo.

# Great, but how do I use it?
* First, create a JSON file, a "props" new folder, and a "textures" new folder in the root of your love project. Your project will look like this:
<img src="http://i.imgur.com/MbfmgC4.png" width="550">

* Add all textures you want to use for the ground layer to the *"textures"* folder. They **need** to have absolutely the same dimensions.

* Add all prop textures you will place on your map to the *"props"* folder. These can be any dimensions you'd like.

And you should be set up to create everything you need.

# JSON map structure
The basic JSON map will look a bit like this:
```JSON
{
"textures":
[
	{
		"file": "myTexture.*",
		"mnemonic": "myTexture"
	}
],
	
"props":
[
	{
		"file": "myProp.*",
		"mnemonic": "myProp",
		"origin" : "50|72"
	}
],
  
"data":
[     
	[["myTexture"],["myTexture"],["myTexture"]],
	[["myTexture"],["myTexture", "myProp"],["myTexture"]],
	[["myTexture"],["myTexture"],["myTexture"]]
],

"general":
[
	{
		"name":"Map name",
		"version":"string with map version",
		"lighting":"255|255|255"
	}
]
}
```
Lets analyze it's parts.

### Textures
```JSON
"textures":
[
	{
		"file": "myTexture.png",
		"mnemonic": "myTexture"
	},
        {
		"file": "myTexture2.jpg",
		"mnemonic": "myTexture2"
	},
       {
        "And so on":"for all textures you'll use"
       }
],
```
This is where you'll load your ground layer textures. It has 2 fields:
* name: Specifies the texture filename. Can be any kind of image file Love loads. Examples are .PNG and .JPG files.
* mnemonic: Specifies a more friendly name given to the texture. Used in the map matrix. (See below).

**All ground textures need to have the same exact dimensions!**

### Props
```JSON
"textures":
[
	{
		"file": "myProp.png",
		"mnemonic": "myProp",
                "origin": "X|Y"
	},
        {
		"file": "myProp2.jpg",
		"mnemonic": "myProp2"
                "origin": "X|Y"
	},
       {
        "And so on":"for all props you'll use"
       }
],
```
This is where you'll load your map props or objects. It has 3 fields:
* name: Specifies the texture used in the prop. Can be any kind of image file Love loads.
* mnemonic: Specifies a more friendly name given to the prop. Used in the map matrix. (See below).
* origin: Specifies the offset used to draw the prop on the tile where it should be. Values should be X and Y separated by a pipe ("|"). To find out this offset, use any image editor you want! Then you modify your values until you can get it right.

Prop textures can be any size you want.

### Data
```JSON
"data":
[     
	[["myTexture"],["myMnemonic"],["myTexture"]],
	[["myTexture"],["myTexture", "myProp"],["myTexture"]],
	[["myTexture"],["myTexture"],["myTexture"]]
],
```
Pretty straightforward. Use the *mnemonics* you defined for your props and textures above and put then into a JSON matrix. I'm not sure, but I think only one prop can be placed per tile. In this example, a map with a 3x3 size would be rendered with texture *myTexture*, and *myProp* prop would be placed in the middle tile[2][2]. Obviously, larger data matrixes will yield bigger maps.

### General
```JSON
"general":
[
	{
		"name":"Map name",
		"version":"string with map version",
		"lighting":"R|G|B"
	}
]
```
Specifies general map information, as well as other extras.
* name: Specifies the map name.
* version: Specifies a map version.
* lighting: A small trick. Values are RGB values separated by a pipe ("|"). Defines the color you want to use to draw your map. If you specify, say, a dark blue, it'll give the map a blue tone, faking a night environment. Be creative! Set this value to "255|255|255" if you don't want to use this feature.

# Isomap methods
## isomap.decodeJson(filename)
Decodes a given JSON file.

*Arguments:*
* filename: The JSON filepath.

*Example*:
```Lua
isomap.decodeJson("Jsonfile.json")
```
## isomap.generatePlayfield()
Generates the playfield with information provided by the preovously loaded JSON file.

*No arguments.*

*Example:*
```Lua
isomap.generatePlayfield()
```
## isomap.drawGround(x, y, zoomLevel)
Draws the map with a *X* and a *Y* offset scaled by *zoomLevel*.

*Arguments:*
* **x** and **y**: X and Y offset for map drawing.
* zoomLevel: a number specifiying the scale the map should be rendered. Used primarily for zooming in and out.

*Example:*
```Lua
isomap.drawGround(300, 200, 1.5)
```

## isomap.drawObjects(x, y, zoomLevel)
Sorts ZBuffer and draws objects on the map with a *X* and a *Y* offset scaled by *zoomLevel*.

*Arguments:*
* **x** and **y**: X and Y offset for object drawing.
* zoomLevel: a number specifiying the scale the objects should be rendered. Used primarily for zooming in and out.

*Example:*
```Lua
isomap.drawObjects(300, 200, 1.5)
```
## isomap.toIso(x, y)
Converts *x* and *y* from cartesian (2D) to isometric coordinates.

*Arguments:*
* **x** and **y**: X and Y values to be converted.

*Example:*
```Lua
isomap.toIso(420, 350)
```
## isomap.toCartesian(x, y)
Converts *x* and *y* from isometric to cartesian (2D) coordinates.

*Arguments:*
* **x** and **y**: X and Y values to be converted.

*Example:*
```Lua
isomap.toCartesian(5, 8)
```
# Minimal usage example
```Lua
isomap = require ("isomap")
function love.load()
	--Variables
	x = 0
	y = 0

	--Set background to deep blue
	love.graphics.setBackgroundColor(0, 0, 69)

	--Decode JSON map file
	isomap.decodeJson("JSONMap.json")

	--Generate map from JSON file (loads assets and creates tables)
	isomap.generatePlayField()
end

function love.update(dt)
	--Get player input so map moves around.
	if love.keyboard.isDown("left") then x = x + 900*dt end
	if love.keyboard.isDown("right") then x = x - 900*dt end
	if love.keyboard.isDown("up") then y = y+900*dt end
	if love.keyboard.isDown("down") then y = y-900*dt end
end

function love.draw()
	isomap.draw(x, y, 1)
end

```

# Personal recommendations
I recommend using [rxi's autobatch](https://github.com/rxi/autobatch) library to reduce draw calls made by this library to draw your map!

# Contact
Rants, questions, suggestions and anything else, [drop me an email here](mailto:pedrorocha@gec.inatel.br).
