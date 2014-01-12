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
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextFormat;

public final class Main extends Sprite {
    private var ll:Lightning;

    private var cross1:MovieClip = new MovieClip();
    private var cross2:MovieClip = new MovieClip();

    private var circles:MovieClip = new MovieClip();

    private var cb0:MovieClip;
    private var cb1:MovieClip;
    private var cb2:MovieClip;
    private var cb3:MovieClip;
    private var cb4:MovieClip;
    private var cb5:MovieClip;
    private var cb6:MovieClip;
    private var cb7:MovieClip;
    private var cb8:MovieClip;
    private var cb9:MovieClip;
    private var cb10:MovieClip;
    private var cb11:MovieClip;
    private var cb12:MovieClip;
    private var cb13:MovieClip;

    private var slider:MovieClip;
    private var slider1:MovieClip;
    private var slider2:MovieClip;
    private var slider3:MovieClip;
    private var slider4:MovieClip;
    private var slider5:MovieClip;
    private var slider6:MovieClip;
    private var slider7:MovieClip;
    private var slider8:MovieClip;
    private var slider9:MovieClip;
    private var slider10:MovieClip;
    private var slider11:MovieClip;
    private var slider12:MovieClip;
    private var slider13:MovieClip;

    public function Main() {
        var color:uint = 0xffffff;
        ll = new Lightning(color, 2);
        ll.blendMode = BlendMode.ADD;

        var glow:GlowFilter = new GlowFilter();
        glow.color = color;
        glow.strength = 4;
        glow.quality = 3;
        glow.blurX = glow.blurY = 10;
        ll.filters = [glow];
        addChild(ll);
        ll.startX = cross1.x;
        ll.startY = cross1.y;

        ll.endX = cross2.x;
        ll.endY = cross2.y;

        setChildIndex(ll, 0);

        ll.childrenMaxGenerations = 3;
        ll.childrenMaxCountDecay = .5;

        var tfmt:TextFormat = new TextFormat("_sans", 11, 0xffffff);

        cb0.addItem({label: "Choose a preset", value: 0});
        cb0.addItem({label: "Fast discharge", value: 1});
        cb0.addItem({label: "Fast discharge (Max length + max length variation)", value: 2});
        cb0.addItem({label: "Fast discharge (slow-motion)", value: 3});
        cb0.addItem({label: "Moving Thunderbolt", value: 4});
        cb0.addItem({label: "Moving Thunderbolt (Max length + max length variation)", value: 5});
        cb0.selectedIndex = 0;
        cb0.addEventListener(Event.CHANGE, oncb);
        cb0.textField.setStyle("textFormat", tfmt);
        cb0.dropdown.setRendererStyle("textFormat", tfmt);

        cb1.addItem({label: "Discharge", value: false});
        cb1.addItem({label: "Lightning (detached end)", value: true});
        cb1.selectedIndex = 1;
        cb1.addEventListener(Event.CHANGE, oncb);
        cb1.textField.setStyle("textFormat", tfmt);
        cb1.dropdown.setRendererStyle("textFormat", tfmt);

        cb2.addItem({label: "None", value: LightningFadeType.NONE});
        cb2.addItem({label: "Generation", value: LightningFadeType.GENERATION});
        cb2.addItem({label: "Tip to end", value: LightningFadeType.TIP_TO_END});
        cb2.selectedIndex = 2;
        cb2.addEventListener(Event.CHANGE, oncb);
        cb2.textField.setStyle("textFormat", tfmt);
        cb2.dropdown.setRendererStyle("textFormat", tfmt);

        cb3.addItem({label: "None", value: LightningFadeType.NONE});
        cb3.addItem({label: "Generation", value: LightningFadeType.GENERATION});
        cb3.addItem({label: "Tip to end", value: LightningFadeType.TIP_TO_END});
        cb3.selectedIndex = 2;
        cb3.addEventListener(Event.CHANGE, oncb);
        cb3.textField.setStyle("textFormat", tfmt);
        cb3.dropdown.setRendererStyle("textFormat", tfmt);


        slider.addEventListener(Event.CHANGE, onslider);
        slider2.addEventListener(Event.CHANGE, onslider);
        slider3.addEventListener(Event.CHANGE, onslider);
        slider4.addEventListener(Event.CHANGE, onslider);
        slider5.addEventListener(Event.CHANGE, onslider);
        slider6.addEventListener(Event.CHANGE, onslider);
        slider7.addEventListener(Event.CHANGE, onslider);
        slider8.addEventListener(Event.CHANGE, onslider);
        slider9.addEventListener(Event.CHANGE, onslider);
        slider10.addEventListener(Event.CHANGE, onslider);
        slider11.addEventListener(Event.CHANGE, onslider);
        slider12.addEventListener(Event.CHANGE, onslider);
        slider13.addEventListener(Event.CHANGE, onslider);


        var tf:TextFormat = new TextFormat();
        tf.color = 0xffffff;

        cross1.addEventListener(MouseEvent.MOUSE_UP, onup);
        cross1.addEventListener(MouseEvent.MOUSE_DOWN, ondown);
        cross2.addEventListener(MouseEvent.MOUSE_UP, onup);
        cross2.addEventListener(MouseEvent.MOUSE_DOWN, ondown);
        cross1.buttonMode = cross2.buttonMode = cross1.useHandCursor = cross2.useHandCursor = true;


        var circles:Shape = new Shape();
        addChildAt(circles, 0);

        addEventListener(Event.ENTER_FRAME, onframe);
    }

