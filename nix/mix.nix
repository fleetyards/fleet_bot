{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    appsignal = buildMix rec {
      name = "appsignal";
      version = "2.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c4cv8r09cliarnvh1i58iw7izr87avawrswkz1fdjzmxjiayikm";
      };

      beamDeps = [ decorator hackney jason telemetry ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19bp6xh052ql3ha0v3r8999cvja5d2p6cph02mxphfaj4jsbyc53";
      };

      beamDeps = [];
    };

    castore = buildMix rec {
      name = "castore";
      version = "0.1.20";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12n9bb4v9b9sx9xk11k98s4f4a532dmmn0x4ak28dj990mjvf850";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ha6vmf5p3xlbf5w1msa89frhvfk535rnyfybz9wdmh6vdms8v96";
      };

      beamDeps = [];
    };

    chacha20 = buildMix rec {
      name = "chacha20";
      version = "1.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0j93ph8j02lk6xw3kzn7kf0vimjscfq52zysy3qh76df479za9r0";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    remedy_cowlib = buildRebar3 rec {
      name = "remedy_cowlib";
      version = "2.11.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0c5ij4f6bihg05q0rrsj2q83x1y3aldinpr86ihwp070131ksq8b";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.6.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lvxzksdrc2lbl0rzrww4q5rmayf37q0phcpz2kyvxq7n2zi1qa1";
      };

      beamDeps = [ bunt file_system jason ];
    };

    curve25519 = buildMix rec {
      name = "curve25519";
      version = "1.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0b8ryj7icn2x7b5nrvqd7yqpfawi3fwmzbn3bx6ls5gibgakmfhg";
      };

      beamDeps = [];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04iwywfqf8k125yfvm084l1mp0bcv82mwih7xlpb7kx61xdw29y1";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xzm8hfhn8q02rmg8cpgs68n5jz61wvqg7bxww9i1a6yanf6wril";
      };

      beamDeps = [];
    };

    decorator = buildMix rec {
      name = "decorator";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zsrasbf6z3g7xs1s8gk5g7rf49ng1dskphqfif8gnl3j3fww1qa";
      };

      beamDeps = [];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.29";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "00rmqvf3hkxfvkijqd624n0hn1xqims8h211xmm02fdi7qdsy0j9";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.9.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xgfz1pzylj22k0qa8zh4idvd4139b1lwnmq33na8fia2j69hpyy";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0w1zplm8ndf10dwxffg60iwzvbz3hyyiy761x91cvnwg6nsfxd8y";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    ed25519 = buildMix rec {
      name = "ed25519";
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iqfr14gzf1gbkdwjcic4c9yxp6qz4swl68hx1482gda7x7vib0d";
      };

      beamDeps = [];
    };

    equivalex = buildMix rec {
      name = "equivalex";
      version = "1.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1z25w0h81irkflyxfyni188p53srs859q6s6dv9iflc5vcd33yj6";
      };

      beamDeps = [];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.29.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1xkljn0ggg7fk8qv2dmr2m40h3lmfhi038p2hksdldja6yk5yx5p";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.14.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pd805jyd4qbpb2md3kw443325yqynpkpyr2iixb9zf432psqnal";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    gen_stage = buildMix rec {
      name = "gen_stage";
      version = "1.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "00ld2kivkr1bp0yg93q8yjmc48gx0n7rvqm30wmlww0g2hisyfcy";
      };

      beamDeps = [];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.20.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ggb458h60ch3inndqp9xhbailhb0jkq3xnp85sa94sy8dvv20qw";
      };

      beamDeps = [];
    };

    remedy_gun = buildRebar3 rec {
      name = "remedy_gun";
      version = "2.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vj49hlh7c2dlddcs1bnnxjz7klgv2ry36w0hrzpaayizf2mls5n";
      };

      beamDeps = [ cowlib ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.18.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13hja14kig5jnzcizpdghj68i88f0yd9wjdfjic9nzi98kzxmv54";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04wci9ifsfyd2pbcrnpgh2aq0a8fi1lpkrzb91kz3x93b8yq91rc";
      };

      beamDeps = [];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    influxql = buildMix rec {
      name = "influxql";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0p1006vaz2sq5bmnvsf58586b4m03fnflsbqhah0r0ync14z1ykm";
      };

      beamDeps = [];
    };

    instream = buildMix rec {
      name = "instream";
      version = "2.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0hkxm2g6dkzwvvkgj8j40azbgapngfj7slwzqffj3qf11ybz7mkp";
      };

      beamDeps = [ hackney influxql jason nimble_csv poolboy ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0891p2yrg3ri04p302cxfww3fi16pvvw1kh4r91zg85jhl87k8vr";
      };

      beamDeps = [ decimal ];
    };

    kcl = buildMix rec {
      name = "kcl";
      version = "1.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01dzxbz1036zx2cdrb7np5ga289bm1j8a9abhgv2v42dhk9ks24z";
      };

      beamDeps = [ curve25519 ed25519 poly1305 salsa20 ];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19jpprryixi452jwhws3bbks6ki3wni9kgzah3srg22a3x8fsi8a";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.16.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rrqydcq2bshs577z7jbgdnrlg7cpnzc8n48kap4c2ln2gfcpci8";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fvw0zr7vqd94vlj62xbqh0yrih1f7wwnmlj62rz0klax44hhk8p";
      };

      beamDeps = [ makeup ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0szzdfalafpawjrrwbrplhkgxjv8837mlxbkpbn5xlj4vgq0p8r7";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "106x9nmzi4ji5cqaddn76pxiyxdihk12z2qgszcdgd2rrjxsaxff";
      };

      beamDeps = [ castore hpax ];
    };

    nebulex = buildMix rec {
      name = "nebulex";
      version = "2.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lms95b8zwpa634f6wnwa5nj259m5jhd142rr4a7dm0gfzjqiy69";
      };

      beamDeps = [ decorator shards telemetry ];
    };

    nimble_csv = buildMix rec {
      name = "nimble_csv";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0amij6y3pgkpazhjr3madrn9c9lv6malq11ln1w82562zhbq2qnh";
      };

      beamDeps = [];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q6wa2ljprybfb9w2zg0gbppiwsnimgw5kcvakdp3z8mp42gk9sd";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c3hnppmjkwnqrc9vvm72kpliav0mqyyk4cjp7vsqccikgiqkmy8";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gv59waa505mz2gi956sj1aa6844c65w2dp2qh2jfgsx15am0w8w";
      };

      beamDeps = [];
    };

    nostrum = buildMix rec {
      name = "nostrum";
      version = "0.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0spp5c3l30pxslqsinvc0qizv9w7k26b7glgj9j6cxhkwi3mm4i7";
      };

      beamDeps = [ certifi gen_stage gun jason kcl mime ];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    poly1305 = buildMix rec {
      name = "poly1305";
      version = "1.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0fxwgp22jx9hb88vlnynb539smwk2r5dnf9ikca5w6d5c536hkp1";
      };

      beamDeps = [ chacha20 equivalex ];
    };

    poolboy = buildRebar3 rec {
      name = "poolboy";
      version = "1.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qq116314418jp4skxg8c6jx29fwp688a738lgaz6h2lrq29gmys";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.16.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s5jbwfzsdsyvlwgx3bqlfwilj2c468wi3qxq0c2d23fvhwxdspd";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    salsa20 = buildMix rec {
      name = "salsa20";
      version = "1.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ilaqpynkcs1hkdf2d3qryi7jqhlsm4cxrv1znqdsqx5rzcdqpbl";
      };

      beamDeps = [];
    };

    shards = buildRebar3 rec {
      name = "shards";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ir4y5zqplk6j8ik99f5ankypkzmfhggvhh1lskmi92lb9b8w60x";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0j6zq3y7xz768djz25x55gampyhd9nv6ax9dzx67f52nyyhv49xp";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "0.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iilk2n75kn9i95fdp8mpxvn3rcn3ghln7p77cijqws13j3y1sbv";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_metrics_appsignal = buildMix rec {
      name = "telemetry_metrics_appsignal";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0f69ny4gillri1fg81nrpsqc22nlg4gqg9iallpgfcni60gr8h70";
      };

      beamDeps = [ appsignal jason telemetry telemetry_metrics ];
    };

    telemetry_metrics_telegraf = buildMix rec {
      name = "telemetry_metrics_telegraf";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ms2qncl0rc0ardap1si6lb0sgn73c34hx87pqmzv5g1vid8ix92";
      };

      beamDeps = [ telemetry_metrics ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vjgxkxn9ll1gc6xd8jh4b0ldmg9l7fsfg7w63d44gvcssplx8mk";
      };

      beamDeps = [ telemetry ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08m1jlvcp1347k4v35xbv8plrv2xy6p8i440c4wsyxmx3zj8a0qx";
      };

      beamDeps = [ castore finch gun hackney jason mime mint telemetry ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };
  };
in self

