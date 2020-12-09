# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def _set_args(arg, arg_name, args, inputs = None):
    if not arg:
        return
    args.append("%s%s" % (arg_name, arg.files.to_list()[0].path if hasattr(arg, "files") else arg))
    if inputs != None:
        inputs.append(arg.files.to_list()[0])

def _proto_from_disco_impl(ctx):
    arguments = []
    inputs = []

    attr = ctx.attr
    _set_args(attr.src, "--discovery_doc_path=", arguments, inputs)
    _set_args(",".join(attr.service_ignorelist), "--service_ignorelist=", arguments)
    _set_args(",".join(attr.message_ignorelist), "--message_ignorelist=", arguments)

    converter = ctx.executable.converter
    ctx.actions.run(
        inputs = inputs,
        outputs = [ctx.outputs.output],
        arguments = arguments + ["--output_file_path=%s" % ctx.outputs.output.path],
        progress_message = "%s: `%s %s`" % (ctx.label, converter.path, " ".join(arguments)),
        executable = converter,
    )

proto_from_disco = rule(
    attrs = {
        "src": attr.label(mandatory = True, allow_single_file = True),
        "service_ignorelist": attr.string_list(allow_empty=True, default=[]),
        "message_ignorelist": attr.string_list(allow_empty=True, default=[]),
        "converter": attr.label(
            default = Label("//:disco_to_proto3_converter"),
            executable = True,
            cfg = "host",
        ),
    },
    outputs = {
        "output": "%{name}.proto",
    },
    implementation = _proto_from_disco_impl,
)
