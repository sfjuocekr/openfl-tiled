// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled". <http://github.com/Kasoki/openfl-tiled>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package openfl.tiled.display;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.tiled.TiledMap;

class CopyPixelsRenderer implements Renderer {

	private var map:TiledMap;

	public function new() {
	}

	public function setTiledMap(map:TiledMap):Void {
		this.map = map;
	}

	public function drawLayer(on:Dynamic, layer:Layer):Void {
		var bitmapData = new BitmapData(map.totalWidth, map.totalHeight, true, map.backgroundColor);
		var gidCounter:Int = 0;

		if(layer.visible) {
			for(y in 0...map.heightInTiles) {
				for(x in 0...map.widthInTiles) {
					var nextGID = layer.tiles[gidCounter].gid;

					if(nextGID != 0) {
						var point:Point = new Point();

						switch (map.orientation) {
							case TiledMapOrientation.Orthogonal:
								point = new Point(x * map.tileWidth, y * map.tileHeight);
							case TiledMapOrientation.Isometric:
								point = new Point((map.width + x - y - 1) * map.tileWidth * 0.5, (y + x) * map.tileHeight * 0.5);
						}

						var tileset:Tileset = map.getTilesetByGID(nextGID);

						var rect:Rectangle = tileset.getTileRectByGID(nextGID);

						if(map.orientation == TiledMapOrientation.Isometric) {
							point.x += map.totalWidth * 0.5;
						}

						// copy pixels
						bitmapData.copyPixels(tileset.image.texture, rect, point, null, null, true);
					}

					gidCounter++;
				}
			}
		}

		var bitmap = new Bitmap(bitmapData);

		if(map.orientation == TiledMapOrientation.Isometric) {
			bitmap.x -= map.totalWidth * 0.5;
		}

		on.addChild(bitmap);
	}

	public function drawImageLayer(on:Dynamic, imageLayer:ImageLayer):Void {
		var bitmap = new Bitmap(imageLayer.image.texture);

		on.addChild(bitmap);
	}

	public function clear(on:Dynamic):Void {
		while(on.numChildren > 0){
			on.removeChildAt(0);
		}
	}
}