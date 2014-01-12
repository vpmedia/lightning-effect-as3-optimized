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
import com.oaxoa.fx.LightningFadeType;

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;

// http://blog.oaxoa.com/wp-content/examples/showExample.php?f=lightning_test_coil.swf&w=727&h=566

[SWF(width="800", height="600", frameRate="30", backgroundColor="#001a4d")]
public final class Main extends Sprite {

    private static const cx:uint = 360;

    private static const cy:uint = 320;

    private var ll:Lightning;

    private var dot1:Sprite;

    private var dot2:Sprite;

    private var ball:Sprite;

    private var p:Point;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }

    private function onAdded(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        // lightning
        var color:uint = 0xffffff;
        ll = new Lightning(color, 2);
        ll.blendMode = BlendMode.ADD;
        ll.childrenDetachedEnd = true;
        ll.childrenLifeSpanMin = .1;
        ll.childrenLifeSpanMax = 2;
        ll.childrenMaxCount = 4;
        ll.childrenMaxCountDecay = .5;
        ll.steps = 150;
        ll.alphaFadeType = LightningFadeType.TIP_TO_END;
        ll.childrenProbability = .3;
        addChild(ll);
        // ball
        ball = new Sprite();
        ball.useHandCursor = ball.buttonMode = true;
        ball.graphics.beginFill(0xCCCCCC);
        ball.graphics.drawCircle(0, 0, 15);
        ball.graphics.endFill();
        ball.x = 400;
        ball.y = 50;
        addChild(ball);
        // dot1
        dot1 = new Sprite();
        dot1.mouseEnabled = false;
        dot1.graphics.beginFill(0x666666);
        dot1.graphics.drawCircle(0, 0, 8);
        dot1.graphics.endFill();
        dot1.alpha = .75;
        dot1.x = 100;
        dot1.y = 100;
        addChild(dot1);
        // dot2
        dot2 = new Sprite();
        dot2.graphics.beginFill(0x333333);
        dot2.graphics.drawCircle(0, 0, 8);
        dot2.graphics.endFill();
        dot2.mouseEnabled = false;
        dot2.x = 600;
        dot2.y = 100;
        addChild(dot2);
        // glow for all
        var glow:GlowFilter = new GlowFilter();
        glow.color = color;
        glow.strength = 3.5;
        glow.quality = 3;
        glow.blurX = glow.blurY = 10;
        ll.filters = dot1.filters = dot2.filters = [glow];

        p = new Point();
        randomizePoint();

        ball.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        ball.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(Event.ENTER_FRAME, onFrameEnter);
    }

    private function onFrameEnter(event:Event):void {

        var rnd:Number = Math.random();
        if (rnd < .05) randomizePoint();
        var dx:Number = cx - ball.x;
        var dy:Number = cy - ball.y;
        var d:Number = Math.sqrt(dx * dx + dy * dy);
        if (d < 310) {
            dot2.visible = true;
            if (ll.childrenDetachedEnd) {
                ll.childrenDetachedEnd = false;
                ll.alphaFadeType = LightningFadeType.GENERATION;
                ll.disposeAllChildren();
            }

            ll.endX = dot2.x = ball.x;
            ll.endY = dot2.y = ball.y;
        } else {
            dot2.visible = false;
            if (!ll.childrenDetachedEnd) {
                ll.childrenDetachedEnd = true;
                ll.alphaFadeType = LightningFadeType.TIP_TO_END;
                ll.disposeAllChildren();
            }
            ll.endX = p.x;
            ll.endY = p.y;
        }
        var ddx:Number = cx - ll.endX;
        var ddy:Number = cy - ll.endY;
        var aangle:Number = Math.atan2(ddy, ddx);
        ll.startX = cx - Math.cos(aangle) * 80;
        dot1.scaleX = Math.sin(aangle);
        ll.startY = cy;
        dot1.x = ll.startX;
        dot1.y = ll.startY;
        ll.update();
    }

    private function randomizePoint():void {
        var angle:Number = -Math.random() * Math.PI;
        var dist:Number = 160 + Math.random() * 180;
        p.x = cx + Math.cos(angle) * dist;
        p.y = cy + Math.sin(angle) * dist;
    }

    private function onMouseDown(event:MouseEvent):void {
        ball.startDrag();
    }

    private function onMouseUp(event:MouseEvent):void {
        ball.stopDrag();
    }
}
}
