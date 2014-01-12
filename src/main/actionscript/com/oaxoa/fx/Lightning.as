/*
 The MIT License (MIT)

 Copyright (c) 2008 Pierluigi Pesenti (blog.oaxoa.com)
 Contributor 2014 Andras Csizmadia (www.vpmedia.eu)

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
package com.oaxoa.fx {
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Timer;

/**
 * Lightning Class
 * AS3 Class to mimic a real lightning or electric discharge
 *
 * @author        Pierluigi Pesenti (blog.oaxoa.com)
 * @contributor   Andras Csizmadia (www.vpmedia.eu)
 * @version        0.6.0
 *
 */
public class Lightning extends Sprite {

    //----------------------------------
    //  Public Properties
    //----------------------------------

    /** TBD */
    public var startX:Number;

    /** TBD */
    public var startY:Number;

    /** TBD */
    public var endX:Number;

    /** TBD */
    public var endY:Number;

    /** TBD */
    public var thickness:Number;

    /** TBD */
    public var childrenLifeSpanMin:Number;

    /** TBD */
    public var childrenLifeSpanMax:Number;

    /** TBD */
    public var childAngle:Number;

    /** TBD */
    public var maxLength:Number;

    /** TBD */
    public var maxLengthVary:Number;

    /** TBD */
    public var startStep:uint;

    /** TBD */
    public var endStep:uint;

    /** TBD */
    public var alphaFadeType:String;

    /** TBD */
    public var thicknessFadeType:String;

    /** TBD */
    public var childrenDetachedEnd:Boolean;

    //----------------------------------
    //  Static Properties
    //----------------------------------

    /** @private */
    private static const SMOOTH_COLOR:uint = 0x808080;

    /** @private */
    private static const WHITE_COLOR:uint = 0xFFFFFF;

    /** @private */
    private static var ID:uint = 0;

    //----------------------------------
    //  Internal Properties
    //----------------------------------

    /** Internal identifier */
    internal var id:uint = ID++;

    /** Generation level */
    internal var generation:uint;

    /** Life time */
    internal var lifeSpan:Number;

    /** Position, used to alpha calc. */
    internal var position:Number;

    /** Abs. position, used to alpha calc. */
    internal var absolutePosition:Number;

    /** Children smoothing display object helper */
    internal var childrenSmooth:Sprite;

    /** Reference to the parent Lightning. */
    internal var parentInstance:Lightning;

    //----------------------------------
    //  Getter/Setter Properties
    //----------------------------------

    /** @private */
    private var _steps:uint;

    /** @private */
    private var _smoothPercentage:uint;

    /** @private */
    private var _childrenSmoothPercentage:uint;

    /** @private */
    private var _childrenAngleVariation:Number;

    /** @private */
    private var _childrenProbability:Number;

    /** @private */
    private var _childrenProbabilityDecay:Number;

    /** @private */
    private var _childrenMaxGenerations:uint;

    /** @private */
    private var _childrenMaxCount:uint;

    /** @private */
    private var _childrenMaxCountDecay:Number;

    /** @private */
    private var _childrenLengthDecay:Number;

    /** @private */
    private var _thicknessDecay:Number;

    /** @private */
    private var _wavelength:Number;

    /** @private */
    private var _amplitude:Number;

    /** @private */
    private var _speed:Number;

    //----------------------------------
    //  Private Properties
    //----------------------------------

    /** @private */
    private var _smooth:Sprite;

    /** @private */
    private var _smoothMatrix:Matrix;

    /** @private */
    private var _drawMatrix:Matrix;

    /** @private */
    private var _sbd:BitmapData;

    /** @private */
    private var _bbd:BitmapData;

    /** @private */
    private var _lifeTimer:Timer;

    /** @private */
    private var _sOffsets:Array;

    /** @private */
    private var _bOffsets:Array;

    /** @private */
    private var _seed1:uint;

    /** @private */
    private var _seed2:uint;

    /** @private */
    private var _color:uint;

    /** @private */
    private var _len:Number;

    /** @private */
    private var _multi2:Number;

    /** @private */
    private var _stepEvery:Number;

    /** @private */
    private var _dx:Number;

    /** @private */
    private var _dy:Number;

    /** @private */
    private var _soff:Number;

    /** @private */
    private var _soffx:Number;

    /** @private */
    private var _soffy:Number;

    /** @private */
    private var _boff:Number;

    /** @private */
    private var _boffx:Number;

