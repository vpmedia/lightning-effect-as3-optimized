/*
 Licensed under the MIT License

 Copyright (c) 2008 Pierluigi Pesenti (blog.oaxoa.com)
 Contributor 2014 Andras Csizmadia (www.vpmedia.hu)

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
 */
package {
import com.oaxoa.fx.Lightning;

import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

// http://blog.oaxoa.com/wp-content/examples/showExample.php?f=lightning_test_plug.swf&w=413&h=564

[SWF(width="800", height="600", frameRate="30", backgroundColor="#001a4d")]
public final class Main extends Sprite {
    private var fingers;
    private var dot1:Sprite;
    private var dot2:Sprite;
    private var dot3:Sprite;
    private var dot4:Sprite;
    private var ll:Lightning;
    private var ll2:Lightning;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }

    private function onAdded(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);

        fingers = new MovieClip();
        addChild(fingers);
        //
        dot1 = new Sprite();
        dot1.name = "dot1";
        dot1.graphics.beginFill(0x333333);
        dot1.graphics.drawCircle(0, 0, 8);
        dot1.graphics.endFill();
        fingers.addChild(dot1);
        //
        dot2 = new Sprite();
        dot2.name = "dot2";
        dot2.graphics.beginFill(0x666666);
        dot2.graphics.drawCircle(0, 0, 8);
        dot2.graphics.endFill();
        fingers.addChild(dot2);
        dot2.x = 50;

        fingers.y = 400;
        fingers.x = fingers.y / 2.5 - 10;

        //
        dot3 = new Sprite();
        dot3.graphics.beginFill(0xFF0000);
        dot3.graphics.drawCircle(0, 0, 8);
        dot3.graphics.endFill();
        dot3.x = 50;
        dot3.y = 50;
        addChild(dot3);

        //
        dot4 = new Sprite();
        dot4.graphics.beginFill(0x00FF00);
        dot4.graphics.drawCircle(0, 0, 8);
        dot4.graphics.endFill();
        dot4.x = 150;
        dot4.y = 50;
        addChild(dot3);

        //
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

        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(Event.ENTER_FRAME, onFrameEnter);
    }

    private function updatePositions():void {
        ll.endX = fingers.x + dot1.x;
        ll.endY = fingers.y + dot1.y;
        ll2.endX = fingers.x + dot2.x;
        ll2.endY = fingers.y + dot2.y;
    }

    private function onMouseMove(event:MouseEvent):void {
        //trace(this, "onMouseMove");
        fingers.y = mouseY - 150;
        if (fingers.y > 600) fingers.y = 600;
        fingers.x = fingers.y / 2.5 - 10;
        updatePositions();
       // event.updateAfterEvent();
    }

    private function onFrameEnter(event:Event):void {
        ll.update();
        ll2.update();
    }

}
}
