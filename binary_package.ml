open Astring
open Rresult

type name = string * string

(** Name and version of the binary package corresponding to a given package. *)
let binary_name sandbox ~name ~ver =
  let ocaml_version = Sandbox_switch.ocaml_version sandbox in
  (name ^ "+cached", ver ^ "-ocaml" ^ ocaml_version)

let name_to_string (name, ver) = name ^ "." ^ ver
let has_binary_package repo (name, ver) = Repo.has_pkg repo ~pkg:name ~ver

let make_binary_package sandbox repo name ~original_name =
  ignore (sandbox, repo, name, original_name);
  Ok ()

(* Sandbox_switch.list_files sandbox ~pkg >>= fun paths -> *)
