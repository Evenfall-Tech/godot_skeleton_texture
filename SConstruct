#!/usr/bin/env python
import os
import sys

env = SConscript("thirdparty/godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

env.Append(CPPPATH=["#plugin/src/cpp/include/"])
sources = []
sources += Glob("#plugin/src/cpp/*.cpp")

if env["target"] in ["editor", "template_debug"]:
  doc_data = env.GodotCPPDocData("#plugin/src/gen/doc_data.gen.cpp", source=Glob("doc_classes/*.xml"))
  sources.append(doc_data)

binary_path = '#demo/addons/godotskeletontexture/.bin'
project_name = 'godotskeletontexture'

# Statically link with libgcc and libstdc++ for more Linux compatibility.
if env["platform"] == "linux":
    env.Append(
        LINKFLAGS=[
            "-Wl,--no-undefined",
            "-static-libgcc",
            "-static-libstdc++",
        ]
    )

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "{0}/{1}/{2}/lib{3}.{1}.framework/{3}.{1}".format(
            binary_path,
            env["platform"],
            env["target"],
            project_name,
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "{}/{}/{}/{}/lib{}{}".format(
            binary_path,
            env["platform"],
            env["target"],
            env["arch"],
            project_name,
            env["SHLIBSUFFIX"],
        ),
        source=sources,
    )

Default(library)
