/*
 Licensed under the MIT License

 Copyright (c) 2008 Pierluigi Pesenti

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 http://blog.oaxoa.com/
 */
package {
import com.oaxoa.fx.Lightning;

import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
public final class Main extends Sprite {
    private var fingers:MovieClip = new MovieClip();
    private var dot3:Sprite = new Sprite();
    private var dot4:Sprite = new Sprite();
    private var ll:Lightning;
    private var ll2:Lightning;

    public function Main() {

        var dot1:Sprite = new Sprite();
        dot1.name = "dot1";
        fingers.addChild(dot1);
        var dot2:Sprite = new Sprite();
        dot2.name = "dot2";
        fingers.addChild(dot2);
        dot2.x = 50;

        fingers.x = fingers.y = 200;

        dot3.x = dot3.y = 10;
        dot4.x = dot4.y = 200;


        addChild(fingers);
        addChild(dot3);
        addChild(dot4);

        setChildIndex(fingers, 2);
        var iy:Number = fingers.y;

        fingers.x = fingers.y / 2.5 - 10;

        var color:uint = 0xddeeff;
        ll = new Lightning(color, 2);
        ll2 = new Lightning(color, 2);
        ll.blendMode = ll2.blendMode = BlendMode.ADD;
        ll.childrenProbability = ll2.childrenProbability = .5;
        ll.childrenLifeSpanMin = ll2.childrenLifeSpanMin = .1;
        ll.childrenLifeSpanMax = ll2.childrenLifeSpanMax = 2;
        ll.maxLength = ll2.maxLength = 50;
        ll.maxLengthVary = ll2.maxLengthVary = 200;

        ll.startX = dot3.x;
        ll.startY = dot3.y;
        ll2.startX = dot4.x;
        ll2.startY = dot4.y;

        var glow:GlowFilter = new GlowFilter();
        glow.color = color;
        glow.strength = 3.5;
        glow.quality = 3;
        glow.blurX = glow.blurY = 10;
        ll.filters = ll2.filters = [glow];
        addChild(ll);
        addChild(ll2);

        updatePositions();

        addEventListener(MouseEvent.MOUSE_MOVE, onmove);
        addEventListener(Event.ENTER_FRAME, onframe);
    }


    function updatePositions():void {
        ll.endX = fingers.x + fingers.getChildByName("dot1").x;
        ll.endY = fingers.y + fingers.getChildByName("dot1").y;
        ll2.endX = fingers.x + fingers.getChildByName("dot2").x;
        ll2.endY = fingers.y + fingers.getChildByName("dot2").y;
    }

    function onmove(event:MouseEvent):void {
        fingers.y = mouseY - 150;
        if (fingers.y == 320) fingers.y = 320;
        fingers.x = fingers.y / 2.5 - 10;
        updatePositions();
        event.updateAfterEvent();
    }

    function onframe(event:Event):void {
        ll.update();
        ll2.update();
    }

}
}
