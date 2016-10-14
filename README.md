modulr
======

Description
-----------

`modulr` is a [CommonJS module implementation](http://commonjs.org/specs/modules/1.0.html)
in Ruby for client-side JavaScript. It accepts a singular file as input (the _program_) on
which is does static analysis to recursively resolve its dependencies.

The program, its dependencies and a small, namespaced JavaScript library are
concatenated into a single `js` file with optional minification through the [YUI Compressor](http://developer.yahoo.com/yui/compressor/). This improves load times by
[minimizing HTTP requests](http://developer.yahoo.com/performance/rules.html#num_http).
Further load time performance improvements are made possible by the built-in
[lazy evaluation](http://googlecode.blogspot.com/2009/09/gmail-for-mobile-html5-series-reducing.html)
option. Modules are delivered as JavaScript strings--instead of functions--and are
evaluated only when required.

The bundled JavaScript library provides each module with the necessary `require`
function and `exports` and `module` free variables. In its full version, the bundled
library also provided support for the [`require.ensure`](http://wiki.commonjs.org/wiki/Modules/Async/A) (async module requires) and [`require.define`](http://wiki.commonjs.org/wiki/Modules/Transport/D) (module transport) methods.

`modulr` can also be used as a build tool for JavaScript code that will be executed in a regular JS environment. In this case, the global variable defined by the `--global-export` option is assigned the `exports` of the main CommonJS module and asynchronous module requires are not supported.

Finally, `modulr` allows you to create handy [dependency graphs](http://modulrjs.org/spec_dependency_graph.html).

* [Github repository](http://github.com/codespeaks/modulr)
* [Specification](http://wiki.commonjs.org/wiki/Modules/1.0)

Install
-------

    $ [sudo] gem install modulr

Usage
-----

`modulr` is available as a Ruby library or as a command-line utility (`modulrize`).

To process a JavaScript source file, just run:

    $ modulrize filename.js > output.js

You can also simultaneously process multiples files like so:

    $ modulrize filename.js other_filename.js > output.js

Options are as follows:

    -o, --output=FILE                Write the output to FILE. Defaults to stdout.
    -r, --root=DIR                   Set DIR as root directory. Defaults to the directory containing FILE.
        --lazy-eval [MODULES]        Enable lazy evaluation of all JS modules or of those specified by MODULES.
                                     MODULES accepts a comma-separated list of identifiers.
        --minify                     Minify output using YUI Compressor.
        --global-export[=GLOBAL_VAR] If GLOBAL_VAR is specified and only one module is being processed, exports it to the GLOBAL_VAR global variable.
                                     If GLOBAL_VAR is specified and multiple modules are being processed, exports each one of them as a property of GLOBAL_VAR.
                                     If GLOBAL_VAR isn't specified, exports the module to global variables corresponding to their identifier.
        --main-module=MAIN_MODULE    Set the identifier of the main module (available through `require.main`).
        --sync                       Load all dependencies synchronously.
        --dependency-graph[=OUTPUT]  Create a dependency graph of the module.
    -h, --help                       Show this message.

Minification options (these are forwarded to YUI Compressor without the "minify-" prefix):

    --minify-disable-optimizations   Disable all micro optimizations.
    --minify-nomunge                 Minify only, do not obfuscate.
    --minify-verbose                 Display informational messages and warnings.
    --minify-line-break COLUMN       Insert a line break after the specified column number.
    --minify-preserve-semi           Preserve all semicolons.


Specs
-----

To run the specs, first clone the Git repository then grab the CommonJS
specs, included as a Git submodule, by running:

    $ git clone git://github.com/codespeaks/modulr.git
    $ cd modulr
    $ git submodule init
    $ git submodule update

[Mozilla's SpiderMonkey](http://www.mozilla.org/js/spidermonkey/) is required
and the `js` command line executable must be available on the load path (try `which js`).

You can run all the specs by issuing:

    $ rake spec

Alternatively, a list of comma-separated specs can be specified through the `SPECS`
environment variable (see `vendor/commonjs/tests/modules/1.0`) for a comprehensive
list of available specs).

    $ rake spec SPECS=absolute,transitive
