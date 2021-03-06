// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub/src/exit_codes.dart' as exit_codes;
import 'package:scheduled_test/scheduled_test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

main() {
  initConfig();
  setUp(d.validPackage.create);

  integration('--force cannot be combined with --dry-run', () {
    schedulePub(args: ['lish', '--force', '--dry-run'],
        error: """
          Cannot use both --force and --dry-run.
          
          Usage: pub publish [options]
          -h, --help       Print this usage information.
          -n, --dry-run    Validate but do not publish the package.
          -f, --force      Publish without confirmation if there are no errors.
              --server     The package server to which to upload this package.
                           (defaults to "https://pub.dartlang.org")

          Run "pub help" to see global options.
          See http://dartlang.org/tools/pub/cmd/pub-lish.html for detailed documentation.
          """,
        exitCode: exit_codes.USAGE);
  });
}
