open Bos
open Rresult

type t = Fpath.t

let init_repo path =
  OS.Dir.create path >>= fun _ ->
  OS.Dir.create (Fpath.add_seg path "packages") >>= fun _ ->
  OS.File.write (Fpath.add_seg path "repo") {|
    opam-version: "2.0"
  |}

let repo_name = "platform-cache"
let repo_path = Fpath.v "./cache_repo"

let init () =
  OS.Dir.exists repo_path  >>= fun initialized ->
  if initialized then Ok repo_path
  else
    init_repo repo_path >>= fun _ ->
    Exec.run_opam
      Cmd.(
        v "repository" % "add" % "--dont-select" % "-k" % "local" % "-y"
        % repo_name % p repo_path)
    >>= fun () ->
    Ok repo_path

let repo_path_of_pkg t ~pkg ~ver =
  Fpath.(t / "packages" / pkg / (pkg ^ "." ^ ver))

let has_pkg t ~pkg ~ver =
  match OS.Dir.exists (repo_path_of_pkg t ~pkg ~ver) with
  | Ok r -> r
  | Error _ -> false

let add_package t ~pkg ~ver ~opam =
  ignore (t, pkg, ver, opam);
  ()

let with_repo_enabled _ f =
  let unselect_repo () =
    ignore (Exec.run_opam Cmd.(v "repository" % "remove" % repo_name))
  in
  Exec.run_opam Cmd.(v "repository" % "add" % repo_name) >>= fun () ->
  Fun.protect ~finally:unselect_repo f
