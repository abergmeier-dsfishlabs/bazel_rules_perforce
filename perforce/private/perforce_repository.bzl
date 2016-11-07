# Copyright 2016 Deep Silver FISHLABS. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

OS_BINARY = {
  "linux": Label("@com_perforce_linux_x86_64//:BUILD"),
  "mac os x": Label("@com_perforce_mac_x86_64//:BUILD"),
}

OS_NIXY = {
  "linux": True,
  "mac os x": True,
}

URI_ENCODE = [
  ("%", "%25"),
  ("!", "%21"),
  ("#", "%23"),
  ("$", "%24"),
  ("&", "%26"),
  ("'", "%27"),
  ("(", "%28"),
  (")", "%29"),
  ("*", "%2A"),
  ("+", "%2B"),
  (",", "%2C"),
  ("/", "%2F"),
  (":", "%3A"),
  (";", "%3B"),
  ("=", "%3D"),
  ("?", "%3F"),
  ("@", "%40"),
  ("[", "%5B"),
  ("]", "%5D"),
]

def uri_encode(uri):
  result = str(uri)
  for src, tgt in URI_ENCODE:
    result = result.replace(src, tgt)

  return result

def _perforce_repository_impl(ctx):
  os_name = ctx.os.name

  perforceroot = ctx.path(OS_BINARY[os_name]).dirname

  # Try whether we have *nix utils in path
  hostname_result = ctx.execute([
    "hostname",
  ])

  # 1. Configure the platform dependent

  nixy = OS_NIXY[os_name]
  if nixy:
    perforcebinary = perforceroot.get_child("p4")

    if hostname_result.return_code:
      fail("Failed to gather hostname: %s" % hostname_result.stderr)
    hostname = hostname_result.stdout.strip(" \t\n\r")
  else:
    fail("Unsupported operating system: " + os_name)

  # 2. Create the environment with connection settings

  unique_id = uri_encode(ctx.path("."))

  perforce_environment = {
    "P4CLIENT": "%s_bazel_%s" % (hostname, unique_id),
  }

  if ctx.attr.host:
    perforce_environment["P4HOST"] = ctx.attr.host

  if ctx.attr.port:
    perforce_environment["P4PORT"] = ctx.attr.port

  if ctx.attr.user:
    perforce_environment["P4USER"] = ctx.attr.user

  if ctx.attr.passwd:
    perforce_environment["P4PASSWD"] = ctx.attr.passwd

  # 3. Handle actual revision to sync

  if ctx.attr.revision:
    rev = ctx.attr.revision
  else:
    fail("Need a revision to sync", "revision")

  if ctx.attr.stream:
    stream = ctx.attr.stream
  else:
    stream = rev

  # 3. Create Perforce client workspace

  root_path = ctx.path(".")

  ctx.file(".perforce_workspace", """\
Client: %s
Root: %s
Stream: %s
""" % (perforce_environment["P4CLIENT"], root_path, stream))

  config_path = ctx.path(".perforce_workspace")

  result = ctx.execute([
    "sh",
    "-c", "cat %s | %s client -i" % (config_path, perforcebinary),],
    environment = perforce_environment
  )

  if result.return_code:
    fail("Failed to create Perforce client spec: %s" % result.stderr)

  perforce_workspace_changed = not "Client %s not changed" % perforce_environment["P4CLIENT"] in result.stdout

  perforce_options = []

  # Earlier handling is nice but this should only be called on blank directory. And thus client workspace will be always out of sync.
  perforce_workspace_changed = True

  if perforce_workspace_changed:
    perforce_options.append("-f")

  # 4. Execute Perforce syncing of wprkspace

  print("Syncing with Perforce revision %s" % rev)
  result = ctx.execute([
      perforcebinary,
      "sync",
      "-q",
      ] + perforce_options + [
      rev,
      ],
      environment = perforce_environment
  )

  if result.return_code:
    fail("failed to sync %s: %s" % (rev, result.stderr))

def _new_perforce_repository_impl(ctx):
  _perforce_repository_impl(ctx)

  ctx.symlink(ctx.attr.build_file, "BUILD")

_perforce_repository_attrs = {
    "_type": attr.string(default = "readonly"),
    "host": attr.string(),
    "port": attr.string(),
    "user": attr.string(),
    "passwd": attr.string(),
    "stream": attr.string(),
    "revision": attr.string(mandatory = True),
}


p4_repository = repository_rule(
    implementation = _perforce_repository_impl,
    attrs = _perforce_repository_attrs,
)


new_p4_repository = repository_rule(
    implementation = _new_perforce_repository_impl,
    attrs = _perforce_repository_attrs + {
      "build_file": attr.string(mandatory = True),
    },
)