    /** @private */
    private var _boffy:Number;

    /** @private */
    private var _angle:Number;

    /** @private */
    private var _tx:Number;

    /** @private */
    private var _ty:Number;

    //----------------------------------
    //  Constructor
    //----------------------------------

    /**
     * Constructor
     *
     * @param color The lightning color
     * @param thickness The lightning thickness
     * @param generation The lightning sub-generation
     */
    public function Lightning(color:uint = 0xFFFFFF, thickness:Number = 2, generation:uint = 0) {
        preInitialize(color, thickness, generation);
    }

    //----------------------------------
    //  Private Methods
    //----------------------------------

    /**
     * @private
     */
    private function preInitialize(color:uint, thickness:Number, generation:uint):void {
        setupDefaults();
        _color = color;
        this.thickness = thickness;
        this.generation = generation;
        if (this.generation == 0)
            initialize();
        //trace(this, "initialize");
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
    }

    /**
     * @private
     */
    private function setupDefaults():void {
        // public
        startX = 0;
        startY = 0;
        endX = 0;
        endY = 0;
        thickness = 2;
        childrenLifeSpanMin = 0;
        childrenLifeSpanMax = 0;
        childAngle = 0;
        maxLength = 0;
        maxLengthVary = 0;
        startStep = 0;
        endStep = 0;
        alphaFadeType = LightningFadeType.GENERATION;
        thicknessFadeType = LightningFadeType.NONE;
        childrenDetachedEnd = false;
        // setter
        _smoothPercentage = 50;
        _childrenSmoothPercentage = 0;
        _childrenAngleVariation = 60;
        _childrenProbability = 0.025;
        _childrenProbabilityDecay = .5;
        _childrenMaxGenerations = 1;
        _childrenMaxCount = 4;
        _childrenMaxCountDecay = .5;
        _childrenLengthDecay = 0;
        _thicknessDecay;
        _wavelength = .3;
        _amplitude = .5;
        _speed = 1;
        // internal
        lifeSpan = 0;
        position = 0;
        absolutePosition = 1;
    }

