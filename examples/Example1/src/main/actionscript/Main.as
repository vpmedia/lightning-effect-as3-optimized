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
import com.oaxoa.fx.LightningFadeType;

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.Point;

[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
public final class Main extends Sprite {

    private static const cx:uint = 360;

    private static const cy:uint = 320;

    private var ll:Lightning;

    private var dot1:Sprite = new Sprite();

    private var dot2:Sprite = new Sprite();

    private var ball:Sprite = new Sprite();

    private var p:Point;

    public function Main() {

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

        ball.useHandCursor = ball.buttonMode = true;
        dot1.mouseEnabled = dot2.mouseEnabled = false;
        dot1.alpha = .75;

        var glow:GlowFilter = new GlowFilter();
        glow.color = color;
        glow.strength = 3.5;
        glow.quality = 3;
        glow.blurX = glow.blurY = 10;
        ll.filters = dot1.filters = dot2.filters = [glow];
        addChild(ll);

        ll.childrenProbability = .3;

        p = new Point();
        randomizePoint();

        addEventListener(Event.ENTER_FRAME, onframe);

    }

    private function randomizePoint():void {
        var angle:Number = -Math.random() * Math.PI;
        var dist:Number = 160 + Math.random() * 180;
        p.x = cx + Math.cos(angle) * dist;
        p.y = cy + Math.sin(angle) * dist;
    }

    function onframe(event:Event):void {

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

    /*function onmdown(event:MouseEvent):void {
     ball.startDrag();
     }
     ball.addEventListener(MouseEvent.MOUSE_DOWN, onmdown);
     ball.addEventListener(MouseEvent.MOUSE_UP, onmup);
     function onmup(event:MouseEvent):void {
     ball.stopDrag();
     }*/
}
}
