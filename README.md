# irredit_relative
My bash script to make IrrEdit working by editing its paths in .irr files


## How to use
Considering this project directory tree:

-- myPoject>

----source>

----lib>

----maps>

--------textures>

--------convert.sh

--------levelX>

------------levelX.irr

------------levelX.irr.meshes>

------------convert.sh -> ../convert.sh

With convert.sh being in maps/ as in each levelX/ directories (you can use ln -s)

You need to launch in your levelX directory

    ./convert.sh levelX.irr

With levelX.irr your irrlicht scene (if you are launching from level1, just run ./convert.sh level1.irr). It will create the converted files as __'c_levelX*'__.

##Why?

I wanted to work with CopperCube/Irredit, but I didn't like the idea of doing levels under windows so I launched it from Wine and it all went well!

But, there is always a but, in *.irr files you have lines like:

	<texture name="Texture1" value="z:\home\pellet_k\téléchargements\3d\textures\hexagontile_hgt.png" />

And of course it doesn't work if you are installing your game on Linux, and even in Windows because it is an absolute path.

Sometimes IrrEdit does absolute paths, sometimes it doesn't. But in any cases it keeps the path from where you get your textures/3d/sound/etc... and it may not be your current project directory.

So I made this bash script to make my life easier. and I just need now to say to Irrlicht:

    scenemgr->loadScene("maps/levelX/c_levelX.irr");

The new file created has __'c_'__ prepended to the file name.

You can use and abuse of this script in any way you'd like. But please if you see something wrong just put an issue it may help =D
