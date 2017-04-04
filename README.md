# isomap-love2d
Isometric map engine/library for Love2D

<img src="http://i.imgur.com/4QwPYLu.png" width="480">

## What's this?
This is a simple isometric map decoder and renderer. It can load maps with information stored on a JSON file and render the isometric map to the screen with a simple function call and a few parameters.
The example uses mouse wheel to zoom in and zoom out, and arrow keys to move the map around.

## What now?
I'll keep on adding things, such as elevation and maybe programmable tiles. I'll make a nice level editor too if needed. Won't be fast though.

### Modules used:
* [DKJson](https://github.com/LuaDist/dkjson) for json parsing.
* [Autobatch for love2D](https://github.com/rxi/autobatch), so things don't slow down too much.
* [Lovedebug](https://github.com/Ranguna/LOVEDEBUG) so you can have a nice ingame console. Disabled though.
* [Lovebird](https://github.com/rxi/lovebird) since it helps wonders with table content viewing.
* [Kenney's isometric sprites](https://kenney.nl/) since I suck at drawing. (The example tree is an example.)
* [segfaultd](https://github.com/danielpontello) for drawing an example notice board, can be seen in the demo.

