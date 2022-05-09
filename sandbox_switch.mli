open Rresult

type t

val init : ocaml_version:string -> (t, [> R.msg ]) result
val pin : t -> pkg:string -> url:string -> (unit, [> R.msg ]) result
val install : t -> pkgs:string list -> (unit, [> R.msg ]) result
val list_files : t -> pkg:string -> (string list, [> R.msg ]) result
