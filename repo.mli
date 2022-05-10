open Bos

type t

val init : unit -> (t, 'e) OS.result
val has_pkg : t -> pkg:string -> ver:string -> bool
val add_package : t -> pkg:string -> ver:string -> opam:string -> unit
val with_repo_enabled : t -> (unit -> (('a, 'e) OS.result as 'r)) -> 'r