    function onframe(event:Event):void {
        ll.startX = cross1.x;
        ll.startY = cross1.y;

        ll.endX = cross2.x;
        ll.endY = cross2.y;
        ll.update();
        updateCircles();
    }

    function oncb(event:Event):void {
        var t:MovieClip = event.currentTarget as MovieClip;
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

    function onslider(event:Event):void {
        var t:MovieClip = event.currentTarget as MovieClip;
        //ttip.show(t.value.toString());
        // ttip.y = t.y - 30;
        switch (t) {
            case slider:
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

    function setPreset(n:uint):void {
        switch (n) {
            // fast discharge
            case 1:
                ll.childrenLifeSpanMin = 1;
                ll.childrenLifeSpanMax = 3;
                ll.childrenProbability = 1;
                ll.childrenMaxGenerations = 3;
                ll.childrenMaxCount = 4;
                ll.childrenAngleVariation = 110;
                ll.thickness = 2;
                ll.steps = 100;

                ll.smoothPercentage = 50;
                ll.wavelength = .3;
                ll.amplitude = .5;
                ll.speed = .7;
                ll.maxLength = 0;
                ll.maxLengthVary = 0;

                ll.childrenDetachedEnd = false;
                cb1.selectedIndex = 0;
                ll.alphaFadeType = LightningFadeType.GENERATION;
                cb2.selectedIndex = 1;
                ll.thicknessFadeType = LightningFadeType.NONE;
                cb3.selectedIndex = 0;

                break;
            // fast discharge (with max length+variation)
            case 2:
                ll.childrenLifeSpanMin = 1;
                ll.childrenLifeSpanMax = 3;
                ll.childrenProbability = 1;
                ll.childrenMaxGenerations = 3;
                ll.childrenMaxCount = 4;
                ll.childrenAngleVariation = 110;
                ll.thickness = 2;
                ll.steps = 100;

                ll.smoothPercentage = 50;
                ll.wavelength = .3;
                ll.amplitude = .5;
                ll.speed = .7;
                ll.maxLength = 440;
                ll.maxLengthVary = 75;

                ll.childrenDetachedEnd = false;
                cb1.selectedIndex = 0;
                ll.alphaFadeType = LightningFadeType.GENERATION;
                cb2.selectedIndex = 1;
                ll.thicknessFadeType = LightningFadeType.NONE;
                cb3.selectedIndex = 0;

                break;
            // fast discharge slowmo
            case 3:
                ll.childrenLifeSpanMin = 1;
                ll.childrenLifeSpanMax = 3;
                ll.childrenProbability = 1;
                ll.childrenMaxGenerations = 3;
                ll.childrenMaxCount = 4;
                ll.childrenAngleVariation = 110;
                ll.thickness = 2;
                ll.steps = 100;

                ll.smoothPercentage = 50;
                ll.wavelength = .3;
                ll.amplitude = .5;
                ll.speed = .1;
                ll.maxLength = 0;
                ll.maxLengthVary = 0;

                ll.childrenDetachedEnd = false;
                cb1.selectedIndex = 0;
                ll.alphaFadeType = LightningFadeType.GENERATION;
                cb2.selectedIndex = 1;
                ll.thicknessFadeType = LightningFadeType.NONE;
                cb3.selectedIndex = 0;

                break;
            // moving thumnder
            case 4:
                ll.childrenLifeSpanMin = .1;
                ll.childrenLifeSpanMax = 2;
                ll.childrenProbability = 1;
                ll.childrenMaxGenerations = 3;
                ll.childrenMaxCount = 4;
                ll.childrenAngleVariation = 130;
                ll.thickness = 3;
                ll.steps = 100;

                ll.smoothPercentage = 50;
                ll.wavelength = .3;
                ll.amplitude = .5;
                ll.speed = 1;
                ll.maxLength = 0;
                ll.maxLengthVary = 0;

                ll.childrenDetachedEnd = true;
                cb1.selectedIndex = 1;
                ll.alphaFadeType = LightningFadeType.TIP_TO_END;
                cb2.selectedIndex = 2;
                ll.thicknessFadeType = LightningFadeType.GENERATION;
                cb3.selectedIndex = 1;

                break;
            case 5:
                ll.childrenLifeSpanMin = .1;
                ll.childrenLifeSpanMax = 2;
                ll.childrenProbability = 1;
                ll.childrenMaxGenerations = 3;
                ll.childrenMaxCount = 4;
                ll.childrenAngleVariation = 130;
                ll.thickness = 3;
                ll.steps = 100;

                ll.smoothPercentage = 50;
                ll.wavelength = .3;
                ll.amplitude = .5;
                ll.speed = 1;
                ll.maxLength = 440;
                ll.maxLengthVary = 75;

                ll.childrenDetachedEnd = true;
                cb1.selectedIndex = 1;
                ll.alphaFadeType = LightningFadeType.TIP_TO_END;
                cb2.selectedIndex = 2;
                ll.thicknessFadeType = LightningFadeType.GENERATION;
                cb3.selectedIndex = 1;

                break;
        }
        ll.disposeAllChildren();
        updateSliders();
    }

    function updateSliders():void {
        slider.value = ll.smoothPercentage;
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

    function ondown(event:MouseEvent):void {
        event.currentTarget.alpha = .2;
        event.currentTarget.startDrag();
    }

    function onup(event:MouseEvent):void {
        event.currentTarget.alpha = 1;
        event.currentTarget.stopDrag();
    }

    function updateCircles():void {
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
