import macros, os, strutils

proc projectModuleRelPath(modules: NimNode, filePath: string): string =
  #echo getProjectPath(), " ", currentSourcePath()
  if modules.kind == nnkInfix:
    let temp = modules
    #echo temp.treeRepr
    temp[2] = newEmptyNode()
    let 
      modPath = temp.repr.replace(" ").replace(".")
      absModPath = getProjectPath() & modPath
      absSourcePath = block:
        var res = filePath
        res.splitPath.head
    echo absSourcePath
    echo absModPath

macro share*(modules: untyped): untyped =
  result = newStmtList()
  result.add quote do:
    import `modules`
  case modules.kind:
  of nnkIdent:
    result.add quote do:
      export `modules`
  of nnkInfix:
    if modules[2].kind == nnkIdent:
      let module = modules[2]
      result.add quote do:
        export `module`
    else:
      for module in modules[2]:
        result.add quote do:
          export `module`
  else: discard

macro absImport(modules: untyped, path: static[string]): untyped =
  echo path
  echo projectModuleRelPath(modules, path)

template aImport*(modules: untyped)=
  absImport(modules, instantiationInfo(-1, true).filename)
