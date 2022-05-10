open Astring
open Rresult
open Bos

type name = string * string

(** Name and version of the binary package corresponding to a given package. *)
let binary_name sandbox ~name ~ver =
  let ocaml_version = Sandbox_switch.ocaml_version sandbox in
  (name ^ "+cached", ver ^ "-ocaml" ^ ocaml_version)

let name_to_string (name, ver) = name ^ "." ^ ver
let has_binary_package repo (name, ver) = Repo.has_pkg repo ~pkg:name ~ver

let generate_opam_file original_name archive_path ocaml_version =
  Printf.sprintf
    {|
opam-version: "%s"
name: "%s"
install: [
  ["mkdir" "-p" "%%{prefix}%%/etc/opam-bin/packages"]
  ["rm" "-f" "bin-package.info"]
  ["cp" "-aT" "." "%%{prefix}%%"]
  [
    "mv"
    "%%{prefix}%%/bin-package.version"
    "%%{prefix}%%/etc/opam-bin/packages/ocamlformat"
  ]
]
depends: [
  "ocaml" {= "%s"}
]
url {
  src:
    "%s"
}
|}
    "2.0" original_name ocaml_version archive_path
(* name, opam-version
   install instructions
   depend on ocaml =exact
   conflict with original name
   archive *)

let should_remove = Fpath.(is_prefix (v "lib"))

let process_path prefix path =
  match Fpath.rem_prefix prefix path with
  | None -> None
  | Some path -> if should_remove path then None else Some path

(** Binary is already in the sandbox. Add this binary as a package in the local repo  *)
let make_binary_package sandbox repo bname ~original_name =
  let prefix = Sandbox_switch.switch_path_prefix sandbox in
  let archive_path =
    Fpath.(v "archives" / (name_to_string bname ^ ".tar.gz"))
  in
  Sandbox_switch.list_files sandbox ~pkg:original_name >>= fun paths ->
  let paths =
    List.filter_map (process_path prefix) paths
    |> List.map Fpath.to_string |> String.concat ~sep:"\n"
  in
  OS.Cmd.(
    in_string paths
    |> run_in Cmd.(v "tar" % "-C" % "cf" % p archive_path % "-T" % "-"))
  >>= fun () -> Ok ()
(* "tar -C PREFIX cf mon_archive.tar.gz -T -" *)
(* Collecter tous les fichiers (sauf les librairies) et en faire une tarball *)
(* Stocker (dans .opam/plugins/ocaml-platform/archives) *)
(* Générer le fichier "opam" à mettre dans repo_path_of_pkg *)
(* Faire un opam update *)
(* 1 Créer le "opam" dans local_repo/packages/  *)
