// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS d.file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE d.file.

import 'descriptor.dart' as d;
import 'test_pub.dart';

main() {
  initConfig();
  forBothPubGetAndUpgrade((command) {
    integration('.packages file is created', () {
      servePackages((builder) {
        builder.serve("foo", "1.2.3",
            deps: {'baz': '2.2.2'}, contents: [d.dir("lib", [])]);
        builder.serve("bar", "3.2.1", contents: [d.dir("lib", [])]);
        builder.serve("baz", "2.2.2",
            deps: {"bar": "3.2.1"}, contents: [d.dir("lib", [])]);
      });

      d.appDir({"foo": "1.2.3"}).create();

      pubCommand(command);

      d.dir(appPath, [d.packagesFile({
          "foo": "1.2.3", "bar": "3.2.1", "baz": "2.2.2", "myapp": "0.0.0"})])
       .validate();
    });

    integration('.packages file is overwritten', () {
      servePackages((builder) {
        builder.serve("foo", "1.2.3",
            deps: {'baz': '2.2.2'}, contents: [d.dir("lib", [])]);
        builder.serve("bar", "3.2.1", contents: [d.dir("lib", [])]);
        builder.serve("baz", "2.2.2",
            deps: {"bar": "3.2.1"}, contents: [d.dir("lib", [])]);
      });

      d.appDir({"foo": "1.2.3"}).create();

      var oldFile = d.dir(appPath, [d.packagesFile({"notFoo": "9.9.9"})]);
      oldFile.create();
      oldFile.validate();  // Sanity-check that file was created correctly.

      pubCommand(command);

      d.dir(appPath, [d.packagesFile({
          "foo": "1.2.3", "bar": "3.2.1", "baz": "2.2.2", "myapp": "0.0.0"})])
       .validate();
    });

    integration('.packages file is not created if pub command fails', () {
      d.appDir({"foo": "1.2.3"}).create();

      pubCommand(command, args: ['--offline'],
                 error: "Could not find package foo in cache.\n");

      d.dir(appPath, [d.nothing('.packages')]).validate();
    });

    integration('.packages file has relative path to path dependency', () {
      servePackages((builder) {
        builder.serve("foo", "1.2.3",
            deps: {'baz': 'any'}, contents: [d.dir("lib", [])]);
        builder.serve("baz", "9.9.9",
            deps: {}, contents: [d.dir("lib", [])]);
      });

      d.dir("local_baz", [
        d.libDir("baz", 'baz 3.2.1'),
        d.libPubspec("baz", "3.2.1")
      ]).create();

      d.dir(appPath, [
        d.pubspec({
          "name": "myapp",
          "dependencies": {},
          "dependency_overrides": {
            "baz": {"path": "../local_baz"},
          }
        })
      ]).create();

      pubCommand(command);

      d.dir(appPath, [d.packagesFile({"myapp": "0.0.0",
                                      "baz": "../local_baz"})]).validate();
    });

  });
}
