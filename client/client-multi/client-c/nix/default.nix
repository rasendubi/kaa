#
#  Copyright 2016 CyberVision, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

let
  raspberrypiSystem = {
    config = "armv6l-unknown-linux-gnueabi";
    # config = "arm-linux-gnueabihf";
    bigEndian = false;
    arch = "arm";
    float = "hard";
    fpu = "vfp";
    withTLS = true;
    libc = "glibc";
    platform = pkgs.platforms.raspberrypi;
    openssl.system = "linux-generic32";
    gcc = {
      arch = "armv6";
      fpu = "vfp";
      float = "softfp";
      abi = "aapcs-linux";
    };
  };

  raspberrypiPkgs = import <nixpkgs> { crossSystem = raspberrypiSystem; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
    gcc-xtensa-lx106 = callPackage ./gcc-xtensa-lx106 { };

    esp8266-rtos-sdk = callPackage ./esp8266-rtos-sdk { };

    cc3200-sdk = callPackage ./cc3200-sdk { };

    raspberrypi-tools = raspberrypiPkgs.gccCrossStageFinal;

    raspberrypi-openssl = raspberrypiPkgs.openssl.crossDrv;

    # Currently, it causes compilation failure, so we use 4.7 for now.
    # gcc-arm-embedded = pkgs.callPackage_i686 ./gcc-arm-embedded {
    #   dirName = "5.0";
    #   subdirName = "5-2015-q4-major";
    #   version = "5.2-2015q4-20151219";
    #   releaseType = "major";
    #   sha256 = "12mbwl9iwbw7h6gwwkvyvfmrsz7vgjz27jh2cz9z006ihzigi50y";
    # };
    gcc-arm-embedded = pkgs.gcc-arm-embedded-4_7;

    kaa-client = callPackage ./kaa-client { };

    astyle = pkgs.astyle.overrideDerivation (self: {
      sourceRoot = "astyle";
      preBuild = ''
        cd build/${if self.stdenv.cc.isClang then "clang" else "gcc"}
      '';
      patches = [ ./astyle/max_indent.patch ];
    });
  };

in self
