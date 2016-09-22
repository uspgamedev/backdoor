
extends Node

export var major = 0
export var minor = 0
export var patch = 0
export(String, "unstable", "alpha", "beta", "rc", "stable") var status = "unstable"

func get_version_str():
  return var2str(major) + "." + var2str(minor) + "." + var2str(patch) + "-" + status
