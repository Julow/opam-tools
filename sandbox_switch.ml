open Bos
open Rresult

type t = { ocaml_version : string }

let switch_name ov = Fmt.str "opam-tools-%s" ov

let ocaml_version t = t.ocaml_version

let init ~ocaml_version =
  Exec.run_opam_l Cmd.(v "switch" % "list" % "-s") >>= fun all_sw ->
  let sw = switch_name ocaml_version in
  (match List.exists (( = ) sw) all_sw with
  | true -> Ok ()
  | false ->
      Logs.info (fun l -> l "Creating switch %s to use for tools" sw);
      Exec.run_opam
        Cmd.(v "switch" % "create" % sw % ocaml_version % "--no-switch"))
  >>= fun () -> Ok { ocaml_version }

let a_switch t = Cmd.(v "--switch" % switch_name t.ocaml_version)

let pin t ~pkg ~url = Exec.run_opam Cmd.(v "pin" %% a_switch t % "add" % "-ny" % pkg % url)
let install t ~pkgs = Exec.run_opam Cmd.(v "install" %% a_switch t % "-y" %% of_list pkgs)

let list_files t ~pkg =
  Exec.run_opam_l Cmd.(v "show" %% a_switch t % "--list-files" % pkg)
