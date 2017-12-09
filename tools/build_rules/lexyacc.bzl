def genlex(name, src, out, hdr):
  cmd = "flex -o $(@D)/%s --header-file=$(@D)/%s $(location %s)" % (out, hdr, src)
  native.genrule(
    name = name,
    outs = [out, hdr],
    srcs = [src],
    cmd = cmd
  )

def genyacc(name, src, out, hdr):
  cmd = "bison -o $(@D)/%s --defines=$(@D)/%s $(location %s)" % (out, hdr, src)
  native.genrule(
    name = name,
    outs = [out, hdr],
    srcs = [src],
    cmd = cmd
  )
