# Comic Reader

Welcome to the Comic Reader App repository. This app reads [Comic Books files](https://en.wikipedia.org/wiki/Comic_book_archive) including CBR, CBZ and CB7 files. The app support devices from iOS 12.4 to iOS 13.5 right now.

You can read your comics:

![FirstImage](AppStore1.png)

The app also scans paper comics using your device camera. Depending of the version, you can use [VisionKit](https://developer.apple.com/documentation/visionkit) to scan your comics. With this option selected, the quality of the scanning improves:

![SecondImage](AppStore2.png)

You can download the app from the App Store from [here](https://apps.apple.com/us/app/id1522310540)

## How to contribute

Right now what we need is to have the app traslated to more languages, so you can create a pull request with the new language.

This was my first app, so it's sure it has some mistakes or improvements to make, so please, feel free contribute to the code.

## Special Thanks

The app use three diferent libraries to decompress the files, in order of implementation:

1. [marmelory/Zip](https://github.com/marmelroy/Zip)
2. [OlehKulykov/LzmaSDKObjC](https://github.com/OlehKulykov/LzmaSDKObjC)
3. [abbeycode/UnrarKit](https://github.com/abbeycode/UnrarKit)

Special thanks to all the people who contributed in those projects.


## Diferent Licenses from the libraries
- [marmelory/Zip](https://github.com/marmelroy/Zip)

    The MIT License (MIT)

    Copyright (c) 2015 Roy Marmelstein

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

- [OlehKulykov/LzmaSDKObjC](https://github.com/OlehKulykov/LzmaSDKObjC)

    The MIT License (MIT)

    Copyright (c) 2015 - 2019 Oleh Kulykov <info@resident.name>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

- [abbeycode/UnrarKit](https://github.com/abbeycode/UnrarKit)
 
    © Dov Frankel, All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