    /**
     * @private
     */
    private function initialize():void {
        // randomize seeds
        _seed1 = Math.random() * 100;
        _seed2 = Math.random() * 100;
        // start life timer if needed
        if (lifeSpan > 0) {
            _lifeTimer = new Timer(lifeSpan * 1000, 1);
            _lifeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLifeSpanEnd, false, 0, true);
            _lifeTimer.start();
        }
        // setup points
        startX = 50;
        startY = 200;
        endX = 50;
        endY = 600;
        // setup factors
        _multi2 = .03;
        _stepEvery = 4;
        _steps = 50;
        // setup display objects
        _sbd = new BitmapData(_steps, 1, false);
        _bbd = new BitmapData(_steps, 1, false);
        // setup points
        _sOffsets = [new Point(0, 0), new Point(0, 0)];
        _bOffsets = [new Point(0, 0), new Point(0, 0)];
        // setup smoothing
        _drawMatrix = new Matrix();
        if (generation == 0) {
            _smoothMatrix = new Matrix();
            _smooth = new Sprite();
            childrenSmooth = new Sprite();
            smoothPercentage = 50;
            childrenSmoothPercentage = 50;
        } else {
            _smooth = childrenSmooth = parentInstance.childrenSmooth;
        }
        // setup default props
        steps = 100;
        _childrenLengthDecay = .5;
    }

    //----------------------------------
    //  Event Handlers
    //----------------------------------

    /**
     * @private
     */
    private function onRemoved(event:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        dispose();
    }

    /**
     * @private
     */
    private function onLifeSpanEnd(event:TimerEvent):void {
        //trace(this, "onLifeSpanEnd");
        if (this.parent)
            this.parent.removeChild(this);
        else
            dispose();
    }

    //----------------------------------
    //  API
    //----------------------------------

    /**
     * Disposes object and it's children.
     */
    private function dispose():void {
        //trace(this, "dispose");
        // remove timer
        if (_lifeTimer) {
            _lifeTimer.removeEventListener(TimerEvent.TIMER, onLifeSpanEnd);
            _lifeTimer.stop();
        }
        // remove children
        disposeAllChildren();
        // null variables
        _lifeTimer = null;
        _smoothMatrix = null;
        parentInstance = null;
    }

    /**
     * Removes all child Lightning objects.
     */
    public function disposeAllChildren():void {
        while (numChildren) {
            removeChildAt(0);
        }
    }

    /**
     * Removes child Lightning objects over limit.
     */
    public function validateChildren():void {
        if (numChildren && numChildren > _childrenMaxCount) {
            trace(this, "validateChildren", numChildren, _childrenMaxCount, numChildren);
            while (numChildren > _childrenMaxCount) {
                removeChildAt(numChildren - 1);
            }
        }
    }

    /**
     * Generates child Lightnings
     *
     * @param n TBD
     * @param recursive TBD
     */
    public function generateChild(n:uint = 1, recursive:Boolean = false):void {
        if (generation < _childrenMaxGenerations && numChildren < _childrenMaxCount) {
            var targetChildSteps:uint = _steps * _childrenLengthDecay;
            if (targetChildSteps >= 2) {
                for (var i:uint = 0; i < n; i++) {
                    var startStep:uint = Math.random() * _steps;
                    var endStep:uint = Math.random() * _steps;
                    while (endStep == startStep)
                        endStep = Math.random() * _steps;
                    // calc. child angle
                    var childAngle:Number = Math.random() * _childrenAngleVariation - _childrenAngleVariation / 2;
                    // create child Lightning
                    var child:Lightning = new Lightning(_color, thickness, generation + 1);
                    child.parentInstance = this;
                    child.lifeSpan = Math.random() * (childrenLifeSpanMax - childrenLifeSpanMin) + childrenLifeSpanMin;
                    child.position = 1 - startStep / _steps;
                    child.absolutePosition = absolutePosition * child.position;
                    child.alphaFadeType = alphaFadeType;
                    child.thicknessFadeType = thicknessFadeType;
                    if (alphaFadeType == LightningFadeType.GENERATION)
                        child.alpha = 1 - (1 / (_childrenMaxGenerations + 1)) * child.generation;
                    if (thicknessFadeType == LightningFadeType.GENERATION)
                        child.thickness = thickness - (thickness / (_childrenMaxGenerations + 1)) * child.generation;
                    child.childrenMaxGenerations = _childrenMaxGenerations;
                    child.childrenMaxCount = _childrenMaxCount * (1 - _childrenMaxCountDecay);
                    child.childrenProbability = _childrenProbability * (1 - _childrenProbabilityDecay);
                    child.childrenProbabilityDecay = _childrenProbabilityDecay;
                    child.childrenLengthDecay = _childrenLengthDecay;
                    child.childrenDetachedEnd = childrenDetachedEnd;
                    child.wavelength = _wavelength;
                    child.amplitude = _amplitude;
                    child.speed = _speed;
                    child.initialize();
                    child.endStep = endStep;
                    child.startStep = startStep;
                    child.childAngle = childAngle;
                    addChild(child);
                    child.steps = _steps * (1 - _childrenLengthDecay);
                    if (recursive)
                        child.generateChild(n, true);
                }
            }
        }
    }

    /**
     * TBD
     */
    public function update():void {
        // start update process
        _dx = endX - startX;
        _dy = endY - startY;
        _len = Math.sqrt(_dx * _dx + _dy * _dy);
        _sOffsets[0].x += (_steps / 100) * _speed;
        _sOffsets[0].y += (_steps / 100) * _speed;
        _sbd.perlinNoise(_steps / 20, _steps / 20, 1, _seed1, false, true, 7, true, _sOffsets);
        var calculatedWavelength:Number = _steps * _wavelength;
        var calculatedSpeed:Number = (calculatedWavelength * .1) * _speed;
        _bOffsets[0].x -= calculatedSpeed;
        _bOffsets[0].y += calculatedSpeed;
        _bbd.perlinNoise(calculatedWavelength, calculatedWavelength, 1, _seed2, false, true, 7, true, _bOffsets);
        if (_smoothPercentage > 0) {
            _drawMatrix.identity();
            _drawMatrix.scale(_steps / _smooth.width, 1);
            _bbd.draw(_smooth, _drawMatrix);
        }
        // get visibility from parent or by chance
        if (parentInstance) {
            visible = parent.visible;
        } else if (maxLength == 0) {
            visible = true;
        } else {
            var isVisibleProbability:Number;
            if (_len <= maxLength)
                isVisibleProbability = 1;
            else if (_len > maxLength + maxLengthVary)
                isVisibleProbability = 0;
            else
                isVisibleProbability = 1 - (_len - maxLength) / maxLengthVary;
            visible = Math.random() < isVisibleProbability ? true : false;
        }
        // generate children by chance
        const generateChildRandom:Number = Math.random();
        if (generateChildRandom < _childrenProbability)
            generateChild();
        // render only if visible
        if (visible)
            render();
        // update children
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).update();
        }
    }

    /**
     * TBD
     */
    public function render():void {
        // clear canvas
        this.graphics.clear();
        // start drawing
        this.graphics.lineStyle(thickness, _color);
        // calculate angle
        _angle = Math.atan2(endY - startY, endX - startX);
        // iterate
        for (var i:uint = 0; i < _steps; i++) {
            // get current position
            const currentPosition:Number = 1 / _steps * (_steps - i)
            // calculate alpha and thickness
            var relAlpha:Number = 1;
            var relThickness:Number = thickness;
            if (alphaFadeType == LightningFadeType.TIP_TO_END) {
                relAlpha = absolutePosition * currentPosition;
            }
            if (thicknessFadeType == LightningFadeType.TIP_TO_END) {
                relThickness = thickness * (absolutePosition * currentPosition);
            }
            if (alphaFadeType == LightningFadeType.TIP_TO_END || thicknessFadeType == LightningFadeType.TIP_TO_END) {
                this.graphics.lineStyle(int(relThickness), _color, relAlpha);
            }
            // draw lines with smoothing
            _soff = (_sbd.getPixel(i, 0) - SMOOTH_COLOR) / WHITE_COLOR * _len * _multi2;
            _soffx = Math.sin(_angle) * _soff;
            _soffy = Math.cos(_angle) * _soff;
            _boff = (_bbd.getPixel(i, 0) - SMOOTH_COLOR) / WHITE_COLOR * _len * _amplitude;
            _boffx = Math.sin(_angle) * _boff;
            _boffy = Math.cos(_angle) * _boff;
            _tx = startX + _dx / (_steps - 1) * i + _soffx + _boffx;
            _ty = startY + _dy / (_steps - 1) * i - _soffy - _boffy;
            if (i == 0)
                this.graphics.moveTo(_tx, _ty);
            this.graphics.lineTo(_tx, _ty);
            // iterate and draw sub-lines
            const n:uint = numChildren;
            for (var j:uint = 0; j < n; j++) {
                var cL:Lightning = Lightning(getChildAt(j));
                if (cL.startStep == i) {
                    cL.startX = _tx;
                    cL.startY = _ty;
                }
                if (cL.childrenDetachedEnd) {
                    var arad:Number = _angle + cL.childAngle / 180 * Math.PI;
                    var childLength:Number = _len * _childrenLengthDecay;
                    cL.endX = cL.startX + Math.cos(arad) * childLength;
                    cL.endY = cL.startY + Math.sin(arad) * childLength;
                }
                else {
                    if (cL.endStep == i) {
                        cL.endX = _tx;
                        cL.endY = _ty;
                    }
                }
            }
        }
    }

    /**
     * @private
     */
    override public function toString():String {
        return "[Lightning"
                + " id=" + id
                + " generation=" + generation
                + " numChildren=" + numChildren
                + "]";
    }

    //----------------------------------
    //  Getters/Setters
    //----------------------------------

    /**
     * Getter/Setter for the 'steps' property
     */
    public function set steps(value:uint):void {
        if (value < 2)
            value = 2;
        if (value > 2880)
            value = 2880;
        _steps = value;
        _sbd = new BitmapData(_steps, 1, false);
        _bbd = new BitmapData(_steps, 1, false);
        if (generation == 0)
            this.smoothPercentage = _smoothPercentage;
    }

    /**
     * @private
     */
    public function get steps():uint {
        return _steps;
    }

    /**
     * Getter/Setter for the 'smoothPercentage' property
     */
    public function set smoothPercentage(value:Number):void {
        if (_smooth) {
            _smoothPercentage = value;
            _smoothMatrix.identity();
            _smoothMatrix.createGradientBox(_steps, 1);
            var ratioOffset:uint = _smoothPercentage / 100 * 128;
            _smooth.graphics.clear();
            _smooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], _smoothMatrix);
            _smooth.graphics.drawRect(0, 0, _steps, 1);
            _smooth.graphics.endFill();
        }
    }

    /**
     * @private
     */
    public function get smoothPercentage():Number {
        return _smoothPercentage;
    }

    /**
     * Getter/Setter for the 'childrenSmoothPercentage' property
     */
    public function set childrenSmoothPercentage(value:Number):void {
        _childrenSmoothPercentage = value;
        _smoothMatrix.identity();
        _smoothMatrix.createGradientBox(_steps, 1);
        var ratioOffset:uint = _childrenSmoothPercentage / 100 * 128;
        childrenSmooth.graphics.clear();
        childrenSmooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], _smoothMatrix);
        childrenSmooth.graphics.drawRect(0, 0, _steps, 1);
        childrenSmooth.graphics.endFill();
    }

    /**
     * @private
     */
    public function get childrenSmoothPercentage():Number {
        return _childrenSmoothPercentage;
    }

    /**
     * Getter/Setter for the 'color' property
     */
    public function set color(value:uint):void {
        _color = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).color = value;
        }
    }

    /**
     * @private
     */
    public function get color():uint {
        return _color;
    }

    /**
     * Getter/Setter for the 'childrenProbability' property
     */
    public function set childrenProbability(value:Number):void {
        value = constrain(value);
        _childrenProbability = value;
    }

    /**
     * @private
     */
    public function get childrenProbability():Number {
        return _childrenProbability;
    }

    /**
     * Getter/Setter for the '' property
     */
    public function set childrenProbabilityDecay(value:Number):void {
        value = constrain(value);
        _childrenProbabilityDecay = value;
    }

    /**
     * @private
     */
    public function get childrenProbabilityDecay():Number {
        return _childrenProbabilityDecay;
    }

    /**
     * Getter/Setter for the '' property
     */
    public function set thicknessDecay(value:Number):void {
        value = constrain(value);
        _thicknessDecay = value;
    }

    /**
     * @private
     */
    public function get thicknessDecay():Number {
        return _thicknessDecay;
    }

    /**
     * Getter/Setter for the 'childrenLengthDecay' property
     */
    public function set childrenLengthDecay(value:Number):void {
        value = constrain(value);
        _childrenLengthDecay = value;
    }

    /**
     * @private
     */
    public function get childrenLengthDecay():Number {
        return _childrenLengthDecay;
    }

    /**
     * Getter/Setter for the 'childrenMaxGenerations' property
     */
    public function set childrenMaxGenerations(value:uint):void {
        _childrenMaxGenerations = value;
        validateChildren();
    }

    /**
     * @private
     */
    public function get childrenMaxGenerations():uint {
        return _childrenMaxGenerations;
    }

    /**
     * Getter/Setter for the 'childrenMaxCount' property
     */
    public function set childrenMaxCount(value:uint):void {
        _childrenMaxCount = value;
        validateChildren();
    }

    /**
     * @private
     */
    public function get childrenMaxCount():uint {
        return _childrenMaxCount;
    }

    /**
     * Getter/Setter for the 'childrenMaxCountDecay' property
     */
    public function set childrenMaxCountDecay(value:Number):void {
        value = constrain(value);
        _childrenMaxCountDecay = value;
    }

    /**
     * @private
     */
    public function get childrenMaxCountDecay():Number {
        return _childrenMaxCountDecay;
    }

    /**
     * Getter/Setter for the 'childrenAngleVariation' property
     */
    public function set childrenAngleVariation(value:Number):void {
        _childrenAngleVariation = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).childAngle = Math.random() * value - value / 2;
            Lightning(getChildAt(i)).childrenAngleVariation = value;
        }
    }

    /**
     * @private
     */
    public function get childrenAngleVariation():Number {
        return _childrenAngleVariation;
    }

    /**
     * Getter/Setter for the 'wavelength' property
     */
    public function set wavelength(value:Number):void {
        _wavelength = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).wavelength = value;
        }
    }

    /**
     * @private
     */
    public function get wavelength():Number {
        return _wavelength;
    }

    /**
     * Getter/Setter for the 'amplitude' property
     */
    public function set amplitude(value:Number):void {
        _amplitude = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).amplitude = value;
        }
    }

    /**
     * @private
     */
    public function get amplitude():Number {
        return _amplitude;
    }

    /**
     * Getter/Setter for the 'speed' property
     */
    public function set speed(value:Number):void {
        _speed = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).speed = value;
        }
    }

    /**
     * @private
     */
    public function get speed():Number {
        return _speed;
    }

    //----------------------------------
    //  Static Helper Methods
    //----------------------------------

    private static function constrain(num:Number, min:Number = 0, max:Number = 1):Number {
        if (num < min) return min;
        if (num > max) return max;
        return num;
    }
}
}

