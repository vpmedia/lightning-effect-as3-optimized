/*
 Licensed under the MIT License

 Copyright (c) 2008 Pierluigi Pesenti (blog.oaxoa.com)
 Contributor (2014 Andras Csizmadia (www.vpmedia.eu)

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

public final class LightningPool {

    private static var MAX_VALUE:uint;

    private static var GROWTH_VALUE:uint;

    private static var COUNTER:uint;

    private static var POOL:Vector.<Lightning>;

    private static var CURRENT_ITEM:Lightning;

    public static function initialize(maxPoolSize:uint, growthValue:uint):void {
        MAX_VALUE = maxPoolSize;
        GROWTH_VALUE = growthValue;
        COUNTER = maxPoolSize;

        var i:uint = maxPoolSize;

        POOL = new Vector.<Lightning>(MAX_VALUE);
        while (--i > -1)
            POOL[i] = new Lightning();
    }

    public static function getLightning():Lightning {
        if (COUNTER > 0)
            return CURRENT_ITEM = POOL[--COUNTER];

        var i:uint = GROWTH_VALUE;
        while (--i > -1)
            POOL.unshift(new Lightning());
        COUNTER = GROWTH_VALUE;
        return getLightning();

    }

    public static function disposeLightning(disposedLightning:Lightning):void {
        POOL[COUNTER++] = disposedLightning;
    }
}
}