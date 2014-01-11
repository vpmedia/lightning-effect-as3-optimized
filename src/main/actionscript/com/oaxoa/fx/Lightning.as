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
package com.oaxoa.fx {

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Timer;

/**
 * Lightning Class
 * AS3 Class to mimic a real lightning or electric discharge
 *
 * @author        Pierluigi Pesenti
 * @contributor   Andras Csizmadia
 * @version        0.6
 *
 */
public class Lightning extends Sprite {

    //----------------------------------
    //  Public Properties
    //----------------------------------

    public var startX:Number;

    public var startY:Number;

    public var endX:Number;

    public var endY:Number;

    //----------------------------------
    //  Internal Properties
    //----------------------------------

    internal var lifeSpan:Number;

    internal var parentInstance:Lightning;

    internal var position:Number = 0;

    internal var absolutePosition:Number = 1;

    internal var alphaFadeType:String;

    internal var thicknessFadeType:String;

    //----------------------------------
    //  Static Properties
    //----------------------------------

    private static const SMOOTH_COLOR:uint = 0x808080;

    //----------------------------------
    //  Getter/Setter Properties
    //----------------------------------

    //----------------------------------
    //  Private Properties
    //----------------------------------

    private var _glow:GlowFilter;
    private var _holder:Sprite;
    private var _sbd:BitmapData;
    private var _bbd:BitmapData;
    private var _soffs:Array;
    private var _boffs:Array;
    private var _lifeTimer:Timer;
    private var _len:Number;
    private var _multi2:Number;
    private var _steps:uint;
    private var _stepEvery:Number;
    private var _seed1:uint;
    private var _seed2:uint;
    private var _smooth:Sprite;
    private var _childrenSmooth:Sprite;
    private var _childrenArray:Array = [];
    private var _smoothPercentage:uint = 50;
    private var _childrenSmoothPercentage:uint;
    private var _color:uint;
    private var _generation:uint;
    private var _childrenMaxGenerations:uint = 3;
    private var _childrenProbability:Number = 0.025;
    private var _childrenProbabilityDecay:Number = 0;
    private var _childrenMaxCount:uint = 4;
    private var _childrenMaxCountDecay:Number = .5;
    private var _childrenLengthDecay:Number = 0;
    private var _childrenAngleVariation:Number = 60;
    private var _childrenLifeSpanMin:Number = 0;
    private var _childrenLifeSpanMax:Number = 0;
    private var _childrenDetachedEnd:Boolean = false;
    private var _maxLength:Number = 0;
    private var _maxLengthVary:Number = 0;
    private var _isVisible:Boolean = true;
    private var _isInitialized:Boolean;
    private var _thickness:Number;
    private var _thicknessDecay:Number;
    private var _wavelength:Number = .3;
    private var _amplitude:Number = .5;
    private var _speed:Number = 1;
    private var _calculatedWavelength:Number;
    private var _calculatedSpeed:Number;
    private var _dx:Number;
    private var _dy:Number;
    private var _soff:Number;
    private var _soffx:Number;
    private var _soffy:Number;
    private var _boff:Number;
    private var _boffx:Number;
    private var _boffy:Number;
    private var _angle:Number;
    private var _tx:Number;
    private var _ty:Number;

    /**
     * Constructor
     */
    public function Lightning(color:uint = 0xffffff, thickness:Number = 2, generation:uint = 0) {
        mouseEnabled = false;
        _color = color;
        _thickness = thickness;
        _generation = generation;
        alphaFadeType = LightningFadeType.GENERATION;
        thicknessFadeType = LightningFadeType.NONE;
        if (_generation == 0)
            initialize();
    }

    /**
     * TBD
     */
    private function initialize():void {
        randomizeSeeds();
        if (lifeSpan > 0)
            startLifeTimer();
        _multi2 = .03;
        _holder = new Sprite();
        _holder.mouseEnabled = false;
        startX = 50;
        startY = 200;
        endX = 50;
        endY = 600;
        _stepEvery = 4;
        _steps = 50;
        _sbd = new BitmapData(_steps, 1, false);
        _bbd = new BitmapData(_steps, 1, false);
        _soffs = [new Point(0, 0), new Point(0, 0)];
        _boffs = [new Point(0, 0), new Point(0, 0)];
        if (_generation == 0) {
            _smooth = new Sprite();
            _childrenSmooth = new Sprite();
            smoothPercentage = 50;
            childrenSmoothPercentage = 50;
        }
        else {
            _smooth = _childrenSmooth = parentInstance._childrenSmooth;
        }
        steps = 100;
        childrenLengthDecay = .5;
        addChild(_holder);
        _isInitialized = true;
    }

    //----------------------------------
    //  API
    //----------------------------------

    /**
     * TBD
     */
    public function startLifeTimer():void {
        _lifeTimer = new Timer(lifeSpan * 1000, 1);
        _lifeTimer.addEventListener(TimerEvent.TIMER, dispose, false, 0, true);
        _lifeTimer.start();
    }

    /**
     * TBD
     */
    public function dispose(event:Event = null):void {
        killAllChildren();
        if (_lifeTimer) {
            _lifeTimer.removeEventListener(TimerEvent.TIMER, dispose);
            _lifeTimer.stop();
        }
        if (parentInstance != null) {
            var count:uint = 0;
            var par:Lightning = this.parent as Lightning;
            for each (var obj:Object in par._childrenArray) {
                if (obj.instance == this) {
                    par._childrenArray.splice(count, 1);
                }
                count++;
            }
        }
        this.parent.removeChild(this);
    }

    /**
     * TBD
     */
    public function killAllChildren():void {
        while (_childrenArray.length > 0) {
            var child:Lightning = _childrenArray[0].instance;
            child.dispose();
        }
    }

    /**
     * TBD
     */
    public function generateChild(n:uint = 1, recursive:Boolean = false):void {
        if (_generation < childrenMaxGenerations && _childrenArray.length < childrenMaxCount) {
            var targetChildSteps:uint = steps * childrenLengthDecay;
            if (targetChildSteps >= 2) {
                for (var i:uint = 0; i < n; i++) {
                    var startStep:uint = Math.random() * steps;
                    var endStep:uint = Math.random() * steps;
                    while (endStep == startStep)
                        endStep = Math.random() * steps;
                    var childAngle:Number = Math.random() * childrenAngleVariation - childrenAngleVariation / 2;
                    var child:Lightning = new Lightning(color, thickness, _generation + 1);
                    child.parentInstance = this;
                    child.lifeSpan = Math.random() * (childrenLifeSpanMax - childrenLifeSpanMin) + childrenLifeSpanMin;
                    child.position = 1 - startStep / steps;
                    child.absolutePosition = absolutePosition * child.position;
                    child.alphaFadeType = alphaFadeType;
                    child.thicknessFadeType = thicknessFadeType;
                    if (alphaFadeType == LightningFadeType.GENERATION)
                        child.alpha = 1 - (1 / (childrenMaxGenerations + 1)) * child._generation;
                    if (thicknessFadeType == LightningFadeType.GENERATION)
                        child.thickness = thickness - (thickness / (childrenMaxGenerations + 1)) * child._generation;
                    child.childrenMaxGenerations = childrenMaxGenerations;
                    child.childrenMaxCount = childrenMaxCount * (1 - childrenMaxCountDecay);
                    child.childrenProbability = childrenProbability * (1 - childrenProbabilityDecay);
                    child.childrenProbabilityDecay = childrenProbabilityDecay;
                    child.childrenLengthDecay = childrenLengthDecay;
                    child.childrenDetachedEnd = childrenDetachedEnd;
                    child.wavelength = wavelength;
                    child.amplitude = amplitude;
                    child.speed = speed;
                    child.initialize();
                    _childrenArray.push({instance: child, startStep: startStep, endStep: endStep, detachedEnd: childrenDetachedEnd, childAngle: childAngle});
                    addChild(child);
                    child.steps = steps * (1 - childrenLengthDecay);
                    if (recursive)
                        child.generateChild(n, true);
                }
            }
        }
    }

    public function update():void {
        if (_isInitialized) {
            _dx = endX - startX;
            _dy = endY - startY;
            _len = Math.sqrt(_dx * _dx + _dy * _dy);
            _soffs[0].x += (steps / 100) * speed;
            _soffs[0].y += (steps / 100) * speed;
            _sbd.perlinNoise(steps / 20, steps / 20, 1, _seed1, false, true, 7, true, _soffs);
            _calculatedWavelength = steps * wavelength;
            _calculatedSpeed = (_calculatedWavelength * .1) * speed;
            _boffs[0].x -= _calculatedSpeed;
            _boffs[0].y += _calculatedSpeed;
            _bbd.perlinNoise(_calculatedWavelength, _calculatedWavelength, 1, _seed2, false, true, 7, true, _boffs);
            if (smoothPercentage > 0) {
                var drawMatrix:Matrix = new Matrix();
                drawMatrix.scale(steps / _smooth.width, 1);
                _bbd.draw(_smooth, drawMatrix);
            }
            if (parentInstance != null) {
                isVisible = parentInstance.isVisible;
            }
            else {
                if (maxLength == 0) {
                    isVisible = true;
                }
                else {
                    var isVisibleProbability:Number;
                    if (_len <= maxLength) {
                        isVisibleProbability = 1;
                    }
                    else if (_len > maxLength + maxLengthVary) {
                        isVisibleProbability = 0;
                    }
                    else {
                        isVisibleProbability = 1 - (_len - maxLength) / maxLengthVary;
                    }
                    isVisible = Math.random() < isVisibleProbability ? true : false;
                }
            }
            var generateChildRandom:Number = Math.random();
            if (generateChildRandom < childrenProbability)
                generateChild();
            if (isVisible)
                render();
            var childObject:Object;
            for each (childObject in _childrenArray) {
                childObject.instance.update();
            }
        }
    }

    public function render():void {
        _holder.graphics.clear();
        _holder.graphics.lineStyle(thickness, _color);
        _angle = Math.atan2(endY - startY, endX - startX);
        var childObject:Object;
        for (var i:uint = 0; i < steps; i++) {
            var currentPosition:Number = 1 / steps * (steps - i)
            var relAlpha:Number = 1;
            var relThickness:Number = thickness;
            if (alphaFadeType == LightningFadeType.TIP_TO_END) {
                relAlpha = absolutePosition * currentPosition;
            }
            if (thicknessFadeType == LightningFadeType.TIP_TO_END) {
                relThickness = thickness * (absolutePosition * currentPosition);
            }
            if (alphaFadeType == LightningFadeType.TIP_TO_END || thicknessFadeType == LightningFadeType.TIP_TO_END) {
                _holder.graphics.lineStyle(int(relThickness), _color, relAlpha);
            }
            _soff = (_sbd.getPixel(i, 0) - 0x808080) / 0xffffff * _len * _multi2;
            _soffx = Math.sin(_angle) * _soff;
            _soffy = Math.cos(_angle) * _soff;
            _boff = (_bbd.getPixel(i, 0) - 0x808080) / 0xffffff * _len * amplitude;
            _boffx = Math.sin(_angle) * _boff;
            _boffy = Math.cos(_angle) * _boff;
            _tx = startX + _dx / (steps - 1) * i + _soffx + _boffx;
            _ty = startY + _dy / (steps - 1) * i - _soffy - _boffy;
            if (i == 0)
                _holder.graphics.moveTo(_tx, _ty);
            _holder.graphics.lineTo(_tx, _ty);
            for each (childObject in _childrenArray) {
                if (childObject.startStep == i) {
                    childObject.instance.startX = _tx;
                    childObject.instance.startY = _ty;
                }
                if (childObject.detachedEnd) {
                    var arad:Number = _angle + childObject.childAngle / 180 * Math.PI;
                    var childLength:Number = _len * childrenLengthDecay;
                    childObject.instance.endX = childObject.instance.startX + Math.cos(arad) * childLength;
                    childObject.instance.endY = childObject.instance.startY + Math.sin(arad) * childLength;
                }
                else {
                    if (childObject.endStep == i) {
                        childObject.instance.endX = _tx;
                        childObject.instance.endY = _ty;
                    }
                }
            }
        }
    }

    public function killSurplus():void {
        while (_childrenArray.length > childrenMaxCount) {
            var child:Lightning = _childrenArray[_childrenArray.length - 1].instance;
            child.dispose();
        }
    }

    //----------------------------------
    //  Getters/Setters
    //----------------------------------

    public function set steps(arg:uint):void {
        if (arg < 2)
            arg = 2;
        if (arg > 2880)
            arg = 2880;
        _steps = arg;
        _sbd = new BitmapData(_steps, 1, false);
        _bbd = new BitmapData(_steps, 1, false);
        if (_generation == 0)
            smoothPercentage = smoothPercentage;
    }

    public function get steps():uint {
        return _steps;
    }

    public function set smoothPercentage(arg:Number):void {
        if (_smooth) {
            _smoothPercentage = arg;
            var smoothmatrix:Matrix = new Matrix();
            smoothmatrix.createGradientBox(steps, 1);
            var ratioOffset:uint = _smoothPercentage / 100 * 128;
            _smooth.graphics.clear();
            _smooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], smoothmatrix);
            _smooth.graphics.drawRect(0, 0, steps, 1);
            _smooth.graphics.endFill();
        }
    }

    public function set childrenSmoothPercentage(arg:Number):void {
        _childrenSmoothPercentage = arg;
        var smoothmatrix:Matrix = new Matrix();
        smoothmatrix.createGradientBox(steps, 1);
        var ratioOffset:uint = _childrenSmoothPercentage / 100 * 128;
        _childrenSmooth.graphics.clear();
        _childrenSmooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], smoothmatrix);
        _childrenSmooth.graphics.drawRect(0, 0, steps, 1);
        _childrenSmooth.graphics.endFill();
    }

    public function get smoothPercentage():Number {
        return _smoothPercentage;
    }

    public function get childrenSmoothPercentage():Number {
        return _childrenSmoothPercentage;
    }

    public function set color(arg:uint):void {
        _color = arg;
        if (_glow) {
            _glow.color = arg;
            _holder.filters = [_glow];
        }
        for each (var child:Object in _childrenArray)
            child.instance.color = arg;
    }

    public function get color():uint {
        return _color;
    }

    public function set childrenProbability(arg:Number):void {
        if (arg > 1) {
            arg = 1
        }
        else if (arg < 0)
            arg = 0;
        _childrenProbability = arg;
    }

    public function get childrenProbability():Number {
        return _childrenProbability;
    }

    public function set childrenProbabilityDecay(arg:Number):void {
        if (arg > 1) {
            arg = 1
        }
        else if (arg < 0)
            arg = 0;
        _childrenProbabilityDecay = arg;
    }

    public function get childrenProbabilityDecay():Number {
        return _childrenProbabilityDecay;
    }

    public function set maxLength(arg:Number):void {
        _maxLength = arg;
    }

    public function get maxLength():Number {
        return _maxLength;
    }

    public function set maxLengthVary(arg:Number):void {
        _maxLengthVary = arg;
    }

    public function get maxLengthVary():Number {
        return _maxLengthVary;
    }

    public function set thickness(arg:Number):void {
        if (arg < 0)
            arg = 0;
        _thickness = arg;
    }

    public function get thickness():Number {
        return _thickness;
    }

    public function set thicknessDecay(arg:Number):void {
        if (arg > 1) {
            arg = 1
        }
        else if (arg < 0)
            arg = 0;
        _thicknessDecay = arg;
    }

    public function get thicknessDecay():Number {
        return _thicknessDecay;
    }

    public function set childrenLengthDecay(arg:Number):void {
        if (arg > 1) {
            arg = 1
        }
        else if (arg < 0)
            arg = 0;
        _childrenLengthDecay = arg;
    }

    public function get childrenLengthDecay():Number {
        return _childrenLengthDecay;
    }

    public function set childrenMaxGenerations(arg:uint):void {
        _childrenMaxGenerations = arg;
        killSurplus();
    }

    public function get childrenMaxGenerations():uint {
        return _childrenMaxGenerations;
    }

    public function set childrenMaxCount(arg:uint):void {
        _childrenMaxCount = arg;
        killSurplus();
    }

    public function get childrenMaxCount():uint {
        return _childrenMaxCount;
    }

    public function set childrenMaxCountDecay(arg:Number):void {
        if (arg > 1) {
            arg = 1
        }
        else if (arg < 0)
            arg = 0;
        _childrenMaxCountDecay = arg;
    }

    public function get childrenMaxCountDecay():Number {
        return _childrenMaxCountDecay;
    }

    public function set childrenAngleVariation(arg:Number):void {
        _childrenAngleVariation = arg;
        for each (var o:Object in _childrenArray) {
            o.childAngle = Math.random() * arg - arg / 2;
            o.instance.childrenAngleVariation = arg;
        }
    }

    public function get childrenAngleVariation():Number {
        return _childrenAngleVariation;
    }

    public function set childrenLifeSpanMin(arg:Number):void {
        _childrenLifeSpanMin = arg;
    }

    public function get childrenLifeSpanMin():Number {
        return _childrenLifeSpanMin;
    }

    public function set childrenLifeSpanMax(arg:Number):void {
        _childrenLifeSpanMax = arg;
    }

    public function get childrenLifeSpanMax():Number {
        return _childrenLifeSpanMax;
    }

    public function set childrenDetachedEnd(arg:Boolean):void {
        _childrenDetachedEnd = arg;
    }

    public function get childrenDetachedEnd():Boolean {
        return _childrenDetachedEnd;
    }

    public function set wavelength(arg:Number):void {
        _wavelength = arg;
        for each (var o:Object in _childrenArray) {
            o.instance.wavelength = arg;
        }
    }

    public function get wavelength():Number {
        return _wavelength;
    }

    public function set amplitude(arg:Number):void {
        _amplitude = arg;
        for each (var o:Object in _childrenArray) {
            o.instance.amplitude = arg;
        }
    }

    public function get amplitude():Number {
        return _amplitude;
    }

    public function set speed(arg:Number):void {
        _speed = arg;
        for each (var o:Object in _childrenArray) {
            o.instance.speed = arg;
        }
    }

    public function get speed():Number {
        return _speed;
    }

    public function set isVisible(arg:Boolean):void {
        _isVisible = visible = arg;
    }

    public function get isVisible():Boolean {
        return _isVisible;
    }

    //----------------------------------
    //  Helper methods
    //----------------------------------

    private function randomizeSeeds():void {
        _seed1 = Math.random() * 100;
        _seed2 = Math.random() * 100;
    }
}
}
