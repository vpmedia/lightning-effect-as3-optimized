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
import com.bit101.components.ComboBox;
import com.bit101.components.Slider;
import com.oaxoa.fx.Lightning;
import com.oaxoa.fx.LightningFadeType;
import com.oaxoa.fx.LightningType;

import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextFormat;

[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
public final class Main extends Sprite {
    private var ll:Lightning;

    private var cross1:MovieClip;
    private var cross2:MovieClip;

    private var circles:Shape;

    private var cb0:ComboBox;
    private var cb1:ComboBox;
    private var cb2:ComboBox;
    private var cb3:ComboBox;

    private var slider1:Slider;
    private var slider2:Slider;
    private var slider3:Slider;
    private var slider4:Slider;
    private var slider5:Slider;
    private var slider6:Slider;
    private var slider7:Slider;
    private var slider8:Slider;
    private var slider9:Slider;
    private var slider10:Slider;
    private var slider11:Slider;
    private var slider12:Slider;
    private var slider13:Slider;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }

    private function onAdded(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        //
        cross1 = new MovieClip();
        cross1.graphics.beginFill(0xFFFFFF);
        cross1.graphics.drawCircle(0, 0, 8);
        cross1.graphics.endFill();
        cross1.x = 100;
        cross1.y = 400;
        addChild(cross1);
        cross1.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        cross1.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        //
        cross2 = new MovieClip();
        cross2.graphics.beginFill(0xFFFFFF);
        cross2.graphics.drawCircle(0, 0, 8);
        cross2.graphics.endFill();
        cross2.x = 700;
        cross2.y = 400;
        addChild(cross2);
        cross2.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        cross2.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        //
        cross1.buttonMode = cross2.buttonMode = cross1.useHandCursor = cross2.useHandCursor = true;
        //
        var color:uint = 0xffffff;
        ll = new Lightning(color, 2);
        ll.blendMode = BlendMode.ADD;
        ll.startX = cross1.x;
        ll.startY = cross1.y;
        ll.endX = cross2.x;
        ll.endY = cross2.y;
        ll.childrenMaxGenerations = 3;
        ll.childrenMaxCountDecay = .5;
        addChild(ll);
        //
        var glow:GlowFilter = new GlowFilter();
        glow.color = color;
        glow.strength = 4;
        glow.quality = 3;
        glow.blurX = glow.blurY = 10;
        ll.filters = [glow];
        //
        var d:int = 0;
        //
        cb0 = new ComboBox(this, d);
        cb0.addItem({label: "Choose a preset", value: 0});
        cb0.addItem({label: "Fast discharge", value: 1});
        cb0.addItem({label: "Fast discharge (Max length + max length variation)", value: 2});
        cb0.addItem({label: "Fast discharge (slow-motion)", value: 3});
        cb0.addItem({label: "Moving Thunderbolt", value: 4});
        cb0.addItem({label: "Moving Thunderbolt (Max length + max length variation)", value: 5});
        cb0.selectedIndex = 0;
        cb0.addEventListener(Event.CHANGE, onComboChange);

        cb1 = new ComboBox(this, d+=105);
        cb1.addItem({label: "Discharge", value: false});
        cb1.addItem({label: "Lightning (detached end)", value: true});
        cb1.selectedIndex = 1;
        cb1.addEventListener(Event.CHANGE, onComboChange);

        cb2 = new ComboBox(this, d+=105);
        cb2.addItem({label: "None", value: LightningFadeType.NONE});
        cb2.addItem({label: "Generation", value: LightningFadeType.GENERATION});
        cb2.addItem({label: "Tip to end", value: LightningFadeType.TIP_TO_END});
        cb2.selectedIndex = 2;
        cb2.addEventListener(Event.CHANGE, onComboChange);

        cb3 = new ComboBox(this, d+=105);
        cb3.addItem({label: "None", value: LightningFadeType.NONE});
        cb3.addItem({label: "Generation", value: LightningFadeType.GENERATION});
        cb3.addItem({label: "Tip to end", value: LightningFadeType.TIP_TO_END});
        cb3.selectedIndex = 2;
        cb3.addEventListener(Event.CHANGE, onComboChange);

        d = 0;
        slider1 = new Slider(Slider.HORIZONTAL, this, d, 100);
        slider1.addEventListener(Event.CHANGE, onSliderChange);
        slider2 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider2.addEventListener(Event.CHANGE, onSliderChange);
        slider3 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider3.addEventListener(Event.CHANGE, onSliderChange);
        slider4 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider4.addEventListener(Event.CHANGE, onSliderChange);
        slider5 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider5.addEventListener(Event.CHANGE, onSliderChange);
        slider6 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider6.addEventListener(Event.CHANGE, onSliderChange);
        slider7 = new Slider(Slider.HORIZONTAL, this, d+=105, 100);
        slider7.addEventListener(Event.CHANGE, onSliderChange);
        d = 0;
        slider8 = new Slider(Slider.HORIZONTAL, this, d, 200);
        slider8.addEventListener(Event.CHANGE, onSliderChange);
        slider9 = new Slider(Slider.HORIZONTAL, this, d+=105, 200);
        slider9.addEventListener(Event.CHANGE, onSliderChange);
        slider10 = new Slider(Slider.HORIZONTAL, this, d+=105, 200);
        slider10.addEventListener(Event.CHANGE, onSliderChange);
        slider11 = new Slider(Slider.HORIZONTAL, this, d+=105, 200);
        slider11.addEventListener(Event.CHANGE, onSliderChange);
        slider12 = new Slider(Slider.HORIZONTAL, this, d+=105, 200);
        slider12.addEventListener(Event.CHANGE, onSliderChange);
        slider13 = new Slider(Slider.HORIZONTAL, this, d+=105, 200);
        slider13.addEventListener(Event.CHANGE, onSliderChange);


        var tf:TextFormat = new TextFormat();
        tf.color = 0xffffff;

        circles = new Shape();
        addChildAt(circles, 0);

        addEventListener(Event.ENTER_FRAME, onEnter);
    }

    private function onEnter(event:Event):void {
        ll.startX = cross1.x;
        ll.startY = cross1.y;
        ll.endX = cross2.x;
        ll.endY = cross2.y;
        ll.update();
        updateCircles();
    }

    private function onComboChange(event:Event):void {
        var t:ComboBox = event.currentTarget as ComboBox;
        trace(this, "onComboChange", t);
        switch (t) {
            case cb0:
                setPreset(t.selectedItem.value);
                break;
            case cb1:
                ll.childrenDetachedEnd = t.selectedItem.value;
                ll.disposeAllChildren();
                break;
            case cb2:
                ll.alphaFadeType = t.selectedItem.value;
                ll.disposeAllChildren();
                break;
            case cb3:
                ll.thicknessFadeType = t.selectedItem.value;
                ll.disposeAllChildren();
                break;
        }
    }

    private function onSliderChange(event:Event):void {
        var t:Slider = event.currentTarget as Slider;
        trace(this, "onSliderChange", t);
        //ttip.show(t.value.toString());
        // ttip.y = t.y - 30;
        switch (t) {
            case slider1:
                ll.smoothPercentage = t.value;
                break;
            case slider2:
                ll.childrenAngleVariation = t.value;
                break;
            case slider3:
                ll.childrenMaxCount = t.value;
                break;
            case slider4:
                ll.wavelength = t.value;
                break;
            case slider5:
                ll.amplitude = t.value;
                break;
            case slider6:
                ll.speed = t.value;
                break;
            case slider7:
                ll.thickness = t.value;
                ll.disposeAllChildren();
                break;
            case slider8:
                ll.maxLength = t.value;
                break;
            case slider9:
                ll.maxLengthVary = t.value;
                break;
            case slider10:
                ll.childrenProbability = t.value;
                ll.disposeAllChildren();
                break;
            case slider11:
                ll.childrenLifeSpanMin = t.value;
                ll.disposeAllChildren();
                if (t.value > slider12.value) slider12.value = t.value;
                break;
            case slider12:
                ll.childrenLifeSpanMax = t.value;
                ll.disposeAllChildren();
                slider11.visible = t.value != 0;
                break;
            case slider13:
                ll.steps = t.value;
                ll.disposeAllChildren();
                break;
        }
        ll.render();
    }

    private function setPreset(n:uint):void {
        trace(this, "setPreset", n);
        switch (n) {
            case 1:
                // fast discharge
                LightningType.setType(ll, LightningType.DISCHARGE);
                cb1.selectedIndex = 0;
                cb2.selectedIndex = 1;
                cb3.selectedIndex = 0;
                break;
            case 2:
                // fast discharge (with max length+variation)
                LightningType.setType(ll, LightningType.DISCHARGE);
                ll.maxLength = 440;
                ll.maxLengthVary = 75;
                cb1.selectedIndex = 0;
                cb2.selectedIndex = 1;
                cb3.selectedIndex = 0;

                break;
            case 3:
                // fast discharge slow motion
                LightningType.setType(ll, LightningType.DISCHARGE);
                ll.speed = .1;
                cb1.selectedIndex = 0;
                cb2.selectedIndex = 1;
                cb3.selectedIndex = 0;

                break;
            case 4:
                // moving thunder
                LightningType.setType(ll, LightningType.LIGHTNING);
                cb1.selectedIndex = 1;
                cb2.selectedIndex = 2;
                cb3.selectedIndex = 1;

                break;
            case 5:
                // moving thunder (with max length+variation)
                LightningType.setType(ll, LightningType.LIGHTNING);
                ll.maxLength = 440;
                ll.maxLengthVary = 75;
                ll.childrenDetachedEnd = true;
                ll.alphaFadeType = LightningFadeType.TIP_TO_END;
                ll.thicknessFadeType = LightningFadeType.GENERATION;
                cb1.selectedIndex = 1;
                cb2.selectedIndex = 2;
                cb3.selectedIndex = 1;
                break;
        }
        ll.disposeAllChildren();
        updateSliders();
    }

    private function updateSliders():void {
        slider1.value = ll.smoothPercentage;
        slider2.value = ll.childrenAngleVariation;
        slider3.value = ll.childrenMaxCount;
        slider4.value = ll.wavelength;
        slider5.value = ll.amplitude;
        slider6.value = ll.speed;
        slider7.value = ll.thickness;
        slider8.value = ll.maxLength;
        slider9.value = ll.maxLengthVary;
        slider10.value = ll.childrenProbability;
        slider11.value = ll.childrenLifeSpanMin;
        slider12.value = ll.childrenLifeSpanMax;
        slider13.value = ll.steps;
    }

///////////////////

    private function onMouseDown(event:MouseEvent):void {
        event.currentTarget.alpha = .2;
        event.currentTarget.startDrag();
    }

    private function onMouseUp(event:MouseEvent):void {
        event.currentTarget.alpha = 1;
        event.currentTarget.stopDrag();
    }

    private function updateCircles():void {
        circles.graphics.clear();
        if (ll.maxLength > 0) {
            circles.graphics.lineStyle(6, 0xffffff, .3);
            circles.graphics.drawCircle(cross1.x, cross1.y, ll.maxLength);
            circles.graphics.lineStyle(2, 0xffffff, .4);
            circles.graphics.drawCircle(cross1.x, cross1.y, ll.maxLength + ll.maxLengthVary);
            /*var steps:uint = 5;
             for (var i:uint = 1; i

             } */
        }
    }
}
}
