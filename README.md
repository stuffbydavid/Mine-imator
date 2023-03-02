# Mine-imator

<p align="center">
  <img src="https://www.mineimatorforums.com/uploads/monthly_2021_08/image.png.4699187f1f02be8222a5bf5100c1738f.png" width=800/>
  <br/>
  <br/>
  <img src="https://www.mineimatorforums.com/uploads/monthly_2023_03/336815532_programview.png.9212aa1f6d1bed63411408aa5e905ce0.png" width=800/>
</p>

Mine-imator is a 3D movie maker based on the sandbox game Minecraft, with over 8 million downloads since its launch in 2012. Version 2.0, the 10th anniversary update brings numerous additions including a new UI, new renderer, animation features, multiplatform support and 3D world importer.

Website and download: https://www.mineimator.com

The software is written using GameMaker Language and converted to a separate C++ environment using a custom built GML parser (CppGen). The final executable is built for Windows, Mac OS and Linux using the Qt framework, DirectX/OpenGL rendering and various other libraries.

<hr/>

MBMod Changelog since Mine-imator 2.0.0:

Changes:
<ul>
  <li>Individual blocks for Chorus Plant and Fire can now be fully customized in the workbench.</li>
  <li>Individual blocks and vertically repeating stacks for Iron Bars, Glass Panes, Fences, Walls, and Tripwire can now be fully customized in the workbench.</li>
  <li>Minecraft font now supports nearly every unicode character supported by Minecraft as of 1.19.3.</li>
  <li>Custom item slot interpolation is now floored instead of rounded.</li>
  <li>Added support for new 'text_scale' field for text on imported signs.</li>
  <li>Custom object fog color can now be animated with Environment timelines.</li>
</ul>
  
Bugfixes:
<ul>
  <li>Fixed minutes counter in timeline timer not resetting when an hour has passed.</li>
  <li>Fixed incorrect frame order with interpolated textures.</li>
  <li>Fixed crash with empty tag lists in schematics (dev_mode).</li>
</ul>
