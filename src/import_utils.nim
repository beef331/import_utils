import macros, os, strutils

proc projectModuleRelPath(modules: NimNode, filePath: string): string =
  if modules.kind == nnkInfix:
    let temp = copyNimTree(modules)
    temp[2] = newEmptyNode()
    let 
      modPath = temp.repr.replace(" ").replace(".")
      absModPath = getProjectPath() & "/" & modPath
      absSourcePath = filePath.splitPath.head
    result = relativePath(absModPath, absSourcePath) & "/"
    case modules[2].kind:
    of nnkBracket:
      result.add '['
      for i, module in modules[2]:
        result.add $(module)
        if i != modules[2].len - 1:
          result.add ","
      result.add ']'
    of nnkIdent:
      result.add $modules[2]
    else: discard

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
  let modPath = projectModuleRelPath(modules, path) # Gets relative path for the module(s)
  result = parseStmt("import " & modpath) # Converts to ast

template absImport*(modules: untyped)=
  absImport(modules, instantiationInfo(-1, true).filename)
