{ lib, stdenv, fetchurl, autoPatchelfHook, ... }:

let
  sources = builtins.fromJSON (builtins.readFile ./appsignal.json);
in stdenv.mkDerivation {
  name = "appsignal-nif";
  version = sources.version;

  src = let 
    triple = sources.triples.${stdenv.targetPlatform.system};
  in fetchurl {
    url = "${builtins.head sources.mirrors}/${sources.version}/${triple.filename}";
    sha256 = triple.checksum;
  };

  nativeBuildInputs = [] ++ lib.optional stdenv.isLinux autoPatchelfHook;

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  buildPhase = ''
  '';

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}