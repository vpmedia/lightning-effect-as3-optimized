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

        public var startX:Number = 0;

        public var startY:Number = 0;

        public var endX:Number = 0;

        public var endY:Number = 0;

        public var thickness:Number = 2;

        public var childrenLifeSpanMin:Number = 0;

        public var childrenLifeSpanMax:Number = 0;

        public var childAngle:Number = 0;

        public var maxLength:Number = 0;

        public var maxLengthVary:Number = 0;

        public var startStep:uint;

        public var endStep:uint;

        public var isVisible:Boolean = true;

        public var alphaFadeType:String;

        public var childrenDetachedEnd:Boolean;

        public var thicknessFadeType:String;

        //----------------------------------
        //  Internal Properties
        //----------------------------------

        internal var generation:uint;

        internal var lifeSpan:Number = 0;

        internal var position:Number = 0;

        internal var parentInstance:Lightning;

        internal var absolutePosition:Number = 1;

        internal var childrenArray:Vector.<Lightning> = new Vector.<Lightning>();

        internal var childrenSmooth:Sprite;

        internal var id:uint = ID++;


        //----------------------------------
        //  Static Properties
        //----------------------------------

        private static const SMOOTH_COLOR:uint = 0x808080;

        private static var ID:uint = 0;

        //----------------------------------
        //  Getter/Setter Properties
        //----------------------------------

        //----------------------------------
        //  Private Properties
        //----------------------------------

        private var _holder:Sprite;

        private var _sbd:BitmapData;

        private var _bbd:BitmapData;

        private var _sOffsets:Array;

        private var _bOffsets:Array;

        private var _lifeTimer:Timer;

        private var _len:Number;

        private var _multi2:Number;

        private var _steps:uint;

        private var _stepEvery:Number;

        private var _seed1:uint;

        private var _seed2:uint;

        private var _smooth:Sprite;

        private var _smoothPercentage:uint = 50;

        private var _childrenMaxGenerations:uint = 1;

        private var _childrenProbability:Number = 0.025;

        private var _childrenProbabilityDecay:Number = .5;

        private var _childrenMaxCount:uint = 4;

        private var _childrenMaxCountDecay:Number = .5;

        private var _childrenLengthDecay:Number = 0;

        private var _childrenAngleVariation:Number = 60;

        private var _wavelength:Number = .3;

        private var _amplitude:Number = .5;

        private var _speed:Number = 1;

        private var _childrenSmoothPercentage:uint;

        private var _color:uint;

        private var _thicknessDecay:Number;

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
            _color = color;
            this.thickness = thickness;
            this.generation = generation;
            this.alphaFadeType = LightningFadeType.GENERATION;
            this.thicknessFadeType = LightningFadeType.NONE;
            if (this.generation == 0)
                initialize();
        }

        /**
         * TBD
         */
        private function initialize():void {
            // randomize seeds
            _seed1 = Math.random() * 100;
            _seed2 = Math.random() * 100;
            // start life timer if needed
            if (lifeSpan > 0)
                startLifeTimer();
            //
            //
            startX = 50;
            startY = 200;
            endX = 50;
            endY = 600;
            //
            _multi2 = .03;
            _stepEvery = 4;
            _steps = 50;
            _sbd = new BitmapData(_steps, 1, false);
            _bbd = new BitmapData(_steps, 1, false);
            _sOffsets = [new Point(0, 0), new Point(0, 0)];
            _bOffsets = [new Point(0, 0), new Point(0, 0)];
            if (generation == 0) {
                _smooth = new Sprite();
                childrenSmooth = new Sprite();
                smoothPercentage = 50;
                childrenSmoothPercentage = 50;
            } else {
                _smooth = childrenSmooth = parentInstance.childrenSmooth;
            }
            steps = 100;
            childrenLengthDecay = .5;
            //
            _holder = new Sprite();
            addChild(_holder);
        }

        //----------------------------------
        //  API
        //----------------------------------

        /**
         * TBD
         */
        public function startLifeTimer():void {
            trace(this, "startLifeTimer", lifeSpan);
            _lifeTimer = new Timer(lifeSpan * 1000, 1);
            _lifeTimer.addEventListener(TimerEvent.TIMER, dispose, false, 0, true);
            _lifeTimer.start();
        }

        /**
         * TBD
         */
        public function dispose(event:Event = null):void {
            trace(this, "dispose", parentInstance);
            // remove timer
            if (_lifeTimer) {
                _lifeTimer.removeEventListener(TimerEvent.TIMER, dispose);
                _lifeTimer.stop();
            }
            disposeAllChildren();
            childrenArray = null;
            parentInstance = null;
            if(this.parent)
                this.parent.removeChild(this);
        }

        /**
         * TBD
         */
        public function disposeAllChildren():void {
            if (childrenArray) {
                const n:uint = childrenArray.length;
                for (var i:uint = 0; i < n; i++) {
                    childrenArray[i].dispose();
                }
                childrenArray.length = 0;
            }
        }

        /**
         * TBD
         */
        public function generateChild(n:uint = 1, recursive:Boolean = false):void {
            if (generation < childrenMaxGenerations && childrenArray && childrenArray.length < childrenMaxCount) {
                trace(this, "generateChild", ID, n, recursive, generation, numChildren, _childrenMaxCount);
                var targetChildSteps:uint = steps * childrenLengthDecay;
                if (targetChildSteps >= 2) {
                    for (var i:uint = 0; i < n; i++) {
                        var startStep:uint = Math.random() * steps;
                        var endStep:uint = Math.random() * steps;
                        while (endStep == startStep)
                            endStep = Math.random() * steps;
                        var childAngle:Number = Math.random() * childrenAngleVariation - childrenAngleVariation / 2;
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
                        childrenArray.push(child);
                        addChild(child);
                        child.steps = steps * (1 - childrenLengthDecay);
                        if (recursive)
                            child.generateChild(n, true);
                    }
                }
            }
        }

        public function update():void {
            if (_holder) {
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
                //trace(this, id, "update", numChildren, childrenArray.length);
                if (isVisible) {
                    render();
                    visible = true;
                } else {
                    visible = false;
                    return;
                }
                const n:uint = childrenArray ? childrenArray.length : 0;
                for (var i:uint = 0; i < n; i++) {
                    childrenArray[i].update();
                }
            }
        }

        public function render():void {
            _holder.graphics.clear();
            _holder.graphics.lineStyle(thickness, _color);
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
                // iterate
                const n:uint = childrenArray ? childrenArray.length : 0;
                for (var j:uint = 0; j < n; j++) {
                    if (childrenArray[j].startStep == i) {
                        childrenArray[j].startX = _tx;
                        childrenArray[j].startY = _ty;
                    }
                    if (childrenArray[j].childrenDetachedEnd) {
                        var arad:Number = _angle + childrenArray[j].childAngle / 180 * Math.PI;
                        var childLength:Number = _len * childrenLengthDecay;
                        childrenArray[j].endX = childrenArray[j].startX + Math.cos(arad) * childLength;
                        childrenArray[j].endY = childrenArray[j].startY + Math.sin(arad) * childLength;
                    }
                    else {
                        if (childrenArray[j].endStep == i) {
                            childrenArray[j].endX = _tx;
                            childrenArray[j].endY = _ty;
                        }
                    }
                }
            }
        }

        public function killSurplus():void {
            if(childrenArray.length && childrenArray.length > childrenMaxCount) {
                trace(this, "killSurplus", childrenArray.length, childrenMaxCount, numChildren);
                while (childrenArray.length > childrenMaxCount) {
                    childrenArray.pop().dispose();
                }
            }
        }

        //----------------------------------
        //  Getters/Setters
        //----------------------------------

        public function set steps(value:uint):void {
            if (value < 2)
                value = 2;
            if (value > 2880)
                value = 2880;
            _steps = value;
            _sbd = new BitmapData(_steps, 1, false);
            _bbd = new BitmapData(_steps, 1, false);
            if (generation == 0)
                smoothPercentage = smoothPercentage;
        }

        public function get steps():uint {
            return _steps;
        }

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

        public function get smoothPercentage():Number {
            return _smoothPercentage;
        }

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

        public function get childrenSmoothPercentage():Number {
            return _childrenSmoothPercentage;
        }

        //

        public function set color(value:uint):void {
            _color = value;
            const n:uint = childrenArray ? childrenArray.length : 0;
            for (var i:uint = 0; i < n; i++) {
                childrenArray[i].color = value;
            }
        }

        public function get color():uint {
            return _color;
        }

        //

        public function set childrenProbability(value:Number):void {
            if (value > 1) {
                value = 1
            }
            else if (value < 0)
                value = 0;
            _childrenProbability = value;
        }

        public function get childrenProbability():Number {
            return _childrenProbability;
        }

        //

        public function set childrenProbabilityDecay(value:Number):void {
            if (value > 1) {
                value = 1
            }
            else if (value < 0)
                value = 0;
            _childrenProbabilityDecay = value;
        }

        public function get childrenProbabilityDecay():Number {
            return _childrenProbabilityDecay;
        }

        //

        public function set thicknessDecay(value:Number):void {
            if (value > 1) {
                value = 1
            }
            else if (value < 0)
                value = 0;
            _thicknessDecay = value;
        }

        public function get thicknessDecay():Number {
            return _thicknessDecay;
        }

        //

        public function set childrenLengthDecay(value:Number):void {
            if (value > 1) {
                value = 1
            }
            else if (value < 0)
                value = 0;
            _childrenLengthDecay = value;
        }

        public function get childrenLengthDecay():Number {
            return _childrenLengthDecay;
        }

        //

        public function set childrenMaxGenerations(value:uint):void {
            _childrenMaxGenerations = value;
            killSurplus();
        }

        public function get childrenMaxGenerations():uint {
            return _childrenMaxGenerations;
        }

        //

        public function set childrenMaxCount(value:uint):void {
            _childrenMaxCount = value;
            killSurplus();
        }

        public function get childrenMaxCount():uint {
            return _childrenMaxCount;
        }

        //

        public function set childrenMaxCountDecay(value:Number):void {
            if (value > 1) {
                value = 1
            }
            else if (value < 0)
                value = 0;
            _childrenMaxCountDecay = value;
        }

        public function get childrenMaxCountDecay():Number {
            return _childrenMaxCountDecay;
        }

        //

        public function set childrenAngleVariation(value:Number):void {
            _childrenAngleVariation = value;
            const n:uint = childrenArray ? childrenArray.length : 0;
            for (var i:uint = 0; i < n; i++) {
                childrenArray[i].childAngle = Math.random() * value - value / 2;
                childrenArray[i].childrenAngleVariation = value;
            }
        }

        public function get childrenAngleVariation():Number {
            return _childrenAngleVariation;
        }

        //

        public function set wavelength(value:Number):void {
            _wavelength = value;
            const n:uint = childrenArray ? childrenArray.length : 0;
            for (var i:uint = 0; i < n; i++) {
                childrenArray[i].wavelength = value;
            }
        }

        public function get wavelength():Number {
            return _wavelength;
        }

        //

        public function set amplitude(value:Number):void {
            _amplitude = value;
            const n:uint = childrenArray ? childrenArray.length : 0;
            for (var i:uint = 0; i < n; i++) {
                childrenArray[i].amplitude = value;
            }
        }

        public function get amplitude():Number {
            return _amplitude;
        }

        //

        public function set speed(value:Number):void {
            _speed = value;
            const n:uint = childrenArray ? childrenArray.length : 0;
            for (var i:uint = 0; i < n; i++) {
                childrenArray[i].speed = value;
            }
        }

        public function get speed():Number {
            return _speed;
        }
    }
}

