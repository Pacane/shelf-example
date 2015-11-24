// Copyright (c) 2015, Joel Trottier-Hebert. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'dart:convert';

List<String> users = [];

Middleware logMiddleware = createMiddleware(
    requestHandler: (Request r) => print('Requested url: ${r.url}'));

main(List<String> args) async {
  var addUserPipeline =
      const Pipeline().addMiddleware(logMiddleware).addHandler(addUserHandler);

  var getUsersPipeline =
      const Pipeline().addMiddleware(logMiddleware).addHandler(getUsersHandler);

  var cascade = new Cascade(shouldCascade: (Response r) => r == null)
      .add(addUserPipeline)
      .add(getUsersPipeline);

  var server = await io.serve(cascade.handler, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

Response addUserHandler(Request request) {
  if (request.url.path == "users" && request.method == 'POST') {
    var usernameParam = request.url.queryParameters['username'];
    if (usernameParam == null) {
      return new Response(400, body: "No username was provided");
    } else {
      users.add(usernameParam);
      return new Response.ok("");
    }
  } else {
    return null;
  }
}

Response getUsersHandler(Request request) {
  if (request.url.path == "users" && request.method == 'GET') {
    return new Response.ok(JSON.encode(users));
  } else {
    return null;
  }
}
