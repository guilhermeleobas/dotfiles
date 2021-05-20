function unset_llvm
  set PATH (string match -v ~/Programs/llvm61/build/bin $PATH)
end
