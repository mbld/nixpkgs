{ stdenv, lib, buildGoPackage, fetchFromGitHub, terraform, makeWrapper }:
rec {
  generic = { goDeps, version, sha256, ... }@attrs:
    let attrs' = builtins.removeAttrs attrs ["version" "sha256"]; in
    buildGoPackage ({
      name = "terragrunt-${version}";

      goPackagePath = "github.com/gruntwork-io/terragrunt";

      src = fetchFromGitHub {
        owner  = "gruntwork-io";
        repo   = "terragrunt";
        rev    = "v${version}";
        inherit sha256;
      };

      inherit goDeps;

      buildInputs = [ makeWrapper ];

      preBuild = ''
        buildFlagsArray+=("-ldflags" "-X main.VERSION=v${version}")
      '';

      postInstall = ''
        wrapProgram $bin/bin/terragrunt \
          --set TERRAGRUNT_TFPATH ${lib.getBin terraform}/bin/terraform
      '';

      meta = with stdenv.lib; {
        description = "A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices.";
        homepage = https://github.com/gruntwork-io/terragrunt/;
        license = licenses.mit;
        maintainers = with maintainers; [ peterhoeg ];
      };
    } // attrs');

  # Recent version.
  terragrunt_0_19 = generic {
    goDeps = ./deps_0_19.nix;
    sha256 = "0j7287g9lw06xvbxv9xi0g8zib0fbkihy67g7n1yygh9c3dbdxxi";
    version = "0.19.3";
  };

  # Last minor version that maintains compatibility with Terraform 0.11.x
  terragrunt_0_18 = generic {
    goDeps = ./deps_0_18.nix;
    sha256 = "08q6k03agq45p97b56n8dbj1khxcmw6vgc0r9zgbqxpkrq3r3vh6";
    version = "0.18.7";
  };

  # Version before providing multiple versions of this package.
  terragrunt_0_17 = generic {
    goDeps = ./deps_0_17.nix;
    sha256 = "13hlv0ydmv8gpzgg6bfr7rp89xfw1bkgd0j684armw8zq29cmv3a";
    version = "0.17.4";
  };

}
