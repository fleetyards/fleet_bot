{
  description = "A Discord Ship Database using Fleetyards.net.";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }:
    let
      version = "${nixpkgs.lib.substring 0 8 self.lastModifiedDate}-${
          self.shortRev or "dirty"
        }";

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        });

    in {

      overlays.fleet = final: prev: {
        fleet_bot = final.callPackage ({ beam, rebar3 }:
          let
            packages = beam.packagesWith beam.interpreters.erlang;
            pname = "fleet_bot";
            src = self;
            mixEnv = "prod";
            mixDeps = packages.fetchMixDeps {
              pname = "mix-deps-${pname}";
              inherit src mixEnv version;
              sha256 = "sha256-lj80QNcBrMts7GV1x2LH7iFsO85KHLErJZ+8TBXi4wo=";
            };
          in packages.mixRelease {
            inherit pname version src mixEnv;

            mixFodDeps = mixDeps;

            nativeBuildInputs = [ rebar3 ];
          }) { };
      };
      overlays.default = self.overlays.fleet;

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) fleet_bot;
        default = self.packages.${system}.fleet_bot;
      });

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      nixosModules = {
        fleet_bot = import ./nix/fleet_bot.nix;
        default = self.nixosModules.fleet_bot;
      };

    };

  nixConfig = {
    extra-substituters = [ "https://fleetbot.cachix.org" ];
    extra-trusted-public-keys =
      [ "fleetbot.cachix.org-1:LCc89Bys++LoaCDgLuO47dcIoSFlRlPvXchGkr5LJLc=" ];
  };
}
