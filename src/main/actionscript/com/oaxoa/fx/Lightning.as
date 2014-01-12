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
    public var childrenDetachedEnd:Boolean;

    /** TBD */
    public var thicknessFadeType:String;

    //----------------------------------
    //  Static Properties
    //----------------------------------

    /** @private */
    private static const SMOOTH_COLOR:uint = 0x808080;

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

    /**
     * Constructor
     */
    public function Lightning(color:uint = 0xffffff, thickness:Number = 2, generation:uint = 0) {
        setupDefaults();
        _color = color;
        this.thickness = thickness;
        this.generation = generation;
        this.alphaFadeType = LightningFadeType.GENERATION;
        this.thicknessFadeType = LightningFadeType.NONE;
        if (this.generation == 0)
            initialize();
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
            _lifeTimer.addEventListener(TimerEvent.TIMER, dispose, false, 0, true);
            _lifeTimer.start();
        }
        /*else {
         addEventListener(Event.REMOVED_FROM_STAGE, dispose, false, 0, true);
         } */
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
        if (generation == 0) {
            _smooth = new Sprite();
            childrenSmooth = new Sprite();
            smoothPercentage = 50;
            childrenSmoothPercentage = 50;
        } else {
            _smooth = childrenSmooth = parentInstance.childrenSmooth;
        }
        // setup default props
        steps = 100;
        childrenLengthDecay = .5;
    }

    //----------------------------------
    //  API
    //----------------------------------

    /**
     * Disposes object and it's children.
     */
    public function dispose(event:Event = null):void {
        trace(this, "dispose");
        // remove timer
        if (_lifeTimer) {
            _lifeTimer.removeEventListener(TimerEvent.TIMER, dispose);
            _lifeTimer.stop();
        }
        // remove children
        disposeAllChildren();
        // remove from parent
        if (parent)
            parent.removeChild(this);
        parentInstance = null;
    }

    /**
     * Removes all child Lightning objects.
     */
    public function disposeAllChildren():void {
        while (numChildren) {
            Lightning(removeChildAt(0)).dispose();
        }
    }

    /**
     * Removes child Lightning objects over limit.
     */
    public function validateChildren():void {
        if (numChildren && numChildren > childrenMaxCount) {
            trace(this, "validateChildren", numChildren, childrenMaxCount, numChildren);
            while (numChildren > childrenMaxCount) {
                Lightning(removeChildAt(numChildren - 1)).dispose();
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
        if (generation < childrenMaxGenerations && numChildren < childrenMaxCount) {
            trace(this, "generateChild", generation, numChildren, _childrenMaxCount);
            var targetChildSteps:uint = steps * childrenLengthDecay;
            if (targetChildSteps >= 2) {
                for (var i:uint = 0; i < n; i++) {
                    var startStep:uint = Math.random() * steps;
                    var endStep:uint = Math.random() * steps;
                    while (endStep == startStep)
                        endStep = Math.random() * steps;
                    // calc. child angle
                    var childAngle:Number = Math.random() * childrenAngleVariation - childrenAngleVariation / 2;
                    // create child Lightning
                    var child:Lightning = new Lightning(color, thickness, generation + 1);
                    child.parentInstance = this;
                    child.lifeSpan = Math.random() * (childrenLifeSpanMax - childrenLifeSpanMin) + childrenLifeSpanMin;
                    child.position = 1 - startStep / steps;
                    child.absolutePosition = absolutePosition * child.position;
                    child.alphaFadeType = alphaFadeType;
                    child.thicknessFadeType = thicknessFadeType;
                    if (alphaFadeType == LightningFadeType.GENERATION)
                        child.alpha = 1 - (1 / (childrenMaxGenerations + 1)) * child.generation;
                    if (thicknessFadeType == LightningFadeType.GENERATION)
                        child.thickness = thickness - (thickness / (childrenMaxGenerations + 1)) * child.generation;
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
                    child.endStep = endStep;
                    child.startStep = startStep;
                    child.childAngle = childAngle;
                    addChild(child);
                    child.steps = steps * (1 - childrenLengthDecay);
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
        _sOffsets[0].x += (steps / 100) * speed;
        _sOffsets[0].y += (steps / 100) * speed;
        _sbd.perlinNoise(steps / 20, steps / 20, 1, _seed1, false, true, 7, true, _sOffsets);
        var calculatedWavelength:Number = steps * wavelength;
        var calculatedSpeed:Number = (calculatedWavelength * .1) * speed;
        _bOffsets[0].x -= calculatedSpeed;
        _bOffsets[0].y += calculatedSpeed;
        _bbd.perlinNoise(calculatedWavelength, calculatedWavelength, 1, _seed2, false, true, 7, true, _bOffsets);
        if (smoothPercentage > 0) {
            var drawMatrix:Matrix = new Matrix();
            drawMatrix.scale(steps / _smooth.width, 1);
            _bbd.draw(_smooth, drawMatrix);
        }
        // get visibility from parent or by chance
        if (parentInstance != null) {
            visible = parentInstance.visible;
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
        var generateChildRandom:Number = Math.random();
        if (generateChildRandom < childrenProbability)
            generateChild();
        // render only if visible
        if (visible) {
            // trigger render method
            render();
        }
        // update children
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).update();
        }
    }

    public function render():void {
        this.graphics.clear();
        this.graphics.lineStyle(thickness, _color);
        _angle = Math.atan2(endY - startY, endX - startX);
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
                this.graphics.lineStyle(int(relThickness), _color, relAlpha);
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
                this.graphics.moveTo(_tx, _ty);
            this.graphics.lineTo(_tx, _ty);
            // iterate
            const n:uint = numChildren;
            for (var j:uint = 0; j < n; j++) {
                var cL:Lightning = Lightning(getChildAt(j));
                if (cL.startStep == i) {
                    cL.startX = _tx;
                    cL.startY = _ty;
                }
                if (cL.childrenDetachedEnd) {
                    var arad:Number = _angle + cL.childAngle / 180 * Math.PI;
                    var childLength:Number = _len * childrenLengthDecay;
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

    // STEPS

    /**
     * Setter for the 'steps' property
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
            this.smoothPercentage = smoothPercentage;
    }

    /**
     * TBD
     */
    public function get steps():uint {
        return _steps;
    }

    // SMOOTH PERC.

    /**
     * TBD
     */
    public function set smoothPercentage(value:Number):void {
        if (_smooth) {
            _smoothPercentage = value;
            var smoothmatrix:Matrix = new Matrix();
            smoothmatrix.createGradientBox(steps, 1);
            var ratioOffset:uint = _smoothPercentage / 100 * 128;
            _smooth.graphics.clear();
            _smooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], smoothmatrix);
            _smooth.graphics.drawRect(0, 0, steps, 1);
            _smooth.graphics.endFill();
        }
    }

    /**
     * TBD
     */
    public function get smoothPercentage():Number {
        return _smoothPercentage;
    }

    // CHILD SMOOTH PERC.

    /**
     * TBD
     */
    public function set childrenSmoothPercentage(value:Number):void {
        _childrenSmoothPercentage = value;
        var smoothmatrix:Matrix = new Matrix();
        smoothmatrix.createGradientBox(steps, 1);
        var ratioOffset:uint = _childrenSmoothPercentage / 100 * 128;
        childrenSmooth.graphics.clear();
        childrenSmooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1, 0, 0, 1], [0, ratioOffset, 255 - ratioOffset, 255], smoothmatrix);
        childrenSmooth.graphics.drawRect(0, 0, steps, 1);
        childrenSmooth.graphics.endFill();
    }

    /**
     * TBD
     */
    public function get childrenSmoothPercentage():Number {
        return _childrenSmoothPercentage;
    }

    // COLOR

    /**
     * TBD
     */
    public function set color(value:uint):void {
        _color = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).color = value;
        }
    }

    /**
     * TBD
     */
    public function get color():uint {
        return _color;
    }

    //

    /**
     * TBD
     */
    public function set childrenProbability(value:Number):void {
        if (value > 1)
            value = 1
        else if (value < 0)
            value = 0;
        _childrenProbability = value;
    }

    /**
     * TBD
     */
    public function get childrenProbability():Number {
        return _childrenProbability;
    }

    //

    /**
     * TBD
     */
    public function set childrenProbabilityDecay(value:Number):void {
        if (value > 1)
            value = 1
        else if (value < 0)
            value = 0;
        _childrenProbabilityDecay = value;
    }

    /**
     * TBD
     */
    public function get childrenProbabilityDecay():Number {
        return _childrenProbabilityDecay;
    }

    // THICKNESS DECAY (Not impl.)

    /**
     * TBD
     */
    public function set thicknessDecay(value:Number):void {
        if (value > 1)
            value = 1
        else if (value < 0)
            value = 0;
        _thicknessDecay = value;
    }

    /**
     * TBD
     */
    public function get thicknessDecay():Number {
        return _thicknessDecay;
    }

    // CHILD LEN. DECAY

    /**
     * TBD
     */
    public function set childrenLengthDecay(value:Number):void {
        if (value > 1)
            value = 1
        else if (value < 0)
            value = 0;
        _childrenLengthDecay = value;
    }

    /**
     * TBD
     */
    public function get childrenLengthDecay():Number {
        return _childrenLengthDecay;
    }

    // CHILD MAX GENERATIONS

    /**
     * TBD
     */
    public function set childrenMaxGenerations(value:uint):void {
        _childrenMaxGenerations = value;
        validateChildren();
    }

    /**
     * TBD
     */
    public function get childrenMaxGenerations():uint {
        return _childrenMaxGenerations;
    }

    // CHILD MAX COUNT

    /**
     * TBD
     */
    public function set childrenMaxCount(value:uint):void {
        _childrenMaxCount = value;
        validateChildren();
    }

    /**
     * TBD
     */
    public function get childrenMaxCount():uint {
        return _childrenMaxCount;
    }

    // CHILD MAX. COUNT DECAY

    /**
     * TBD
     */
    public function set childrenMaxCountDecay(value:Number):void {
        if (value > 1)
            value = 1
        else if (value < 0)
            value = 0;
        _childrenMaxCountDecay = value;
    }

    /**
     * TBD
     */
    public function get childrenMaxCountDecay():Number {
        return _childrenMaxCountDecay;
    }

    // ANGLE VAR.

    /**
     * TBD
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
     * TBD
     */
    public function get childrenAngleVariation():Number {
        return _childrenAngleVariation;
    }

    // WAVE LEN.

    /**
     * TBD
     */
    public function set wavelength(value:Number):void {
        _wavelength = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).wavelength = value;
        }
    }

    /**
     * TBD
     */
    public function get wavelength():Number {
        return _wavelength;
    }

    // AMP

    /**
     * TBD
     */
    public function set amplitude(value:Number):void {
        _amplitude = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).amplitude = value;
        }
    }

    /**
     * TBD
     */
    public function get amplitude():Number {
        return _amplitude;
    }

    // SPEED

    /**
     * TBD
     */
    public function set speed(value:Number):void {
        _speed = value;
        const n:uint = numChildren;
        for (var i:uint = 0; i < n; i++) {
            Lightning(getChildAt(i)).speed = value;
        }
    }

    /**
     * TBD
     */
    public function get speed():Number {
        return _speed;
    }
}
}

